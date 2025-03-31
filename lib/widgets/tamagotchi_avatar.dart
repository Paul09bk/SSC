// lib/widgets/tamagotchi_avatar.dart
import 'package:flutter/material.dart';
import 'package:flutter_ssc/models/tamagotchi.dart';
import 'package:flutter_ssc/theme/app_theme.dart';

class TamagotchiAvatar extends StatefulWidget {
  final Tamagotchi tamagotchi;
  final double size;
  final bool animated;
  final VoidCallback? onTap;

  const TamagotchiAvatar({
    Key? key,
    required this.tamagotchi,
    this.size = 200,
    this.animated = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<TamagotchiAvatar> createState() => _TamagotchiAvatarState();
}

class _TamagotchiAvatarState extends State<TamagotchiAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Si l'animation est activée, initialiser le contrôleur
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat(reverse: true);
      
      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      
      _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  // Obtenir la couleur en fonction du niveau
  Color _getLevelColor() {
    switch (widget.tamagotchi.level) {
      case 'beginner':
        return Colors.green;
      case 'novice':
        return Colors.teal;
      case 'apprentice':
        return Colors.blue;
      case 'intermediate':
        return Colors.purple;
      case 'advanced':
        return Colors.orange;
      case 'expert':
        return Colors.red;
      case 'master':
        return Colors.amber;
      default:
        return AppTheme.primaryColor;
    }
  }

  // Obtenir l'image du Tamagotchi en fonction du niveau et de l'humeur
  String _getTamagotchiImagePath() {
    String level = widget.tamagotchi.level;
    
    // Vous pouvez personnaliser cette logique selon vos images
    return 'assets/images/tamagotchi/$level.png';
    
    // Si vous avez des images différentes selon l'humeur, utilisez ceci:
    // return 'assets/images/tamagotchi/${level}_$mood.png';
  }

  @override
  Widget build(BuildContext context) {
    // Créer un widget de base qui peut être tapoté
    Widget avatarWidget = GestureDetector(
      onTap: widget.onTap,
      child: _buildTamagotchiAvatar(),
    );
    
    // Si l'animation est désactivée, retourner directement le widget
    if (!widget.animated) {
      return avatarWidget;
    }
    
    // Sinon, retourner le widget avec animation
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: avatarWidget,
    );
  }

  Widget _buildTamagotchiAvatar() {
    final levelColor = _getLevelColor();
    
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(widget.size / 10),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image du Tamagotchi
          Image.asset(
            _getTamagotchiImagePath(),
            width: widget.size * 0.6,
            height: widget.size * 0.6,
            errorBuilder: (context, error, stackTrace) {
              // Fallback en cas d'erreur de chargement de l'image
              return Icon(
                Icons.pets,
                size: widget.size * 0.5,
                color: levelColor,
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Expression faciale (en attendant d'avoir des images d'humeur)
          _buildMoodIndicator(),
          
          const SizedBox(height: 16),
          
          // Barre de progression pour le niveau
          Container(
            width: widget.size * 0.7,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.tamagotchi.experiencePercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Niveau actuel
          Text(
            widget.tamagotchi.level.toUpperCase(),
            style: TextStyle(
              color: levelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour l'indicateur d'humeur
  Widget _buildMoodIndicator() {
    switch (widget.tamagotchi.mood) {
      case 'happy':
        return const Text('😄', style: TextStyle(fontSize: 24));
      case 'neutral':
        return const Text('😐', style: TextStyle(fontSize: 24));
      case 'tired':
        return const Text('😴', style: TextStyle(fontSize: 24));
      default:
        return const Text('😐', style: TextStyle(fontSize: 24));
    }
    
    // Alternative avec des images:
    // return Image.asset(
    //   'assets/images/tamagotchi/${widget.tamagotchi.mood}.png',
    //   width: 30,
    //   height: 30,
    // );
  }
}