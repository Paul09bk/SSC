import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ssc/models/user.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/models/class_session.dart';
import 'package:logging/logging.dart';

class FirebaseService {
  // Logger pour remplacer les prints
  final _logger = Logger('FirebaseService');
  
  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections Firestore
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _routinesCollection => _firestore.collection('routines');
  CollectionReference get _classesCollection => _firestore.collection('classes');

  // Authentification
  
  // Récupère l'utilisateur actuellement connecté
  User? get currentUser => _auth.currentUser;

  // Vérifie si un utilisateur est connecté
  bool get isUserLoggedIn => currentUser != null;

  // Inscription avec email et mot de passe
  Future<AppUser?> signUp({
    required String email, 
    required String password, 
    required String name
  }) async {
    try {
      // Création de l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (userCredential.user != null) {
        // Création du profil dans Firestore avec valeurs par défaut pour un nouvel utilisateur
        final appUser = AppUser(
          id: userCredential.user!.uid,
          name: name,
          email: email,
          isAdmin: false, // Par défaut, un nouvel utilisateur n'est pas admin
          trainingScore: 0,
          objectives: 0,
          totalObjectives: 5, // Par défaut, 5 objectifs à atteindre
          tamagotchiLevel: 'beginner',
        );
        
        await _usersCollection.doc(appUser.id).set(appUser.toMap());
        return appUser;
      }
    } catch (e) {
      _logger.warning('Erreur d\'inscription: $e');
      rethrow; // Renvoie l'erreur pour que l'appelant puisse la gérer
    }
    return null;
  }

  // Connexion avec email et mot de passe
  Future<AppUser?> signIn({required String email, required String password}) async {
    try {
      // Connexion à Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (userCredential.user != null) {
        // Récupération du profil depuis Firestore
        return await getUserById(userCredential.user!.uid);
      }
    } catch (e) {
      _logger.warning('Erreur de connexion: $e');
      rethrow; // Renvoie l'erreur pour que l'appelant puisse la gérer
    }
    return null;
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Gestion des utilisateurs
  
  // Récupérer un utilisateur par son ID
  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        // Si l'utilisateur existe dans Auth mais pas dans Firestore,
        // on peut créer automatiquement un profil de base
        if (currentUser != null && currentUser!.uid == userId) {
          final newUser = AppUser(
            id: userId,
            name: currentUser!.displayName ?? 'Utilisateur',
            email: currentUser!.email ?? '',
            isAdmin: false,
            trainingScore: 0,
            objectives: 0,
            totalObjectives: 5,
            tamagotchiLevel: 'beginner',
          );
          
          await _usersCollection.doc(userId).set(newUser.toMap());
          return newUser;
        }
      }
    } catch (e) {
      _logger.warning('Erreur récupération utilisateur: $e');
      rethrow;
    }
    return null;
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(AppUser user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      _logger.warning('Erreur mise à jour utilisateur: $e');
      rethrow;
    }
  }

  // Récupérer tous les utilisateurs (admin seulement)
  Future<List<AppUser>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _usersCollection.get();
      return snapshot.docs.map((doc) => 
        AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    } catch (e) {
      _logger.warning('Erreur récupération utilisateurs: $e');
      return [];
    }
  }

  // Gestion des routines
  
  // Ajouter une nouvelle routine
  Future<String?> addRoutine(Routine routine) async {
    try {
      // Préparer la routine pour Firestore
      final routineData = routine.toMap();
      
      // Si l'ID est vide, permettre à Firestore de générer un ID
      if (routine.id.isEmpty) {
        final docRef = await _routinesCollection.add(routineData);
        return docRef.id;
      } else {
        // Sinon utiliser l'ID fourni
        await _routinesCollection.doc(routine.id).set(routineData);
        return routine.id;
      }
    } catch (e) {
      _logger.warning('Erreur ajout routine: $e');
      return null;
    }
  }

  // Récupérer les routines d'un utilisateur
  Future<List<Routine>> getUserRoutines(String userId) async {
    try {
      final QuerySnapshot snapshot = await _routinesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('assignedDate')
          .get();
          
      return snapshot.docs.map((doc) => 
        Routine.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    } catch (e) {
      _logger.warning('Erreur récupération routines: $e');
      return [];
    }
  }

  // Récupérer les routines d'un utilisateur pour une semaine spécifique
  Future<List<Routine>> getUserRoutinesForWeek(String userId, DateTime weekStart) async {
    // Calcule la fin de la semaine (7 jours après le début)
    final weekEnd = weekStart.add(const Duration(days: 7));
    
    try {
      // Convertir les dates en Timestamp pour la requête Firestore
      final startTimestamp = Timestamp.fromDate(weekStart);
      final endTimestamp = Timestamp.fromDate(weekEnd);
      
      final QuerySnapshot snapshot = await _routinesCollection
          .where('userId', isEqualTo: userId)
          .where('assignedDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('assignedDate', isLessThan: endTimestamp)
          .orderBy('assignedDate')
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convertir le Timestamp en DateTime
        if (data['assignedDate'] is Timestamp) {
          data['assignedDate'] = (data['assignedDate'] as Timestamp).toDate().toIso8601String();
        }
        
        return Routine.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      _logger.warning('Erreur récupération routines par semaine: $e');
      return [];
    }
  }

  // Marquer une routine comme complétée
  Future<void> completeRoutine(String routineId) async {
    try {
      await _routinesCollection.doc(routineId).update({'isCompleted': true});
    } catch (e) {
      _logger.warning('Erreur marquage routine comme complétée: $e');
      rethrow;
    }
  }
  
  // Marquer une routine comme non complétée
  Future<void> uncompleteRoutine(String routineId) async {
    try {
      await _routinesCollection.doc(routineId).update({'isCompleted': false});
    } catch (e) {
      _logger.warning('Erreur marquage routine comme non complétée: $e');
      rethrow;
    }
  }

  // Gestion des cours
  
  // Ajouter un nouveau cours
  Future<String?> addClass(ClassSession classSession) async {
    try {
      final docRef = await _classesCollection.add(classSession.toMap());
      return docRef.id;
    } catch (e) {
      _logger.warning('Erreur ajout cours: $e');
      return null;
    }
  }

  // Récupérer les cours disponibles
  Future<List<ClassSession>> getAvailableClasses() async {
    try {
      // Récupère uniquement les cours à venir
      final now = DateTime.now();
      final nowTimestamp = Timestamp.fromDate(now);
      
      final QuerySnapshot snapshot = await _classesCollection
          .where('date', isGreaterThanOrEqualTo: nowTimestamp)
          .orderBy('date')
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convertir le Timestamp en DateTime
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        
        return ClassSession.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      _logger.warning('Erreur récupération cours: $e');
      return [];
    }
  }

  // Récupérer les cours d'un coach spécifique
  Future<List<ClassSession>> getCoachClasses(String coachId) async {
    try {
      final QuerySnapshot snapshot = await _classesCollection
          .where('coachId', isEqualTo: coachId)
          .orderBy('date')
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convertir le Timestamp en DateTime
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        
        return ClassSession.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      _logger.warning('Erreur récupération cours du coach: $e');
      return [];
    }
  }

  // Réserver un cours
  Future<bool> bookClass(String classId, String userId) async {
    try {
      // Récupère le cours
      final docRef = _classesCollection.doc(classId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        return false;
      }
      
      final classData = ClassSession.fromFirestore(docSnapshot);
      
      // Vérifie si le cours est plein ou si l'utilisateur est déjà inscrit
      if (classData.isFull || classData.isUserRegistered(userId)) {
        return false;
      }
      
      // Ajoute l'utilisateur à la liste des participants
      final List<String> updatedParticipants = [...classData.participantIds, userId];
      
      // Met à jour le document
      await docRef.update({'participantIds': updatedParticipants});
      return true;
    } catch (e) {
      _logger.warning('Erreur réservation cours: $e');
      return false;
    }
  }

  // Annuler une réservation
  Future<bool> cancelBooking(String classId, String userId) async {
    try {
      // Récupère le cours
      final docRef = _classesCollection.doc(classId);
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        return false;
      }
      
      final classData = ClassSession.fromFirestore(docSnapshot);
      
      // Vérifie si l'utilisateur est inscrit
      if (!classData.isUserRegistered(userId)) {
        return false;
      }
      
      // Retire l'utilisateur de la liste des participants
      final List<String> updatedParticipants = classData.participantIds
          .where((id) => id != userId)
          .toList();
      
      // Met à jour le document
      await docRef.update({'participantIds': updatedParticipants});
      return true;
    } catch (e) {
      _logger.warning('Erreur annulation réservation: $e');
      return false;
    }
  }

  // Mettre à jour les statistiques de l'utilisateur après la complétion d'une routine
  Future<void> updateUserStats(String userId, {int scoreIncrease = 5}) async {
    try {
      // Récupération de l'utilisateur actuel
      final user = await getUserById(userId);
      if (user == null) return;
      
      // Mise à jour du score d'entraînement et des objectifs
      int newTrainingScore = user.trainingScore + scoreIncrease;
      if (newTrainingScore > 100) newTrainingScore = 100;
      
      int newObjectives = user.objectives + 1;
      if (newObjectives > user.totalObjectives) {
        newObjectives = user.totalObjectives;
      }
      
      // Mise à jour du niveau du Tamagotchi si nécessaire
      String tamagotchiLevel = user.tamagotchiLevel;
      if (newTrainingScore > 90) {
        tamagotchiLevel = 'expert';
      } else if (newTrainingScore > 70) {
        tamagotchiLevel = 'intermediate';
      } else if (newTrainingScore > 40) {
        tamagotchiLevel = 'beginner';
      }
      
      // Mise à jour des données utilisateur
      await _usersCollection.doc(userId).update({
        'trainingScore': newTrainingScore,
        'objectives': newObjectives,
        'tamagotchiLevel': tamagotchiLevel,
      });
    } catch (e) {
      _logger.warning('Erreur mise à jour statistiques: $e');
      rethrow;
    }
  }
  
  // Récupération du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      _logger.warning('Erreur récupération mot de passe: $e');
      rethrow;
    }
  }
  
  // Ajouter plusieurs routines en une seule fois (pour les coachs)
  Future<List<String>> addMultipleRoutines(List<Routine> routines) async {
    final List<String> routineIds = [];
    
    try {
      // Utiliser une batch pour des performances optimales
      final batch = _firestore.batch();
      
      for (final routine in routines) {
        // Préparer la routine pour Firestore
        final routineData = routine.toMap();
        
        // Créer une référence de document
        final docRef = _routinesCollection.doc();
        batch.set(docRef, routineData);
        
        routineIds.add(docRef.id);
      }
      
      // Exécuter toutes les opérations en une fois
      await batch.commit();
      
      return routineIds;
    } catch (e) {
      _logger.warning('Erreur ajout multiples routines: $e');
      return [];
    }
  }
  
  // Supprimer une routine
  Future<bool> deleteRoutine(String routineId) async {
    try {
      await _routinesCollection.doc(routineId).delete();
      return true;
    } catch (e) {
      _logger.warning('Erreur suppression routine: $e');
      return false;
    }
  }

  // Dans firebase_service.dart
Future<bool> deleteClass(String classId) async {
  try {
    await _classesCollection.doc(classId).delete();
    return true;
  } catch (e) {
    _logger.warning('Erreur suppression classe: $e');
    return false;
  }
}



}