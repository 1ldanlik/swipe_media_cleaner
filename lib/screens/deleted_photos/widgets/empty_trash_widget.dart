import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class EmptyTrashWidget extends StatelessWidget {
  const EmptyTrashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_sweep_outlined,
              size: 120,
              color: AppColors.greyLight,
            ),
            const SizedBox(height: 24),
            Text(
              'Корзина пуста',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.greyVeryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Свайпните фото влево на экране просмотра, чтобы добавить их в корзину',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
