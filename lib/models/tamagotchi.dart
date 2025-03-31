// lib/models/tamagotchi.dart
class Tamagotchi {
  // Niveaux disponibles
  static const List<String> levels = [
    'beginner',  // Niveau débutant
    'novice',    // Niveau novice
    'apprentice', // Niveau apprenti
    'intermediate', // Niveau intermédiaire
    'advanced',  // Niveau avancé
    'expert',    // Niveau expert
    'master'     // Niveau maître
  ];

  String level;
  int experience;
  int maxExperience;
  String mood; // 'happy', 'neutral', 'tired'
  DateTime lastInteraction;

  Tamagotchi({
    this.level = 'beginner',
    this.experience = 0,
    this.maxExperience = 100,
    this.mood = 'neutral',
    DateTime? lastInteraction,
  }) : lastInteraction = lastInteraction ?? DateTime.now();

  // Calculer le pourcentage d'expérience actuel
  double get experiencePercentage => experience / maxExperience;

  // Obtenir l'index du niveau actuel
  int get levelIndex => levels.indexOf(level);

  // Vérifier si le tamagotchi peut monter de niveau
  bool get canLevelUp => experience >= maxExperience && levelIndex < levels.length - 1;

  // Ajouter de l'expérience et gérer l'évolution si nécessaire
  void addExperience(int amount) {
    experience += amount;
    
    // Si assez d'expérience pour monter de niveau
    if (canLevelUp) {
      // Passer au niveau suivant
      level = levels[levelIndex + 1];
      // Réinitialiser l'expérience et augmenter le maximum
      experience = 0;
      maxExperience = (maxExperience * 1.5).round();
      // Changer l'humeur en 'happy'
      mood = 'happy';
    }
    
    // Mettre à jour la date de dernière interaction
    lastInteraction = DateTime.now();
  }

  // Mettre à jour l'humeur en fonction du temps écoulé
  void updateMood() {
    final now = DateTime.now();
    final difference = now.difference(lastInteraction);
    
    // Si plus de 3 jours sans interaction
    if (difference.inDays >= 3) {
      mood = 'tired';
    } 
    // Si plus de 1 jour sans interaction
    else if (difference.inDays >= 1) {
      mood = 'neutral';
    }
  }
}