import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

/// Модель для отдельной фотографии
class PhotoItem {
  final String id;
  final String path;
  final DateTime createdDate;
  final int size; // размер в байтах
  final AssetEntity asset;
  final bool isFavorite;

  PhotoItem({
    required this.id,
    required this.path,
    required this.createdDate,
    required this.size,
    required this.asset,
    required this.isFavorite,
  });

  PhotoItem copyWith({
    String? id,
    String? path,
    DateTime? createdDate,
    int? size,
    AssetEntity? asset,
    bool? isFavorite,
  }) {
    return PhotoItem(
      id: id ?? this.id,
      path: path ?? this.path,
      createdDate: createdDate ?? this.createdDate,
      size: size ?? this.size,
      asset: asset ?? this.asset,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  static Future<PhotoItem?> fromAsset(AssetEntity asset, String path) async {
    try {
      // Получаем размер файла
      final file = File(path);
      int fileSize = 0;
      try {
        fileSize = await file.length();
      } catch (e) {
        debugPrint('⚠️ Не удалось получить размер файла: $e');
        fileSize = 0;
      }

      return PhotoItem(
        id: asset.id,
        path: path,
        createdDate: asset.createDateTime,
        size: fileSize,
        asset: asset,
        isFavorite: asset.isFavorite,
      );
    } catch (e) {
      debugPrint('❌ Ошибка создания PhotoItem: $e');
      return null;
    }
  }
}
