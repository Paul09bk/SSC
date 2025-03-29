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
        // Création du profil dans Firestore
        final appUser = AppUser(
          id: userCredential.user!.uid,
          name: name,
          email: email,
        );
        
        await _usersCollection.doc(appUser.id).set(appUser.toMap());
        return appUser;
      }
    } catch (e) {
      _logger.warning('Erreur d\'inscription: $e');
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
      }
    } catch (e) {
      _logger.warning('Erreur récupération utilisateur: $e');
    }
    return null;
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(AppUser user) async {
    await _usersCollection.doc(user.id).update(user.toMap());
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
      final docRef = await _routinesCollection.add(routine.toMap());
      return docRef.id;
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
      final QuerySnapshot snapshot = await _routinesCollection
          .where('userId', isEqualTo: userId)
          .where('assignedDate', isGreaterThanOrEqualTo: weekStart)
          .where('assignedDate', isLessThan: weekEnd)
          .orderBy('assignedDate')
          .get();
          
      return snapshot.docs.map((doc) => 
        Routine.fromMap(doc.data() as Map<String, dynamic>, doc.id)
      ).toList();
    } catch (e) {
      _logger.warning('Erreur récupération routines par semaine: $e');
      return [];
    }
  }

  // Marquer une routine comme complétée
  Future<void> completeRoutine(String routineId) async {
    await _routinesCollection.doc(routineId).update({'isCompleted': true});
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
      final QuerySnapshot snapshot = await _classesCollection
          .where('date', isGreaterThanOrEqualTo: now.toIso8601String())
          .orderBy('date')
          .get();
          
      return snapshot.docs.map((doc) => 
        ClassSession.fromFirestore(doc)
      ).toList();
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
          
      return snapshot.docs.map((doc) => 
        ClassSession.fromFirestore(doc)
      ).toList();
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
    }
  }
}