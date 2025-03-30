import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:flutter_ssc/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClassBookingScreen extends StatefulWidget {
  const ClassBookingScreen({super.key});

  @override
  State<ClassBookingScreen> createState() => _ClassBookingScreenState();
}

class _ClassBookingScreenState extends State<ClassBookingScreen> {
  // La date sélectionnée dans le calendrier
  DateTime _selectedDate = DateTime.now();
  
  // La liste des créneaux disponibles
  List<Map<String, dynamic>> _availableSlots = [];
  
  // Indique si les données sont en cours de chargement
  bool _isLoading = true;
  
  // Service Firebase
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // Charge les créneaux de cours disponibles depuis Firebase
  Future<void> _loadClasses() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Récupère tous les cours disponibles
      final classes = await _firebaseService.getAvailableClasses();
      
      // Convertit les classes en format utilisable par l'interface
      final slots = classes.map((classSession) {
        // Vérifie si l'utilisateur actuel est inscrit à ce cours
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final isBooked = classSession.isUserRegistered(userId);
        
        return {
          'id': classSession.id,
          'date': classSession.date,
          'duration': classSession.duration,
          'title': classSession.title,
          'coach': classSession.coachName,
          'maxParticipants': classSession.maxParticipants,
          'currentParticipants': classSession.participantIds.length,
          'level': classSession.level,
          'isBooked': isBooked,
        };
      }).toList();
      
      if (mounted) {
        setState(() {
          _availableSlots = slots;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Affiche un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des cours: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

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
  Future<void> _toggleBooking(String slotId) async {
    final index = _availableSlots.indexWhere((slot) => slot['id'] == slotId);
    if (index == -1) return;
    
    final slot = _availableSlots[index];
    final userId = FirebaseAuth.instance.currentUser!.uid;
    
    // Affiche un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      bool success;
      
      if (!slot['isBooked']) {
        // Réserver le créneau
        if (slot['currentParticipants'] < slot['maxParticipants']) {
          // Appel au service Firebase pour réserver le créneau
          success = await _firebaseService.bookClass(slotId, userId);
          
          if (success) {
            // Mise à jour locale
            setState(() {
              slot['isBooked'] = true;
              slot['currentParticipants']++;
            });
            
            // Ferme l'indicateur de chargement
            if (mounted) Navigator.pop(context);
            
            // Affiche un message de confirmation
            _showBookingConfirmation(true, slot['title']);
          } else {
            // Ferme l'indicateur de chargement
            if (mounted) Navigator.pop(context);
            
            // Gestion de l'échec
            _showBookingError('Impossible de réserver ce créneau');
          }
        } else {
          // Créneau complet
          // Ferme l'indicateur de chargement
          if (mounted) Navigator.pop(context);
          
          _showBookingError('Ce créneau est complet');
        }
      } else {
        // Annuler la réservation
        // Appel au service Firebase pour annuler la réservation
        success = await _firebaseService.cancelBooking(slotId, userId);
        
        if (success) {
          // Mise à jour locale
          setState(() {
            slot['isBooked'] = false;
            slot['currentParticipants']--;
          });
          
          // Ferme l'indicateur de chargement
          if (mounted) Navigator.pop(context);
          
          // Affiche un message de confirmation
          _showBookingConfirmation(false, slot['title']);
        } else {
          // Ferme l'indicateur de chargement
          if (mounted) Navigator.pop(context);
          
          // Gestion de l'échec
          _showBookingError('Impossible d\'annuler cette réservation');
        }
      }
    } catch (e) {
      // Ferme l'indicateur de chargement
      if (mounted) Navigator.pop(context);
      
      // Gestion des erreurs
      _showBookingError('Erreur: $e');
    }
  }

  // Affiche une notification de confirmation
  void _showBookingConfirmation(bool isBooked, String title) {
    if (mounted) {
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
  }

  // Affiche un message d'erreur
  void _showBookingError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un cours'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Calendrier simplifié
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
                            : Color.fromRGBO(158, 158, 158, 0.3),
                        width: 1,
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
                        color: Color.fromRGBO(33, 150, 243, 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                        style: const TextStyle(
                          color: Colors.white,
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
                        color: Color.fromRGBO(255, 214, 0, 0.2),
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