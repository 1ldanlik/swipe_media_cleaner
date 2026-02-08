import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class EmptyStatisticsWidget extends StatelessWidget {
  const EmptyStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      elevation: 2,
      color: AppColors.warningBackground,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.restoreBlue,
                ),
                SizedBox(width: 12),
                Text(
                  'Начните очистку',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Перейдите на вкладку "Галерея", выберите месяц и начните просматривать фотографии. '
              'Свайпайте влево, чтобы удалить, или вправо, чтобы оставить.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.greyVeryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
