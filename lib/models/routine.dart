class Routine {
  final String id;
  final String name;
  final String description;
  final String userId;
  final DateTime assignedDate;
  final bool isCompleted;

  Routine({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.assignedDate,
    this.isCompleted = false,
  });

  // Convertir une routine en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'assignedDate': assignedDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Créer une routine à partir d'un document Firestore
  factory Routine.fromMap(Map<String, dynamic> map, String id) {
    return Routine(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      assignedDate: DateTime.parse(map['assignedDate']),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}