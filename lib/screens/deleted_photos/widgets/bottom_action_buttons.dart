import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Виджет с кнопками действий внизу экрана корзины
class BottomActionButtons extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDelete;
  final VoidCallback onRestore;

  const BottomActionButtons({
    super.key,
    required this.selectedCount,
    required this.onDelete,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_forever),
                label: Text('Удалить ($selectedCount)'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deleteRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRestore,
                icon: const Icon(Icons.restore),
                label: Text('Восстановить ($selectedCount)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.restoreBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
