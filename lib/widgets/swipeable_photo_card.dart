import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_item.dart';
import '../models/card_interaction_mode.dart';
import '../theme/app_colors.dart';

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
  // Константы
  static const double _swipeThresholdRatio = 0.25; // 25% ширины экрана для срабатывания свайпа
  static const double _maxOverlayAlpha = 0.35; // Максимальная прозрачность overlay
  static const double _minOverlayDistance = 10.0; // Минимальное смещение для показа overlay

  double _dragPosition = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TransformationController _transformationController = TransformationController();
  final ValueNotifier<CardInteractionMode> _interactionModeNotifier =
      ValueNotifier<CardInteractionMode>(CardInteractionMode.swipe);

  // Отслеживаем количество пальцев на экране
  int _pointerCount = 0;

  // Для управления зумом через GestureDetector
  double _initialScale = 1.0;
  Offset _initialFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Отслеживаем изменения масштаба
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    _interactionModeNotifier.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final newMode = scale > 1.0 ? CardInteractionMode.zoom : CardInteractionMode.swipe;

    if (_interactionModeNotifier.value != newMode) {
      _interactionModeNotifier.value = newMode;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerCount++;
    if (_pointerCount >= 2) {
      _interactionModeNotifier.value = CardInteractionMode.zoom;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointerCount--;
    if (_pointerCount == 0) {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if (scale > 1.0) {
        _resetZoom();
      }
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointerCount--;
    if (_pointerCount == 0) {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if (scale > 1.0) {
        _resetZoom();
      }
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _initialScale = _transformationController.value.getMaxScaleOnAxis();
    _initialFocalPoint = details.focalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_interactionModeNotifier.value != CardInteractionMode.zoom) return;

    final newScale = (_initialScale * details.scale).clamp(1.0, 4.0);
    final focalPointDelta = details.focalPoint - _initialFocalPoint;

    final matrix = Matrix4.identity()
      ..translate(focalPointDelta.dx, focalPointDelta.dy)
      ..scale(newScale);

    _transformationController.value = matrix;
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // Можно добавить логику если нужно
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    _interactionModeNotifier.value = CardInteractionMode.swipe;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * _swipeThresholdRatio;

    if (_dragPosition > swipeThreshold) {
      _animateSwipe(screenWidth, widget.onSwipeRight);
    } else if (_dragPosition < -swipeThreshold) {
      _animateSwipe(-screenWidth, widget.onSwipeLeft);
    } else {
      _animateSwipe(0, null);
    }
  }

  void _animateSwipe(double target, VoidCallback? onComplete) {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }

    _animation = Tween<double>(
      begin: _dragPosition,
      end: target,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    void animationListener() {
      setState(() {
        _dragPosition = _animation.value;
      });
    }

    _animation.addListener(animationListener);

    _animationController.forward(from: 0).then((_) {
      _animation.removeListener(animationListener);
      setState(() {
        _dragPosition = target == 0 ? 0 : _dragPosition;
      });
      _animationController.reset();

      if (onComplete != null) {
        onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotation = _dragPosition / screenWidth * 0.1;
    final opacity = 1 - (_dragPosition.abs() / screenWidth * 0.5);

    // Вычисление параметров для overlay
    final swipeThreshold = screenWidth * _swipeThresholdRatio; // 25% ширины экрана
    final swipeProgress = (_dragPosition.abs() / swipeThreshold).clamp(0.0, 1.0);
    final overlayAlpha = (swipeProgress * _maxOverlayAlpha).clamp(0.0, _maxOverlayAlpha);
    final labelOpacity = swipeProgress.clamp(0.0, 1.0);
    final labelScale = 0.9 + (swipeProgress * 0.1); // от 0.9 до 1.0

    // Определяем направление свайпа
    final isSwipingRight = _dragPosition > 0;
    final isSwipingLeft = _dragPosition < 0;
    final showOverlay =
        _dragPosition.abs() > _minOverlayDistance; // Показываем overlay при смещении > 10px

    return ValueListenableBuilder<CardInteractionMode>(
      valueListenable: _interactionModeNotifier,
      builder: (context, mode, child) {
        final isZoomMode = mode == CardInteractionMode.zoom;

        return Listener(
          onPointerDown: _onPointerDown,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          child: GestureDetector(
            onHorizontalDragUpdate: isZoomMode ? null : _onHorizontalDragUpdate,
            onHorizontalDragEnd: isZoomMode ? null : _onHorizontalDragEnd,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: Transform.translate(
              offset: Offset(isZoomMode ? 0 : _dragPosition, 0),
              child: Transform.rotate(
                angle: isZoomMode ? 0 : rotation,
                child: Opacity(
                  opacity: isZoomMode ? 1.0 : opacity.clamp(0.3, 1.0),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    panEnabled: isZoomMode,
                    scaleEnabled: true,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Основное изображение
                            Image.file(
                              File(widget.photo.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.greyLight,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 64,
                                      color: AppColors.brokenImageIcon,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Overlay tint (только в swipe режиме и при наличии смещения)
                            if (!isZoomMode && showOverlay)
                              Container(
                                color: isSwipingRight
                                    ? AppColors.mainButtonBackground.withOpacity(overlayAlpha)
                                    : AppColors.deleteButtonIcon.withOpacity(overlayAlpha),
                              ),

                            // Label с иконкой и текстом
                            if (!isZoomMode && showOverlay)
                              Positioned(
                                top: 20,
                                left: isSwipingRight ? 20 : null,
                                right: isSwipingLeft ? 20 : null,
                                child: Opacity(
                                  opacity: labelOpacity,
                                  child: Transform.scale(
                                    scale: labelScale,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSwipingRight
                                                ? Icons.check_rounded
                                                : Icons.delete_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isSwipingRight ? 'ОСТАВИТЬ' : 'В КОРЗИНУ',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
