// lib/screens/user/tamagotchi_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_ssc/models/tamagotchi.dart';
import 'package:flutter_ssc/models/routine.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:flutter_ssc/widgets/tamagotchi_avatar.dart';
import 'package:flutter_ssc/screens/user/weekly_routines_screen.dart';
import 'package:flutter_ssc/screens/user/class_booking_screen.dart';
import 'package:flutter_ssc/screens/user/routine_validation_screen.dart';

class TamagotchiScreen extends StatefulWidget {
  const TamagotchiScreen({Key? key}) : super(key: key);

  @override
  State<TamagotchiScreen> createState() => _TamagotchiScreenState();
}

class _TamagotchiScreenState extends State<TamagotchiScreen> {
  int trainingScore = 75; // Score d'exemple
  int objectives = 4; // Nombre d'objectifs atteints
  int totalObjectives = 5; // Nombre total d'objectifs
  
  // Tamagotchi de l'utilisateur
  Tamagotchi? _tamagotchi;
  
  // État de chargement
  bool _isLoading = true;
  
  // Liste des routines d'exemple
  List<Routine> _routines = [];
  
  @override
  void initState() {
    super.initState();
    
    // Chargement des données au démarrage
    _loadData();
  }
  
  // Charger les données locales
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Créer un Tamagotchi fictif pour les tests
      _tamagotchi = Tamagotchi(
        level: 'beginner',
        experience: 50,
        maxExperience: 100,
        mood: 'happy',
        lastInteraction: DateTime.now(),
      );
      
      // Créer des routines d'exemple
      _routines = [
        Routine(
          id: '1',
          name: 'Pompes',
          description: '3 séries de 10 pompes',
          userId: 'user123',
          assignedDate: DateTime.now(),
          isCompleted: false,
        ),
        Routine(
          id: '2',
          name: 'Abdominaux',
          description: '3 séries de 15 abdominaux',
          userId: 'user123',
          assignedDate: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: true,
        ),
        Routine(
          id: '3',
          name: 'Étirements',
          description: '15 minutes d\'étirements',
          userId: 'user123',
          assignedDate: DateTime.now().subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
      ];
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Interagir avec le Tamagotchi
  void _interactWithTamagotchi() {
    if (_tamagotchi == null) return;
    
    setState(() {
      // Ajouter un peu d'expérience pour l'interaction
      _tamagotchi!.addExperience(5);
      
      // Mettre à jour l'humeur
      if (_tamagotchi!.mood != 'happy') {
        _tamagotchi!.mood = 'happy';
      }
    });
    
    // Feedback visuel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ton Tamagotchi est content ! +5 XP'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunday Sport Club'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Navigation vers l'écran de réservation
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ClassBookingScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.fitness_center),
            onPressed: () {
              // Navigation vers l'écran des routines
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeeklyRoutinesScreen()),
              );
            },
          ),
        ],
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.white),
              title: const Text('Mes routines'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeeklyRoutinesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text('Réserver un cours'),
              onTap: () {
                Navigator.pop(context); // Ferme le drawer
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
                // Ajouter la logique de déconnexion ici
              },
            ),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Tamagotchi
                      Center(
                        child: Column(
                          children: [
                            if (_tamagotchi != null)
                              TamagotchiAvatar(
                                tamagotchi: _tamagotchi!,
                                size: 220,
                                onTap: _interactWithTamagotchi,
                              )
                            else
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.sports_martial_arts,
                                    size: 100,
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 8),
                            
                            const Text(
                              'Appuie pour interagir',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Indicateurs de performance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Score d'entraînement
                          _buildPerformanceIndicator(
                            label: 'Score',
                            value: '$trainingScore/100',
                            color: AppTheme.successColor,
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Indicateur d'objectifs
                          _buildPerformanceIndicator(
                            label: 'Objectifs',
                            value: '$objectives/$totalObjectives',
                            color: AppTheme.accentColor,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Section routines récentes
                      if (_routines.isNotEmpty) ...[
                        const Text(
                          'Tes dernières routines',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        ..._routines.map((routine) => _buildRoutineItem(routine)),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Bouton d'action principal
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            // Utiliser la première routine non complétée
                            final incompleteRoutines = _routines
                                .where((routine) => !routine.isCompleted)
                                .toList();
                                
                            if (incompleteRoutines.isNotEmpty) {
                              // Naviguer vers l'écran de validation avec la première routine non complétée
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RoutineValidationScreen(
                                    routine: incompleteRoutines.first,
                                  ),
                                ),
                              ).then((_) {
                                // Rafraîchir les données après le retour
                                _loadData();
                              });
                            } else {
                              // Si toutes les routines sont complétées, afficher un message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Toutes tes routines sont complétées. Consulte l\'écran des routines pour en voir plus.',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'Commencer ma routine',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  // Widget pour les indicateurs de performance
  Widget _buildPerformanceIndicator({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Widget pour les éléments de routine récente
  Widget _buildRoutineItem(Routine routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardColor,
      child: ListTile(
        title: Text(
          routine.name,
          style: TextStyle(
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
          // Naviguer vers l'écran de validation pour cette routine
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoutineValidationScreen(routine: routine),
            ),
          ).then((_) {
            // Recharger les données après le retour
            _loadData();
          });
        },
      ),
    );
  }
}