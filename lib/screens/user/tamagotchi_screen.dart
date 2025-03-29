import 'package:flutter/material.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:flutter_ssc/screens/user/weekly_routines_screen.dart';
import 'package:flutter_ssc/screens/user/class_booking_screen.dart';

class TamagotchiScreen extends StatefulWidget {
  const TamagotchiScreen({super.key});

  @override
  State<TamagotchiScreen> createState() => _TamagotchiScreenState();
}

class _TamagotchiScreenState extends State<TamagotchiScreen> {
  int trainingScore = 75; // Score d'exemple
  int objectives = 4; // Nombre d'objectifs atteints
  int totalObjectives = 5; // Nombre total d'objectifs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunday Sport Club'),
        // Ne pas définir de leading personnalisé
        // Flutter affichera automatiquement l'icône hamburger pour le drawer
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
            icon: const Icon(Icons.list),
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
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder pour l'avatar Tamagotchi
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sports_martial_arts,
                        size: 100,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Indicateurs de performance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Score d'entraînement
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.successColor,
                        ),
                        child: Center(
                          child: Text(
                            '$trainingScore/100',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Indicateur d'objectifs
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentColor,
                        ),
                        child: Center(
                          child: Text(
                            '$objectives/$totalObjectives',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bouton d'action principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () {
                // Navigation vers l'écran de validation des routines
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Commencer ma routine')),
                );
                
                // Quand vous aurez créé l'écran de validation, vous pourrez utiliser cette navigation:
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const RoutineValidationScreen()),
                // );
              },
              child: const Text(
                'Commencer ma routine',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      // Ne pas définir de drawer ici, il est déjà défini dans AppNavigation
    );
  }
}