import 'package:flutter/material.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

class RoutineValidationScreen extends StatefulWidget {
  final Routine routine;
  
  const RoutineValidationScreen({
    super.key, 
    required this.routine,
  });

  @override
  State<RoutineValidationScreen> createState() => _RoutineValidationScreenState();
}

class _RoutineValidationScreenState extends State<RoutineValidationScreen> with SingleTickerProviderStateMixin {
  // Contrôleur d'animation pour les transitions
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  // États internes
  bool _isPaused = false;
  bool _isCompleted = false;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  
  // Décomposition fictive de la routine (à remplacer par des données réelles)
  late List<Map<String, dynamic>> _exercises;
  late int _totalSets;
  late int _completedSets;
  
  @override
  void initState() {
    super.initState();
    
    // Initialisation des exercices basés sur la description de la routine
    _parseRoutineDescription();
    
    // Configuration de l'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    // Mise à jour du compteur de séries
    _updateSetCounters();
  }
  
  // Analyse la description de la routine pour extraire les exercices et séries
  void _parseRoutineDescription() {
    // Exemple : "3 séries de 10 pompes" -> 3 séries, 10 répétitions, exercice "pompes"
    // Ceci est une implémentation simplifiée, à adapter selon votre format réel
    
    // Dans un cas réel, utilisez une logique de parsing plus robuste
    // Pour cet exemple, on utilise des données fictives structurées
    
    // Format fictif: définir les exercices de cette routine
    _exercises = [
      {
        'name': widget.routine.name,
        'sets': 3,
        'reps': 10,
        'restBetweenSets': 60, // repos en secondes
      }
    ];
  }
  
  // Calcule le nombre total de séries et mises à jour des compteurs
  void _updateSetCounters() {
    _totalSets = _exercises.fold(0, (sum, exercise) => sum + (exercise['sets'] as int));
    _completedSets = _currentExerciseIndex * (_exercises[0]['sets'] as int) + _currentSetIndex;    
    // Mise à jour de l'animation de progression
    _animationController.value = _completedSets / _totalSets;
  }
  
  // Marque la série actuelle comme terminée et passe à la suivante
  void _completeSet() {
    if (_isCompleted) return;
    
    setState(() {
      // Incrémente l'index de série
      _currentSetIndex++;
      
      // Si toutes les séries de l'exercice actuel sont terminées, passe à l'exercice suivant
      if (_currentSetIndex >= _exercises[_currentExerciseIndex]['sets']) {
        _currentSetIndex = 0;
        _currentExerciseIndex++;
        
        // Si tous les exercices sont terminés, marque la routine comme complétée
        if (_currentExerciseIndex >= _exercises.length) {
          _isCompleted = true;
          // TODO: Mettre à jour le statut de la routine dans Firebase
        }
      }
      
      // Mise à jour des compteurs
      _updateSetCounters();
    });
  }
  
  // Toggle la pause de l'entraînement
  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }
  
  // Afficher le dialogue de confirmation pour quitter
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Tu ne vas pas partir maintenant ?'),
        content: const Text('Ta progression ne sera pas sauvegardée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'On y retourne',
              style: TextStyle(color: AppTheme.accentColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme le dialogue
              Navigator.pop(context); // Retourne à l'écran précédent
            },
            child: const Text(
              'J\'abandonne...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: _isCompleted,
    onPopInvokedWithResult: (bool didPop, dynamic result) {
      if (!didPop) {
        _showExitConfirmation();
      }
    },
    child: Scaffold(
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
        body: _isCompleted 
            ? _buildCompletionScreen() 
            : _buildTrainingScreen(),
      ),
    );
  }
  
  // Écran d'entraînement en cours
  Widget _buildTrainingScreen() {
    final currentExercise = _exercises[_currentExerciseIndex];
    
    return Column(
      children: [
        // Barre de progression animée
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            );
          },
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar/Animation fictive de l'exercice
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      _isPaused ? Icons.pause : Icons.sports_martial_arts,
                      size: 100,
                      color: _isPaused ? Colors.grey : AppTheme.accentColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Information sur l'exercice actuel
                Text(
                  currentExercise['name'],
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Compteur de séries et répétitions
                Text(
                  'Série ${_currentSetIndex + 1}/${currentExercise['sets']} · ${currentExercise['reps']} répétitions',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Badge multiplicateur (comme dans la maquette)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'x3',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Progression globale
                Text(
                  'Progression totale: $_completedSets/$_totalSets séries',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                
                const Spacer(),
                
                // Boutons de contrôle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton Pause
                    ElevatedButton.icon(
                      onPressed: _togglePause,
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(_isPaused ? 'Reprendre' : 'Pause'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                    
                    // Bouton Suivant
                    ElevatedButton.icon(
                      onPressed: _completeSet,
                      icon: const Icon(Icons.check),
                      label: const Text('Terminé'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Écran de complétion quand la routine est terminée
  Widget _buildCompletionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône de succès
          const Icon(
            Icons.check_circle_outline,
            size: 120,
            color: AppTheme.successColor,
          ),
          
          const SizedBox(height: 24),
          
          // Message de félicitations
          Text(
            'Entraînement terminé !',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          
          const SizedBox(height: 8),
          
          // Détails
          Text(
            'Tu as complété ${widget.routine.name}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Information Tamagotchi
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: Colors.black,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ton Tamagotchi a gagné des points !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '+15 points d\'expérience',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Bouton Retour
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Retour à mes routines'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}