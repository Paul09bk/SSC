import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

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
    return DateFormat('E d MMM', 'fr_FR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Mes routines de la semaine'),
  centerTitle: true,
  // Ajouter un bouton de retour
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
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
                  'Semaine du ${DateFormat('d MMM', 'fr_FR').format(_weekStartDate)}',
                  style: Theme.of(context).textTheme.displaySmall,
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
          // Navigation vers l'écran de validation des routines
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigation vers l\'écran de validation')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.fitness_center),
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
      trailing: Container(
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
      onTap: () {
        // Afficher les détails de la routine ou permettre de la valider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Détails de ${routine.name}')),
        );
      },
    );
  }
}