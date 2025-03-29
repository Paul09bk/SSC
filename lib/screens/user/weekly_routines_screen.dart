import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:flutter_ssc/screens/user/routine_validation_screen.dart';
import 'package:flutter_ssc/screens/user/class_booking_screen.dart';

class WeeklyRoutinesScreen extends StatefulWidget {
  const WeeklyRoutinesScreen({super.key});

  @override
  State<WeeklyRoutinesScreen> createState() => _WeeklyRoutinesScreenState();
}

class _WeeklyRoutinesScreenState extends State<WeeklyRoutinesScreen> {
  // Date de début de la semaine actuelle (lundi)
  late DateTime _weekStartDate;
  
  // Liste des routines (simulées pour l'instant)
  late List<Routine> _routines;

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

  // Charge les routines depuis Firebase (simulé pour l'instant)
  void _loadRoutines() {
    // TODO: Remplacer par un appel à Firebase
    _routines = [
      Routine(
        id: '1',
        name: 'Pompes',
        description: '3 séries de 10 pompes',
        userId: 'user123',
        assignedDate: _weekStartDate,
        isCompleted: true,
      ),
      Routine(
        id: '2',
        name: 'Burpees',
        description: '4 séries de 8 burpees',
        userId: 'user123',
        assignedDate: _weekStartDate.add(const Duration(days: 1)),
        isCompleted: false,
      ),
      Routine(
        id: '3',
        name: 'Squats',
        description: '3 séries de 15 squats',
        userId: 'user123',
        assignedDate: _weekStartDate.add(const Duration(days: 2)),
        isCompleted: false,
      ),
      Routine(
        id: '4',
        name: 'Abdominaux',
        description: '4 séries de 12 crunchs',
        userId: 'user123',
        assignedDate: _weekStartDate.add(const Duration(days: 3)),
        isCompleted: false,
      ),
      Routine(
        id: '5',
        name: 'Fentes',
        description: '3 séries de 10 fentes par jambe',
        userId: 'user123',
        assignedDate: _weekStartDate.add(const Duration(days: 4)),
        isCompleted: false,
      ),
    ];
  }

  // Navigation vers la semaine précédente
  void _previousWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.subtract(const Duration(days: 7));
      _loadRoutines();
    });
  }

  // Navigation vers la semaine suivante
  void _nextWeek() {
    setState(() {
      _weekStartDate = _weekStartDate.add(const Duration(days: 7));
      _loadRoutines();
    });
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
  void _toggleRoutineCompletion(Routine routine) {
    setState(() {
      // Localiser et modifier la routine dans la liste
      final index = _routines.indexWhere((r) => r.id == routine.id);
      if (index != -1) {
        // Créer une nouvelle routine avec le statut inversé
        final updatedRoutine = Routine(
          id: routine.id,
          name: routine.name,
          description: routine.description,
          userId: routine.userId,
          assignedDate: routine.assignedDate,
          isCompleted: !routine.isCompleted,
        );
        
        // Remplacer l'ancienne routine par la nouvelle
        _routines[index] = updatedRoutine;
        
        // Afficher un message de confirmation
        final message = updatedRoutine.isCompleted
            ? 'Bravo ! Routine "${routine.name}" complétée !'
            : 'Routine "${routine.name}" marquée comme non complétée';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: updatedRoutine.isCompleted
                ? AppTheme.successColor
                : Colors.grey[700],
          ),
        );
        
        // TODO: Mettre à jour le statut dans Firebase
      }
    });
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
      body: Column(
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
            child: ListView.builder(
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
    // Version simplifiée qui prend simplement la première routine comme exemple
    if (_routines.isNotEmpty) {
      // Prendre simplement la première routine comme exemple
      final sampleRoutine = _routines.first;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoutineValidationScreen(routine: sampleRoutine),
        ),
      ).then((_) {
        setState(() {
          _loadRoutines();
        });
      });
    } else {
      // Pas de routines disponibles
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune routine disponible')),
      );
    }
  },
  backgroundColor: AppTheme.primaryColor,
  child: const Icon(Icons.fitness_center),
),
      // Ajout d'un drawer
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
                'Thomas Martin',
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
                  'T',
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
            
            // Paramètres et déconnexion
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Paramètres (à venir)')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Déconnexion (à venir)')),
                );
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
          setState(() {
            _loadRoutines();
          });
        });
      },
    );
  }
}