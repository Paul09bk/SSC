import 'package:flutter/material.dart';
import 'package:flutter_ssc/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminScheduleScreen extends StatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  State<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends State<AdminScheduleScreen> {
  // Date sélectionnée
  DateTime _selectedDate = DateTime.now();
  
  // Créneau sélectionné
  String? _selectedTimeSlot;
  
  // Titre du cours
  final _titleController = TextEditingController();
  
  // Niveau du cours
  String _selectedLevel = 'Tous niveaux';
  final List<String> _levels = [
    'Débutant',
    'Intermédiaire',
    'Avancé',
    'Tous niveaux'
  ];
  
  // Nombre maximum de participants
  final _maxParticipantsController = TextEditingController(text: '10');
  
  // Durée du cours (en minutes)
  final _durationController = TextEditingController(text: '60');
  
  // Créneaux disponibles
  final List<String> _timeSlots = [
    '08:00-09:00',
    '09:00-10:00', 
    '10:00-11:00',
    '11:00-12:00',
    '14:00-15:00',
    '15:00-16:00',
    '16:00-17:00',
    '17:00-18:00',
    '18:00-19:00',
    '19:00-20:00',
  ];
  
  // Liste des créneaux créés (à remplacer par Firebase)
  final List<Map<String, dynamic>> _scheduledClasses = [];
  
  // Clé du formulaire pour la validation
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _selectedTimeSlot = _timeSlots.first;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _maxParticipantsController.dispose();
    _durationController.dispose();
    super.dispose();
  }
  
  // Formate une date pour l'affichage
  String _formatDate(DateTime date) {
    return DateFormat('E d MMM', 'fr_FR').format(date);
  }
  
  // Vérifie si un créneau existe déjà
  bool _doesSlotExist() {
    return _scheduledClasses.any((slot) {
      return slot['date'].year == _selectedDate.year &&
          slot['date'].month == _selectedDate.month &&
          slot['date'].day == _selectedDate.day &&
          slot['timeSlot'] == _selectedTimeSlot;
    });
  }
  
  // Ajoute un créneau au calendrier
  void _addTimeSlot() {
    if (_formKey.currentState!.validate()) {
      // Vérifie si le créneau n'existe pas déjà
      if (_doesSlotExist()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce créneau existe déjà'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      
      // Parse les heures de début et fin à partir du créneau
      final timeRange = _selectedTimeSlot!.split('-');
      final startTime = timeRange[0].split(':');
      
      // Crée l'objet date/heure pour le créneau
      final slotDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        int.parse(startTime[0]),
        int.parse(startTime[1]),
      );
      
      // Crée le créneau
      final newSlot = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _titleController.text,
        'date': slotDate,
        'timeSlot': _selectedTimeSlot,
        'level': _selectedLevel,
        'maxParticipants': int.parse(_maxParticipantsController.text),
        'duration': int.parse(_durationController.text),
        'participants': <String>[],
      };
      
      setState(() {
        _scheduledClasses.add(newSlot);
      });
      
      // Réinitialise le formulaire
      _titleController.clear();
      
      // Affiche un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Créneau ajouté avec succès'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      
      // TODO: Sauvegarder le créneau dans Firebase
    }
  }
  
  // Supprime un créneau du calendrier
  void _deleteTimeSlot(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Supprimer ce créneau ?'),
        content: const Text(
          'Cette action est irréversible et annulera toutes les réservations existantes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _scheduledClasses.removeWhere((slot) => slot['id'] == id);
              });
              Navigator.pop(context);
              
              // Affiche un message de confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Créneau supprimé'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              
              // TODO: Supprimer le créneau de Firebase
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
  
  // Obtient les créneaux pour une date spécifique
  List<Map<String, dynamic>> _getSlotsByDate(DateTime date) {
    return _scheduledClasses.where((slot) {
      final slotDate = slot['date'] as DateTime;
      return slotDate.year == date.year &&
          slotDate.month == date.month &&
          slotDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du calendrier'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Sélecteur de date
            _buildDateSelector(),
            
            // Formulaire d'ajout de créneau
            _buildAddSlotForm(),
            
            const Divider(height: 32),
            
            // En-tête liste des créneaux
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Créneaux du ${_formatDate(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_getSlotsByDate(_selectedDate).length} créneau(x)',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Liste des créneaux pour la date sélectionnée
            Expanded(
              child: _buildTimeSlotsList(),
            ),
          ],
        ),
      ),
    );
  }
  
  // Construit le sélecteur de date
  Widget _buildDateSelector() {
    final now = DateTime.now();
    // Génère 30 jours à partir d'aujourd'hui
    final days = List.generate(30, (index) {
      return now.add(Duration(days: index));
    });
    
    return Container(
      height: 120,
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Sélectionnez une date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day.year == _selectedDate.year &&
                    day.month == _selectedDate.month &&
                    day.day == _selectedDate.day;
                
                // Vérifie si des créneaux existent ce jour
                final hasSlots = _getSlotsByDate(day).isNotEmpty;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    width: 70,
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
                        : Color.fromRGBO(158, 158, 158, 0.3)  // Valeurs RGB pour Colors.grey                        width: 1,
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
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 4),
                        if (hasSlots)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.accentColor,
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
  
  // Construit le formulaire d'ajout de créneau
  Widget _buildAddSlotForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter un créneau',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Titre du cours
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre du cours',
              hintText: 'Ex: Kung-Fu débutant',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un titre';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Sélection du créneau et du niveau
          Row(
            children: [
              // Sélection du créneau horaire
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Créneau horaire',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedTimeSlot,
                  items: _timeSlots.map((slot) {
                    return DropdownMenuItem<String>(
                      value: slot,
                      child: Text(slot),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeSlot = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requis';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Niveau du cours
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Niveau',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLevel,
                  items: _levels.map((level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Participants max et durée
          Row(
            children: [
              // Nombre maximum de participants
              Expanded(
                child: TextFormField(
                  controller: _maxParticipantsController,
                  decoration: const InputDecoration(
                    labelText: 'Participants max',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requis';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Nombre valide';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Durée du cours
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Durée (min)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requis';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Nombre valide';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bouton d'ajout
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addTimeSlot,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter ce créneau'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Construit la liste des créneaux
  Widget _buildTimeSlotsList() {
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
              'Aucun créneau pour le ${_formatDate(_selectedDate)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: slotsForSelectedDate.length,
      itemBuilder: (context, index) {
        final slot = slotsForSelectedDate[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Créneau horaire et niveau
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
                        slot['timeSlot'] as String,
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
                    color : Color.fromRGBO(255, 235, 59, 1.0),  // Valeurs RGB pour Colors.yellow
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
                
                // Titre et durée
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        slot['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${slot['duration']} min',
                      style: TextStyle(
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Participants
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(slot['participants'] as List).length}/${slot['maxParticipants']} participants',
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    
                    // Bouton de suppression
                    IconButton(
                      onPressed: () => _deleteTimeSlot(slot['id'] as String),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Supprimer ce créneau',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}