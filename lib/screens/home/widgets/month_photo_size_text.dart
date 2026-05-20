import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swipe_media_cleaner/screens/home/home_screen_notifier.dart';
import 'package:swipe_media_cleaner/theme/app_colors.dart';
import 'package:swipe_media_cleaner/utils/file_size_formatter.dart';

class MonthPhotoSizeText extends ConsumerStatefulWidget {
  final int year;
  final int month;

  const MonthPhotoSizeText({
    super.key,
    required this.year,
    required this.month,
  });

  @override
  ConsumerState<MonthPhotoSizeText> createState() => _MonthPhotoSizeTextState();
}

class _MonthPhotoSizeTextState extends ConsumerState<MonthPhotoSizeText> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(homeScreenNotifierProvider.notifier).loadMonthPhotoSize(
            year: widget.year,
            month: widget.month,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeScreenNotifierProvider);

    final sizeBytes = homeState.monthPhotoSizes[widget.month];
    final isLoading = homeState.loadingSizeMonths.contains(widget.month);

    const textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.greyMedium,
    );

    if (sizeBytes != null) {
      return Text(
        FileSizeFormatter.formatBytes(sizeBytes),
        style: textStyle,
      );
    }

    if (isLoading) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    // этот виджет нужен, например, если подгрузка размера завершилась ошибкой.
    return const Text(
      '—',
      style: textStyle,
    );
  }
}
