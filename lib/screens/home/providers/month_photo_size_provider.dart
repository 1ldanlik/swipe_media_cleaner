import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

Future<int> calculatePhotoSizeForMonth({
  required int year,
  required int month,
}) async {
  try {
    debugPrint('📦 Лениво считаем размер фото за $month.$year');

    final startOfMonth = DateTime(year, month, 1);
    final startOfNextMonth = DateTime(year, month + 1, 1);

    final filter = FilterOptionGroup(
      createTimeCond: DateTimeCond(
        min: startOfMonth,
        max: startOfNextMonth,
      ),
      orders: [
        const OrderOption(
          type: OrderOptionType.createDate,
          asc: true,
        ),
      ],
    );

    final int totalCount = await PhotoManager.getAssetCount(
      type: RequestType.image,
      filterOption: filter,
    );

    if (totalCount == 0) {
      debugPrint('📦 Фото за $month.$year не найдены');
      return 0;
    }

    int totalBytes = 0;

    const assetPageSize = 100;
    const fileBatchSize = 4;

    for (int start = 0; start < totalCount; start += assetPageSize) {
      final end = min(start + assetPageSize, totalCount);

      final assets = await PhotoManager.getAssetListRange(
        start: start,
        end: end,
        type: RequestType.image,
        filterOption: filter,
      );

      for (int i = 0; i < assets.length; i += fileBatchSize) {
        final batch = assets.skip(i).take(fileBatchSize).toList();

        final sizes = await Future.wait(
          batch.map(_getAssetSizeBytes),
        );

        totalBytes += sizes.fold<int>(
          0,
          (sum, size) => sum + size,
        );
      }

      debugPrint('⏳ Размер фото за $month.$year: обработано $end / $totalCount');
    }

    return totalBytes;
  } catch (e, stackTrace) {
    debugPrint('❌ Ошибка подсчета размера фото за $month.$year: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<int> _getAssetSizeBytes(AssetEntity asset) async {
  try {
    final File? file = await asset.originFile;

    if (file == null) {
      return 0;
    }

    return await file.length();
  } catch (e) {
    debugPrint('❌ Ошибка получения размера фото ${asset.id}: $e');
    return 0;
  }
}

@immutable
class MonthSizeParams {
  final int year;
  final int month;

  const MonthSizeParams({
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MonthSizeParams && year == other.year && month == other.month;
  }

  @override
  int get hashCode => Object.hash(year, month);
}

final monthPhotoSizeProvider = FutureProvider.family<int, MonthSizeParams>((ref, params) async {
  return calculatePhotoSizeForMonth(
    year: params.year,
    month: params.month,
  );
});
