import 'dart:io' show File;
import 'package:flutter/material.dart';
import '../models/photo_item.dart';
import '../theme/app_colors.dart';

/// Виджет для отображения трёх фотографий месяца в ряд
class MonthPreviewPhotos extends StatelessWidget {
  final List<PhotoItem> previewPhotos;

  const MonthPreviewPhotos({super.key, required this.previewPhotos});

  @override
  Widget build(BuildContext context) {
    if (previewPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Физический размер превью в интерфейсе (logical pixels).
    const previewSize = 46.0;
    // Переводим размер в физические пиксели экрана,
    // чтобы декодировать файл сразу в нужную ширину.
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final targetWidth = (previewSize * devicePixelRatio).round();

    return Row(
      children: [
        for (int i = 0; i < previewPhotos.length; i++) ...[
          SizedBox(
            width: previewSize,
            height: previewSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(previewPhotos[i].path),
                  fit: BoxFit.cover,
                  // Ограничиваем ширину декодирования:
                  // меньше память и быстрее отрисовка для маленьких превью.
                  cacheWidth: targetWidth,
                  filterQuality: FilterQuality.low,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.greyLight,
                      child: const Icon(Icons.broken_image, color: AppColors.brokenImageIcon),
                    );
                  },
                ),
              ),
            ),
          ),
          if (i < previewPhotos.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}
