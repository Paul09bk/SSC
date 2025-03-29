class AppUser {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;
  final int trainingScore;
  final int objectives;
  final int totalObjectives;
  final String tamagotchiLevel;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.trainingScore = 0,
    this.objectives = 0,
    this.totalObjectives = 0,
    this.tamagotchiLevel = 'beginner',
  });

  // Convertir un utilisateur en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'trainingScore': trainingScore,
      'objectives': objectives,
      'totalObjectives': totalObjectives,
      'tamagotchiLevel': tamagotchiLevel,
    };
  }

  // Créer un utilisateur à partir d'un document Firestore
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      trainingScore: map['trainingScore'] ?? 0,
      objectives: map['objectives'] ?? 0,
      totalObjectives: map['totalObjectives'] ?? 0,
      tamagotchiLevel: map['tamagotchiLevel'] ?? 'beginner',
    );
  }
}