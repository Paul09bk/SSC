import 'package:flutter/material.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/models/user.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminCreateRoutineScreen extends StatefulWidget {
  const AdminCreateRoutineScreen({super.key});

  @override
  State<AdminCreateRoutineScreen> createState() => _AdminCreateRoutineScreenState();
}

class _AdminCreateRoutineScreenState extends State<AdminCreateRoutineScreen> {
  // Données utilisateur (à remplacer par des données Firebase)
  final List<AppUser> _users = [
    AppUser(
      id: 'user1',
      name: 'Magalie Dumont',
      email: 'magalie@example.com',
      trainingScore: 75,
      objectives: 3,
      totalObjectives: 5,
    ),
    AppUser(
      id: 'user2',
      name: 'Thomas Martin',
      email: 'thomas@example.com',
      trainingScore: 60,
      objectives: 2,
      totalObjectives: 4,
    ),
    AppUser(
      id: 'user3',
      name: 'Sophie Leclerc',
      email: 'sophie@example.com',
      trainingScore: 85,
      objectives: 4,
      totalObjectives: 5,
    ),
  ];

  // Liste des exercices disponibles
  final List<String> _availableExercises = [
    'Pompes',
    'Burpees',
    'Squats',
    'Abdominaux',
    'Fentes',
    'Mountain Climbers',
    'Jumping Jacks',
    'Planche',
  ];

  // Exercices de la semaine précédente
  final Map<String, String> _lastWeekExercises = {
    'user1': 'Burpees',
    'user2': 'Pompes',
    'user3': 'Squats',
  };

  // Valeurs sélectionnées
  AppUser? _selectedUser;
  String? _selectedExercise;
  int _selectedWeek = 0;
  
  // Informations sur les semaines
  final DateTime _today = DateTime.now();
  late List<Map<String, dynamic>> _weeks;
  
  // Contrôleurs de formulaire
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _descriptionController = TextEditingController();
  
  // Dates sélectionnées
  final List<DateTime> _selectedDates = [];
  
  @override
  void initState() {
    super.initState();
    _selectedUser = _users.first;
    _selectedExercise = _availableExercises.first;
    _initializeWeeks();
    _updateDescriptionFromFields();
  }
  
  // Initialise les données des semaines
  void _initializeWeeks() {
    // Trouve le premier jour de la semaine (lundi)
    final today = _today;
    final firstDayOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    // Génère les informations pour 3 semaines (semaine précédente, courante, et prochaine)
    _weeks = List.generate(3, (index) {
      final weekNumber = firstDayOfWeek
          .add(Duration(days: 7 * (index - 1)))
          .difference(DateTime(today.year, 1, 1))
          .inDays ~/ 7 + 1;
      
      final weekStart = firstDayOfWeek.add(Duration(days: 7 * (index - 1)));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      return {
        'index': index - 1, // -1 = semaine précédente, 0 = courante, 1 = prochaine
        'number': weekNumber,
        'start': weekStart,
        'end': weekEnd,
        'label': index == 0
            ? 'Semaine précédente'
            : index == 1
                ? 'Semaine courante'
                : 'Semaine prochaine',
      };
    });
  }
  
  // Met à jour la description en fonction des valeurs des champs
  void _updateDescriptionFromFields() {
    if (_selectedExercise != null) {
      final sets = _setsController.text;
      final reps = _repsController.text;
      _descriptionController.text = '$sets séries de $reps $_selectedExercise';
    }
  }
  
  // Vérifie si une date est déjà sélectionnée
  bool _isDateSelected(DateTime date) {
    return _selectedDates.any((selectedDate) =>
        selectedDate.year == date.year &&
        selectedDate.month == date.month &&
        selectedDate.day == date.day);
  }
  
  // Toggle la sélection d'une date
  void _toggleDateSelection(DateTime date) {
    setState(() {
      if (_isDateSelected(date)) {
        _selectedDates.removeWhere((selectedDate) =>
            selectedDate.year == date.year &&
            selectedDate.month == date.month &&
            selectedDate.day == date.day);
      } else {
        _selectedDates.add(date);
      }
    });
  }
  
  // Crée les routines pour l'utilisateur
  void _createRoutines() {
    if (_formKey.currentState!.validate() && _selectedDates.isNotEmpty) {
      final List<Routine> routines = [];
      
      // Crée une routine pour chaque date sélectionnée
      for (final date in _selectedDates) {
        final routine = Routine(
          id: DateTime.now().millisecondsSinceEpoch.toString() + date.day.toString(),
          name: _selectedExercise!,
          description: _descriptionController.text,
          userId: _selectedUser!.id,
          assignedDate: date,
        );
        
        routines.add(routine);
      }
      
      // TODO: Sauvegarder les routines dans Firebase
      
      // Affiche un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${routines.length} routine(s) créée(s) pour ${_selectedUser!.name}',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // Réinitialise le formulaire
      setState(() {
        _selectedDates.clear();
      });
    } else if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une date'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer des routines'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // En-tête avec informations sur la semaine
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  const Text(
                    'Créer des routines hebdomadaires',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sélection de l'utilisateur
                  Row(
                    children: [
                      const Text(
                        'Pour qui ?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<AppUser>(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black45,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedUser,
                          items: _users.map((user) {
                            return DropdownMenuItem<AppUser>(
                              value: user,
                              child: Text(user.name),
                            );
                          }).toList(),
                          onChanged: (user) {
                            setState(() {
                              _selectedUser = user;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un utilisateur';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sélection de la semaine
                  Row(
                    children: [
                      const Text(
                        'Pour quand ?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black45,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedWeek,
                          items: _weeks.map((week) {
                            return DropdownMenuItem<int>(
                              value: week['index'],
                              child: Text(
                                '${week['label']} (${week['number']}ème)',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWeek = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sélection de l'exercice
                  Row(
                    children: [
                      const Text(
                        'Quoi ?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black45,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedExercise,
                          items: _availableExercises.map((exercise) {
                            return DropdownMenuItem<String>(
                              value: exercise,
                              child: Text(exercise),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedExercise = value;
                              _updateDescriptionFromFields();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un exercice';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  if (_selectedUser != null && _lastWeekExercises.containsKey(_selectedUser!.id))
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'La semaine dernière: ${_lastWeekExercises[_selectedUser!.id]}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Configuration des séries et répétitions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Séries et répétitions
                  Row(
                    children: [
                      // Séries
                      Expanded(
                        child: TextFormField(
                          controller: _setsController,
                          decoration: const InputDecoration(
                            labelText: 'Séries',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateDescriptionFromFields(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Nombre valide';
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Répétitions
                      Expanded(
                        child: TextFormField(
                          controller: _repsController,
                          decoration: const InputDecoration(
                            labelText: 'Répétitions',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _updateDescriptionFromFields(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requis';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Nombre valide';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description complète
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            
            // Sélection des jours
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sélectionnez les jours',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Grille des jours de la semaine
                  _buildDaySelector(),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Bouton de création
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createRoutines,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Créer les routines',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construit le sélecteur de jours
  Widget _buildDaySelector() {
    // Calcule les dates de la semaine sélectionnée
    final selectedWeekData = _weeks.firstWhere(
      (week) => week['index'] == _selectedWeek,
    );
    
    final weekStart = selectedWeekData['start'] as DateTime;
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = weekDays[index];
        final isSelected = _isDateSelected(day);
        final dayName = DateFormat('E', 'fr_FR').format(day);
        final dayNumber = day.day.toString();
        
        return InkWell(
          onTap: () => _toggleDateSelection(day),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey[700]!,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  dayNumber,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}