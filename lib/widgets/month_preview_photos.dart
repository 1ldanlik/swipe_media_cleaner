import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_item.dart';

/// Виджет для отображения трёх фотографий месяца в ряд
class MonthPreviewPhotos extends StatelessWidget {
  final List<PhotoItem> previewPhotos;

  const MonthPreviewPhotos({
    super.key,
    required this.previewPhotos,
  });

  @override
  Widget build(BuildContext context) {
    if (previewPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        for (int i = 0; i < previewPhotos.length; i++) ...[
          SizedBox(
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(previewPhotos[i].path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
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
