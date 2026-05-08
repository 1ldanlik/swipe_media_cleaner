import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/deleted_photo.dart';
import '../../../theme/app_colors.dart';
import '../notifiers/deleted_photos_notifier.dart';

class PhotoCard extends StatelessWidget {
  final DeletedPhotosNotifier notifier;
  final DeletedPhoto photo;
  final bool isSelected;

  const PhotoCard({
    super.key,
    required this.notifier,
    required this.photo,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => notifier.toggleSelection(photo.id),
      onLongPress: () => notifier.toggleSelection(photo.id),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.greyLight,
                  child: const Icon(Icons.broken_image, color: AppColors.brokenImageIcon),
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: isSelected
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: const ColoredBox(
                            color: AppColors.restoreBlue,
                            child: SizedBox(
                              height: 32,
                              width: 32,
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.white,
                          size: 38,
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white,
                      size: 38,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
