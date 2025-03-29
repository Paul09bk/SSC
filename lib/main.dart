import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ssc/models/user.dart';
import 'package:flutter_ssc/navigation/app_navigation.dart';
import 'package:flutter_ssc/screens/auth/login_screen.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
// Import Firebase gardé en commentaire jusqu'à ce qu'il soit utilisé
// import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

// Fichier fictif à créer pour la configuration de Firebase
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise le formattage des dates en français
  await initializeDateFormatting('fr_FR', null);
  
  // Force le mode portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // TODO: Décommenter après la configuration de Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunday Sport Club',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  // Méthode séparée pour éviter les erreurs de BuildContext à travers les gaps async
  void _loadApp() async {
    // Simule un temps de chargement pour le splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    // Vérifie si le widget est toujours monté avant d'utiliser context
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AuthWrapper(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo provisoire (à remplacer par le logo réel)
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'SSC',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'SUNDAY SPORT CLUB',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discipline et Progression',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}

// Wrapper qui vérifie l'état d'authentification
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Simulation de l'état de connexion (à remplacer par Firebase Auth)
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  AppUser? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  // Vérifie l'état d'authentification
  void _checkAuthState() async {
    // Simule un délai pour vérifier l'authentification
    await Future.delayed(const Duration(seconds: 1));
    
    // Pour la démo, on définit un utilisateur fictif
    // En réalité, c'est ici qu'on récupérerait les données de Firebase Auth
    if (mounted) {
      setState(() {
        _isAuthenticated = true;
        _isAdmin = false; // Changez à true pour tester l'interface admin
        _currentUser = AppUser(
          id: 'user123',
          name: 'Thomas Martin',
          email: 'thomas@example.com',
          isAdmin: _isAdmin,
          trainingScore: 75,
          objectives: 4,
          totalObjectives: 5,
        );
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un indicateur de chargement
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si l'utilisateur est authentifié, affiche l'application
    if (_isAuthenticated && _currentUser != null) {
      return AppNavigation(user: _currentUser!);
    }
    
    // Sinon, affiche l'écran de connexion
    return LoginScreen(onLogin: (user) {
      setState(() {
        _isAuthenticated = true;
        _currentUser = user;
      });
    });
  }
}