import 'dart:io';
import 'package:photo_manager/photo_manager.dart';

/// Модель для отдельной фотографии
class PhotoItem {
  final String id;
  final String path;
  final DateTime createdDate;
  final int size; // размер в байтах
  final AssetEntity asset;

  PhotoItem({
    required this.id,
    required this.path,
    required this.createdDate,
    required this.size,
    required this.asset,
  });

  static Future<PhotoItem?> fromAsset(AssetEntity asset, String path) async {
    // Получаем размер файла
    final file = File(path);
    int fileSize = 0;
    try {
      fileSize = await file.length();
    } catch (e) {
      fileSize = 0;
    }

    return PhotoItem(
      id: asset.id,
      path: path,
      createdDate: asset.createDateTime,
      size: fileSize,
      asset: asset,
    );
  }
}
