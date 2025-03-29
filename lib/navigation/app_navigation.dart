// Ce fichier doit être placé dans lib/navigation/app_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_ssc/models/user.dart';
import 'package:flutter_ssc/screens/user/tamagotchi_screen.dart';
import 'package:flutter_ssc/screens/user/weekly_routines_screen.dart';
import 'package:flutter_ssc/screens/user/class_booking_screen.dart';
import 'package:flutter_ssc/screens/admin/admin_create_routine_screen.dart';
import 'package:flutter_ssc/screens/admin/admin_schedule_screen.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

class AppNavigation extends StatelessWidget {
  final AppUser user;
  
  const AppNavigation({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        onGenerateRoute: (settings) {
          Widget page;
          
          // Navigation par défaut selon le type d'utilisateur
          if (settings.name == '/' || settings.name == null) {
            page = user.isAdmin 
                ? const AdminCreateRoutineScreen() 
                : const TamagotchiScreen();
          }
          // Routes utilisateur
          else if (settings.name == '/tamagotchi') {
            page = const TamagotchiScreen();
          }
          else if (settings.name == '/routines') {
            page = const WeeklyRoutinesScreen();
          }
          else if (settings.name == '/booking') {
            page = const ClassBookingScreen();
          } 
          // Routes admin
          else if (settings.name == '/admin/routines') {
            page = const AdminCreateRoutineScreen();
          }
          else if (settings.name == '/admin/schedule') {
            page = const AdminScheduleScreen();
          } 
          // Fallback
          else {
            page = const TamagotchiScreen();
          }
          
          return MaterialPageRoute(
            builder: (_) => page,
            settings: settings,
          );
        },
      ),
      drawer: AppDrawer(user: user),
    );
  }
}

class AppDrawer extends StatelessWidget {
  final AppUser user;
  
  const AppDrawer({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: Column(
        children: [
          // En-tête du drawer avec les infos utilisateur
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppTheme.accentColor,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            accountName: Text(
              user.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              user.isAdmin ? 'Coach' : 'Membre',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          // Menu utilisateur
          if (!user.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.pets, color: AppTheme.accentColor),
              title: const Text('Mon Tamagotchi'),
              onTap: () {
                // Ferme le drawer
                Navigator.pop(context);
                
                // Navigue vers la page en utilisant le Navigator interne
                final navigator = Navigator.of(context, rootNavigator: false);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const TamagotchiScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.white),
              title: const Text('Mes routines'),
              onTap: () {
                // Ferme le drawer
                Navigator.pop(context);
                
                // Navigue vers la page en utilisant le Navigator interne
                final navigator = Navigator.of(context, rootNavigator: false);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const WeeklyRoutinesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.white),
              title: const Text('Réserver un cours'),
              onTap: () {
                // Ferme le drawer
                Navigator.pop(context);
                
                // Navigue vers la page en utilisant le Navigator interne
                final navigator = Navigator.of(context, rootNavigator: false);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const ClassBookingScreen()),
                );
              },
            ),
          ],
          
          // Menu admin
          if (user.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.white),
              title: const Text('Créer des routines'),
              onTap: () {
                // Ferme le drawer
                Navigator.pop(context);
                
                // Navigue vers la page en utilisant le Navigator interne
                final navigator = Navigator.of(context, rootNavigator: false);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminCreateRoutineScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.white),
              title: const Text('Gestion du calendrier'),
              onTap: () {
                // Ferme le drawer
                Navigator.pop(context);
                
                // Navigue vers la page en utilisant le Navigator interne
                final navigator = Navigator.of(context, rootNavigator: false);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminScheduleScreen()),
                );
              },
            ),
          ],
          
          const Divider(color: Colors.grey),
          
          // Paramètres et déconnexion (pour tous les utilisateurs)
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implémenter la page des paramètres
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
              // TODO: Implémenter la logique de déconnexion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Déconnexion (à venir)')),
              );
            },
          ),
          
          const Spacer(),
          
          // Footer avec version
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Sunday Sport Club v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}