import 'package:flutter/material.dart';
import 'package:flutter_ssc/models/user.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  final Function(AppUser) onLogin;
  
  const LoginScreen({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    // Pour la démo, on utilise un écran de connexion simplifié
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'SSC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'SUNDAY SPORT CLUB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 48),
              
              // Formulaire de connexion
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              
              // Boutons de connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pour la démo, connecte un utilisateur standard
                    onLogin(AppUser(
                      id: 'user123',
                      name: 'Thomas Martin',
                      email: 'thomas@example.com',
                      isAdmin: false,
                      trainingScore: 75,
                      objectives: 4,
                      totalObjectives: 5,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CONNEXION MEMBRE'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pour la démo, connecte un utilisateur admin
                    onLogin(AppUser(
                      id: 'admin123',
                      name: 'Sophie Leclerc',
                      email: 'sophie@example.com',
                      isAdmin: true,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('CONNEXION COACH'),
                ),
              ),
              const SizedBox(height: 24),
              
              // Lien d'inscription
              TextButton(
                onPressed: () {
                  // TODO: Implémenter l'écran d'inscription
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inscription (à venir)')),
                  );
                },
                child: const Text('Pas encore inscrit ? Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}