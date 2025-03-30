import 'package:flutter/material.dart';
import 'package:flutter_ssc/screens/auth/register_screen.dart';
import 'package:flutter_ssc/services/firebase_service.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ssc/screens/auth/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showRegisterScreen = false;
  
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Méthode de connexion
  Future<void> _login() async {
    // Validation du formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Appel au service d'authentification Firebase
      await _firebaseService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // L'utilisateur sera redirigé automatiquement via l'AuthWrapper
    } catch (e) {
      // Gestion des erreurs d'authentification
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              _errorMessage = 'Aucun utilisateur trouvé avec cet email';
              break;
            case 'wrong-password':
              _errorMessage = 'Mot de passe incorrect';
              break;
            case 'invalid-credential':
              _errorMessage = 'Identifiants invalides';
              break;
            case 'user-disabled':
              _errorMessage = 'Ce compte a été désactivé';
              break;
            default:
              _errorMessage = 'Erreur de connexion: ${e.message}';
          }
        } else {
          _errorMessage = 'Une erreur s\'est produite lors de la connexion';
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affiche l'écran d'inscription si demandé
    if (_showRegisterScreen) {
      return RegisterScreen(
        onLoginInstead: () => setState(() => _showRegisterScreen = false),
      );
    }
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
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
                
                // Message d'erreur
                if (_errorMessage.isNotEmpty) 
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(244, 67, 54, 0.1), // Rouge avec opacité 0.1
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                // Formulaire de connexion
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                
                // Bouton de connexion principal
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: const Color.fromRGBO(61, 90, 254, 0.5), // Couleur primaire avec opacité 0.5
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'CONNEXION',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bouton de connexion en tant qu'admin (pour démo seulement)
                // À supprimer en production
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      _emailController.text = 'coach@ssc.com';
                      _passwordController.text = 'coach123';
                      _login();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: const Color.fromRGBO(255, 214, 0, 0.5), // Couleur d'accent avec opacité 0.5
                    ),
                    child: const Text(
                      'DÉMO COACH',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Lien d'inscription
                TextButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _showRegisterScreen = true;
                    });
                  },
                  child: const Text('Pas encore inscrit ? Créer un compte'),
                ),
                
                // Lien mot de passe oublié
                TextButton(
  onPressed: _isLoading ? null : () {
    // Navigation vers l'écran de récupération de mot de passe
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordScreen(
          onBackToLogin: () => Navigator.pop(context),
        ),
      ),
    );
  },
  child: const Text('Mot de passe oublié ?'),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}