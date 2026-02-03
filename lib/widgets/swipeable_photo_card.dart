import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_item.dart';

class SwipeablePhotoCard extends StatefulWidget {
  final PhotoItem photo;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const SwipeablePhotoCard({
    super.key,
    required this.photo,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<SwipeablePhotoCard> createState() => _SwipeablePhotoCardState();
}

class _SwipeablePhotoCardState extends State<SwipeablePhotoCard>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _dragPosition = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Если свайп больше 30% экрана
    if (_dragPosition.abs() > screenWidth * 0.3) {
      // Анимируем карточку за экран
      _animation = Tween<double>(
        begin: _dragPosition,
        end: _dragPosition > 0 ? screenWidth : -screenWidth,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      
      _animationController.forward(from: 0).then((_) {
        if (_dragPosition > 0) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
        _animationController.reset();
        setState(() {
          _dragPosition = 0;
        });
      });
    } else {
      // Возвращаем карточку на место
      _animation = Tween<double>(
        begin: _dragPosition,
        end: 0,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
      );
      _animationController.forward(from: 0);
    }
  }

  Color _getOverlayColor() {
    if (_dragPosition > 50) {
      return Colors.green.withOpacity(0.3);
    } else if (_dragPosition < -50) {
      return Colors.red.withOpacity(0.3);
    }
    return Colors.transparent;
  }

  Widget _getOverlayIcon() {
    if (_dragPosition > 50) {
      return Positioned(
        top: 50,
        left: 30,
        child: Transform.rotate(
          angle: -0.3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              size: 64,
              color: Colors.green,
            ),
          ),
        ),
      );
    } else if (_dragPosition < -50) {
      return Positioned(
        top: 50,
        right: 30,
        child: Transform.rotate(
          angle: 0.3,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.close,
              size: 64,
              color: Colors.red,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotation = _dragPosition / screenWidth * 0.4;
    final opacity = (1 - (_dragPosition.abs() / screenWidth)).clamp(0.5, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Transform.translate(
        offset: Offset(_dragPosition, 0),
        child: Transform.rotate(
          angle: rotation,
          child: Opacity(
            opacity: opacity,
            child: Stack(
              children: [
                // Фотография
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.photo.path),
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Цветной оверлей при свайпе
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getOverlayColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                
                // Иконка при свайпе
                _getOverlayIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}