import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ssc/models/user.dart';
import 'package:flutter_ssc/navigation/app_navigation.dart';
import 'package:flutter_ssc/screens/auth/login_screen.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ssc/services/firebase_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:cloud_firestore/cloud_firestore.dart';

// Importez le fichier de configuration Firebase généré
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialise le formattage des dates en français
  await initializeDateFormatting('fr_FR', null);
  
  // Force le mode portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  

  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      print('Erreur de configuration de l\'émulateur Firebase: $e');
    }
  }
  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  // Vérifie l'état d'authentification avec Firebase
  void _checkAuthState() async {
    // Écoute les changements d'état d'authentification
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        // L'utilisateur n'est pas connecté
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentUser = null;
          });
        }
      } else {
        // L'utilisateur est connecté, récupérer ses données
        try {
          final appUser = await _firebaseService.getUserById(user.uid);
          
          if (mounted) {
            setState(() {
              _currentUser = appUser;
              _isLoading = false;
            });
          }
        } catch (e) {
          debugPrint('Erreur lors de la récupération des données utilisateur: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
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
    if (_currentUser != null) {
      return AppNavigation(user: _currentUser!);
    }
    
    // Sinon, affiche l'écran de connexion
    return const LoginScreen();
  }
}