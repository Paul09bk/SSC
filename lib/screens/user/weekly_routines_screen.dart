import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:flutter_ssc/screens/user/routine_validation_screen.dart';
import 'package:flutter_ssc/screens/user/class_booking_screen.dart';
import 'package:flutter_ssc/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyRoutinesScreen extends StatefulWidget {
  const WeeklyRoutinesScreen({super.key});

  @override
  State<WeeklyRoutinesScreen> createState() => _WeeklyRoutinesScreenState();
}

class _WeeklyRoutinesScreenState extends State<WeeklyRoutinesScreen> {
  // Date de début de la semaine actuelle (lundi)
  late DateTime _weekStartDate;
  
  // Liste des routines
  List<Routine> _routines = [];
  
  // Indique si les routines sont en cours de chargement
  bool _isLoading = true;
  
  // Service Firebase
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _initializeWeekStartDate();
    _loadRoutines();
  }

  // Initialise la date de début de semaine au lundi
  void _initializeWeekStartDate() {
    final now = DateTime.now();
    // Détermine le premier jour de la semaine (lundi)
    // 1 = lundi, 2 = mardi, etc.
    final weekday = now.weekday;
    _weekStartDate = now.subtract(Duration(days: weekday - 1));
  }

  // Charge les routines depuis Firebase
Future<void> _loadRoutines() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    // Récupère l'ID de l'utilisateur connecté
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Si aucun utilisateur n'est connecté, retourner à l'écran de connexion
      if (mounted) {
        Navigator.of(context).pop();
      }
      return; // Ce return termine la fonction sans renvoyer de Future explicite
    }
    
    // Récupère les routines de l'utilisateur pour la semaine
    final routines = await _firebaseService.getUserRoutinesForWeek(
      currentUser.uid,
      _weekStartDate,
    );
    
    if (mounted) {
      setState(() {
        _routines = routines;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      // Affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des routines: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

  // Navigation vers la semaine précédente
  void _previousWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
    });
    _loadRoutines();
  }

  // Navigation vers la semaine suivante
  void _nextWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.add(const Duration(days: 7));
    });
    _loadRoutines();
  }

  // Obtenir les routines pour un jour spécifique
  List<Routine> _getRoutinesForDay(DateTime day) {
    return _routines.where((routine) =>
      routine.assignedDate.year == day.year &&
      routine.assignedDate.month == day.month &&
      routine.assignedDate.day == day.day
    ).toList();
  }

  // Formater une date pour l'affichage
  String _formatDate(DateTime date) {
    return DateFormat('E. d MMMM', 'fr_FR').format(date);
  }

  // Marquer une routine comme complétée/non complétée
  void _toggleRoutineCompletion(Routine routine) async {
    // Affiche un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Inverse l'état de complétion
      final updatedStatus = !routine.isCompleted;
      
      // Mise à jour dans Firestore
      if (updatedStatus) {
        // Si la routine est complétée, mettre à jour le statut
        await _firebaseService.completeRoutine(routine.id);
        
        // Mettre à jour les statistiques de l'utilisateur
        await _firebaseService.updateUserStats(
          FirebaseAuth.instance.currentUser!.uid,
          scoreIncrease: 5, // Augmenter le score de 5 points
        );
      } else {
        // Si la routine est démarquée, mettre à jour le statut
        // Dans cet exemple, nous ne fournissons pas de méthode pour démarquer
        // une routine dans le service Firebase, donc nous pourrions ajouter cette
        // fonctionnalité au service
        await _firebaseService.uncompleteRoutine(routine.id);
      }
      
      // Recharger les routines pour mettre à jour l'interface
      await _loadRoutines();
      
      // Fermer l'indicateur de chargement
      if (mounted) {
        Navigator.pop(context);
        
        // Afficher un message de confirmation
        final message = updatedStatus
            ? 'Bravo ! Routine "${routine.name}" complétée !'
            : 'Routine "${routine.name}" marquée comme non complétée';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: updatedStatus
                ? AppTheme.successColor
                : Colors.grey[700],
          ),
        );
      }
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (mounted) {
        Navigator.pop(context);
        
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour de la routine: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes routines de la semaine'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Aide / Informations sur cet écran
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Aide',
            onPressed: () {
              // Afficher un dialogue d'aide
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: const Text('Comment ça marche'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cet écran affiche vos routines assignées pour chaque jour de la semaine.'),
                      SizedBox(height: 8),
                      Text('• Naviguez entre les semaines avec les flèches en haut'),
                      Text('• Appuyez sur une routine pour voir ses détails'),
                      Text('• Cochez le cercle à droite pour marquer une routine comme terminée'),
                      SizedBox(height: 8),
                      Text('Le bouton flottant en bas à droite vous permet de commencer vos routines d\'aujourd\'hui.'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Compris !'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // En-tête avec navigation de semaine
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: _previousWeek,
                      ),
                      Text(
                        'Semaine du ${DateFormat('d MMMM', 'fr_FR').format(_weekStartDate)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: _nextWeek,
                      ),
                    ],
                  ),
                ),
                
                // Liste des jours de la semaine et routines
                Expanded(
                  child: _routines.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune routine programmée pour cette semaine',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: 7, // 7 jours de la semaine
                          itemBuilder: (context, index) {
                            final day = _weekStartDate.add(Duration(days: index));
                            final routinesForDay = _getRoutinesForDay(day);
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête du jour
                                Container(
                                  color: AppTheme.cardColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, 
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDate(day),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${routinesForDay.length} routine(s)',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Liste des routines du jour
                                if (routinesForDay.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Aucune routine programmée',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  )
                                else
                                  ...routinesForDay.map((routine) => _buildRoutineItem(routine)),
                                
                                const Divider(height: 1),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get routines for today
          final now = DateTime.now();
          final routinesForToday = _getRoutinesForDay(now);
          
          if (routinesForToday.isEmpty) {
            // No routines available for today
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucune routine disponible pour aujourd\'hui')),
            );
          } else {
            // Take first incomplete routine as example
            final routine = routinesForToday.firstWhere(
              (r) => !r.isCompleted,
              orElse: () => routinesForToday.first,
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoutineValidationScreen(routine: routine),
              ),
            ).then((_) {
              // Reload routines after returning
              _loadRoutines();
            });
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.fitness_center),
      ),
      drawer: Drawer(
        backgroundColor: AppTheme.backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
              ),
              accountName: Text(
                'Utilisateur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              accountEmail: Text(
                'Membre',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.accentColor,
                child: Text(
                  'U',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            
            // Menu utilisateur
            ListTile(
              leading: const Icon(Icons.pets, color: AppTheme.accentColor),
              title: const Text('Mon Tamagotchi'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.pop(context); // Retourne à l'écran Tamagotchi
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.white),
              title: const Text('Mes routines'),
              selected: true,
              selectedTileColor: Color.fromRGBO(61, 90, 254, 0.1),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text('Réserver un cours'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                // Navigation vers l'écran de réservation
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ClassBookingScreen()),
                );
              },
            ),
          
            const Divider(color: Colors.grey),
            
            // Déconnexion
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Déconnexion'),
              onTap: () async {
                // Ferme le drawer
                Navigator.pop(context);
                
                // Affiche un dialogue de confirmation
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.cardColor,
                    title: const Text('Déconnexion'),
                    content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Déconnexion'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ) ?? false;

                if (confirmed && context.mounted) {
                  try {
                    // Affiche un indicateur de chargement
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                    
                    // Appel au service Firebase pour la déconnexion
                    await _firebaseService.signOut();
                    
                    // Ferme l'indicateur de chargement
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    
                    // L'AuthWrapper détectera le changement d'état d'authentification
                    // et reviendra automatiquement à l'écran de connexion
                  } catch (e) {
                    // Ferme l'indicateur de chargement en cas d'erreur
                    if (context.mounted) {
                      Navigator.pop(context);
                      
                      // Affiche un message d'erreur
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de la déconnexion: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Construit un élément de routine
  Widget _buildRoutineItem(Routine routine) {
    return ListTile(
      title: Text(
        routine.name,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        routine.description,
        style: TextStyle(
          color: Colors.grey[400],
          decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: InkWell(
        onTap: () => _toggleRoutineCompletion(routine),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: routine.isCompleted ? AppTheme.successColor : Colors.transparent,
            border: Border.all(
              color: routine.isCompleted ? AppTheme.successColor : Colors.grey,
              width: 2,
            ),
          ),
          child: routine.isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
      ),
      onTap: () {
        // Naviguer vers l'écran de validation pour cette routine
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoutineValidationScreen(routine: routine),
          ),
        ).then((_) {
          // Recharger les routines après le retour de l'écran de validation
          _loadRoutines();
        });
      },
    );
  }
}