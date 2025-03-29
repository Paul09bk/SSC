import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

class ClassBookingScreen extends StatefulWidget {
  const ClassBookingScreen({super.key});

  @override
  State<ClassBookingScreen> createState() => _ClassBookingScreenState();
}

class _ClassBookingScreenState extends State<ClassBookingScreen> {
  // La date sélectionnée dans le calendrier
  DateTime _selectedDate = DateTime.now();
  
  // La liste des créneaux disponibles (à remplacer par des données réelles)
  final List<Map<String, dynamic>> _availableSlots = [
    {
      'id': '1',
      'date': DateTime.now().add(const Duration(days: 1, hours: 10)),
      'duration': 60, // minutes
      'title': 'Cours collectif Kung-Fu',
      'coach': 'Maître Lee',
      'maxParticipants': 10,
      'currentParticipants': 6,
      'level': 'Tous niveaux',
      'isBooked': false,
    },
    {
      'id': '2',
      'date': DateTime.now().add(const Duration(days: 1, hours: 14)),
      'duration': 45, // minutes
      'title': 'Taekwondo avancé',
      'coach': 'Sophia Chen',
      'maxParticipants': 8,
      'currentParticipants': 7,
      'level': 'Avancé',
      'isBooked': true,
    },
    {
      'id': '3',
      'date': DateTime.now().add(const Duration(days: 2, hours: 9)),
      'duration': 90, // minutes
      'title': 'Karaté débutant',
      'coach': 'Marc Dupont',
      'maxParticipants': 12,
      'currentParticipants': 3,
      'level': 'Débutant',
      'isBooked': false,
    },
    {
      'id': '4',
      'date': DateTime.now().add(const Duration(days: 3, hours: 18)),
      'duration': 60, // minutes
      'title': 'Boxe thaï',
      'coach': 'Sophie Martin',
      'maxParticipants': 10,
      'currentParticipants': 9,
      'level': 'Intermédiaire',
      'isBooked': false,
    },
    {
      'id': '5',
      'date': DateTime.now().add(const Duration(days: 4, hours: 11)),
      'duration': 75, // minutes
      'title': 'Jiu-jitsu brésilien',
      'coach': 'Carlos Silva',
      'maxParticipants': 8,
      'currentParticipants': 4,
      'level': 'Tous niveaux',
      'isBooked': false,
    },
  ];

  // Filtrer les créneaux par date
  List<Map<String, dynamic>> _getSlotsByDate(DateTime date) {
    return _availableSlots.where((slot) {
      final slotDate = slot['date'] as DateTime;
      return slotDate.year == date.year &&
          slotDate.month == date.month &&
          slotDate.day == date.day;
    }).toList();
  }

  // Formater l'heure au format 24h
  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  // Réserver ou annuler un créneau
  void _toggleBooking(String slotId) {
    setState(() {
      final index = _availableSlots.indexWhere((slot) => slot['id'] == slotId);
      if (index != -1) {
        final slot = _availableSlots[index];
        
        // Vérifie si on peut réserver (pas complet)
        if (!slot['isBooked'] && 
            slot['currentParticipants'] < slot['maxParticipants']) {
          // Réserve le créneau
          slot['isBooked'] = true;
          slot['currentParticipants']++;
          
          // Affiche un message de confirmation
          _showBookingConfirmation(true, slot['title']);
          
          // TODO: Mettre à jour la réservation dans Firebase
        } else if (slot['isBooked']) {
          // Annule la réservation
          slot['isBooked'] = false;
          slot['currentParticipants']--;
          
          // Affiche un message de confirmation
          _showBookingConfirmation(false, slot['title']);
          
          // TODO: Mettre à jour la réservation dans Firebase
        }
      }
    });
  }

  // Affiche une notification de confirmation
  void _showBookingConfirmation(bool isBooked, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBooked
              ? 'Vous avez réservé "$title"'
              : 'Réservation annulée pour "$title"',
        ),
        backgroundColor: isBooked ? AppTheme.successColor : Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text('Mes routines de la semaine'),
  centerTitle: true,
  // Ajouter un bouton de retour
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.of(context).pop();
    },
  ),
),
      body: Column(
        children: [
          // Calendrier simplifié (à remplacer par un calendrier plus complet si nécessaire)
          _buildCalendar(),
          
          // Liste des créneaux disponibles
          Expanded(
            child: _buildSlotsList(),
          ),
        ],
      ),
    );
  }

  // Construit le widget de calendrier
  Widget _buildCalendar() {
    final now = DateTime.now();
    
    // Génère 14 jours à partir d'aujourd'hui
    final days = List.generate(14, (index) {
      return now.add(Duration(days: index));
    });

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Sélectionnez une date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                
                // Vérifie si des créneaux sont disponibles ce jour
                final hasSlots = _getSlotsByDate(day).isNotEmpty;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: EdgeInsets.only(
                      left: index == 0 ? 16 : 8,
                      right: index == days.length - 1 ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            :  Color.fromRGBO(158, 158, 158, 0.3)  // Valeurs RGB pour Colors.grey                  width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E', 'fr_FR').format(day).toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasSlots
                                ? isSelected 
                                    ? Colors.white 
                                    : AppTheme.accentColor
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Construit la liste des créneaux disponibles
  Widget _buildSlotsList() {
    final slotsForSelectedDate = _getSlotsByDate(_selectedDate);
    
    if (slotsForSelectedDate.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.event_busy,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun cours disponible le ${DateFormat('dd MMMM', 'fr_FR').format(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez sélectionner une autre date',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slotsForSelectedDate.length,
      itemBuilder: (context, index) {
        final slot = slotsForSelectedDate[index];
        final startTime = slot['date'] as DateTime;
        final endTime = startTime.add(Duration(minutes: slot['duration'] as int));
        final isFull = slot['currentParticipants'] >= slot['maxParticipants'];
        final isBooked = slot['isBooked'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppTheme.cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isBooked
                ? BorderSide(color: AppTheme.primaryColor, width: 2)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horaire et niveau
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(33, 150, 243, 1.0),  // Valeurs RGB pour Colors.blue
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(33, 150, 243, 1.0),  // Valeurs RGB pour Colors.blue
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        slot['level'] as String,
                        style: const TextStyle(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Titre du cours
                Text(
                  slot['title'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Coach
                Text(
                  'Coach: ${slot['coach']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Participants
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${slot['currentParticipants']}/${slot['maxParticipants']} participants',
                      style: TextStyle(
                        fontSize: 14,
                        color: isFull ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                    
                    // Indicateur "Complet" si nécessaire
                    if (isFull) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'COMPLET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bouton de réservation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFull && !isBooked
                        ? null // Désactivé si complet et non réservé
                        : () => _toggleBooking(slot['id'] as String),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBooked
                          ? Colors.redAccent
                          : AppTheme.successColor,
                      disabledBackgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isBooked ? 'Annuler la réservation' : 'Réserver',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}