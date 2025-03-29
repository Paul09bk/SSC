import 'package:flutter/material.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:flutter_ssc/screens/user/weekly_routines_screen.dart';
import 'package:flutter_ssc/screens/user/class_booking_screen.dart';
import 'package:flutter_ssc/screens/user/routine_validation_screen.dart';
import 'package:flutter_ssc/models/routine.dart';

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
        // Laisser Flutter gérer automatiquement l'icône hamburger
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
      // Implémentation d'un drawer local
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Déconnexion (à venir)')),
                );
              },
            ),
          ],
        ),
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
                // Créer une routine de démonstration 
                final routine = Routine(
                  id: 'demo-routine-1',
                  name: 'Routine d\'entraînement',
                  description: '3 séries de 10 exercices',
                  userId: 'user123',
                  assignedDate: DateTime.now(),
                );
                
                // Navigation vers l'écran de validation
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutineValidationScreen(routine: routine),
                  ),
                );
              },
              child: const Text(
                'Commencer ma routine',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}