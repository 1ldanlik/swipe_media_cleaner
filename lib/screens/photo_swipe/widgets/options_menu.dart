import 'package:flutter/material.dart';
import 'package:swipe_media_cleaner/theme/app_colors.dart';

class OptionsMenu extends StatefulWidget {
  final bool isFullPictureShow;
  final bool isFinished;
  final bool currentPhotoIsFavorite;
  final VoidCallback onFullPictureShowToggle;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShareTap;

  const OptionsMenu({
    super.key,
    required this.onFullPictureShowToggle,
    required this.isFullPictureShow,
    required this.isFinished,
    required this.currentPhotoIsFavorite,
    required this.onToggleFavorite,
    required this.onShareTap,
  });

  @override
  State<OptionsMenu> createState() => _OptionsMenuState();
}

class _OptionsMenuState extends State<OptionsMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get isOpen => _controller.value > 0.5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  }

  void toggle() {
    isOpen ? _controller.reverse() : _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SlidingIconPanel(
      controller: _controller,
      onMainTap: toggle,
      items: [
        IconButton(
          onPressed: widget.onFullPictureShowToggle,
          icon: Icon(
            widget.isFullPictureShow ? Icons.zoom_out_map_rounded : Icons.zoom_in_map_rounded,
            color: AppColors.greyMedium,
            size: 28,
          ),
        ),
        IconButton(
          onPressed: widget.onShareTap,
          icon: const Icon(Icons.ios_share_rounded, color: AppColors.greyMedium, size: 28),
        ),
        IconButton(
          onPressed: widget.onToggleFavorite,
          icon: Icon(
            widget.currentPhotoIsFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.currentPhotoIsFavorite ? AppColors.favoriteRed : AppColors.greyMedium,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class _SlidingIconPanel extends StatelessWidget {
  const _SlidingIconPanel({required this.controller, required this.onMainTap, required this.items});

  final AnimationController controller;
  final VoidCallback onMainTap;
  final List<Widget> items;

  static const double width = 56;
  static const double mainButtonSize = 56;
  static const double itemSize = 48;
  static const double itemGap = 6;
  static const double panelPadding = 6;

  double get panelHeight {
    return panelPadding * 2 + items.length * itemSize + (items.length - 1) * itemGap;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: mainButtonSize + panelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: mainButtonSize - 24,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                final t = Curves.easeOutCubic.transform(controller.value);

                return ClipRect(
                  child: Align(alignment: Alignment.topCenter, heightFactor: t, child: child),
                );
              },
              child: _PanelBody(
                width: width,
                height: panelHeight + 24,
                items: items,
                onItemTap: () {
                  controller.reverse();
                },
              ),
            ),
          ),
          _MainEyeButton(onTap: onMainTap, controller: controller),
        ],
      ),
    );
  }
}

class _PanelBody extends StatelessWidget {
  const _PanelBody({
    required this.width,
    required this.height,
    required this.items,
    required this.onItemTap,
  });

  final double width;
  final double height;
  final List<Widget> items;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppColors.navigationBarBackground,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final item in items) ...[item, if (item != items.last) const SizedBox(height: 6)],
        ],
      ),
    );
  }
}

class _MainEyeButton extends StatelessWidget {
  const _MainEyeButton({required this.onTap, required this.controller});

  final VoidCallback onTap;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        final opacity = 0.5 + controller.value * 0.5;

        return Material(
          color: AppColors.favoriteRed.withValues(alpha: opacity),
          shape: const CircleBorder(),
          elevation: 8,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Transform.rotate(
                angle: controller.value * 3.14159,
                child: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 26),
              ),
            ),
          ),
        );
      },
    );
  }
}
