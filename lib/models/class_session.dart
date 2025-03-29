import 'package:cloud_firestore/cloud_firestore.dart';

class ClassSession {
  final String id;
  final String title;
  final DateTime date;
  final int duration; // en minutes
  final String coachId;
  final String coachName;
  final String level; // débutant, intermédiaire, avancé, tous niveaux
  final int maxParticipants;
  final List<String> participantIds;

  ClassSession({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.coachId,
    required this.coachName,
    required this.level,
    required this.maxParticipants,
    this.participantIds = const [],
  });

  // Vérifie si la classe est complète
  bool get isFull => participantIds.length >= maxParticipants;

  // Vérifie si un utilisateur est inscrit
  bool isUserRegistered(String userId) {
    return participantIds.contains(userId);
  }

  // Convertir une session de cours en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'duration': duration,
      'coachId': coachId,
      'coachName': coachName,
      'level': level,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
    };
  }

  // Créer une session de cours à partir d'un document Firestore
  factory ClassSession.fromMap(Map<String, dynamic> map, String id) {
    return ClassSession(
      id: id,
      title: map['title'] ?? '',
      date: DateTime.parse(map['date']),
      duration: map['duration'] ?? 60,
      coachId: map['coachId'] ?? '',
      coachName: map['coachName'] ?? '',
      level: map['level'] ?? 'Tous niveaux',
      maxParticipants: map['maxParticipants'] ?? 10,
      participantIds: List<String>.from(map['participantIds'] ?? []),
    );
  }

  // Créer une session de cours à partir d'un document Firestore avec conversion automatique de Timestamp
  factory ClassSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Conversion du Timestamp Firestore en DateTime si nécessaire
    DateTime date;
    if (data['date'] is Timestamp) {
      date = (data['date'] as Timestamp).toDate();
    } else {
      date = DateTime.parse(data['date']);
    }
    
    return ClassSession(
      id: doc.id,
      title: data['title'] ?? '',
      date: date,
      duration: data['duration'] ?? 60,
      coachId: data['coachId'] ?? '',
      coachName: data['coachName'] ?? '',
      level: data['level'] ?? 'Tous niveaux',
      maxParticipants: data['maxParticipants'] ?? 10,
      participantIds: List<String>.from(data['participantIds'] ?? []),
    );
  }

  // Calculer l'heure de fin de la classe
  DateTime get endTime => date.add(Duration(minutes: duration));

  // Formatter l'heure de début et de fin pour l'affichage
  String get timeRange {
    final startHour = date.hour.toString().padLeft(2, '0');
    final startMinute = date.minute.toString().padLeft(2, '0');
    
    final end = endTime;
    final endHour = end.hour.toString().padLeft(2, '0');
    final endMinute = end.minute.toString().padLeft(2, '0');
    
    return '$startHour:$startMinute-$endHour:$endMinute';
  }
}