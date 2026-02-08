import 'package:flutter/material.dart';

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  backgroundColor: Colors.red,
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
                  foregroundColor: Colors.blue,
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
