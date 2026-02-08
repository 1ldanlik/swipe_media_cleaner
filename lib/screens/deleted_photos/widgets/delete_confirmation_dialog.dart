import 'package:flutter/material.dart';

/// Диалог подтверждения удаления фотографий
class DeleteConfirmationDialog extends StatelessWidget {
  final int photoCount;

  const DeleteConfirmationDialog({
    super.key,
    required this.photoCount,
  });

  /// Показать диалог и вернуть результат подтверждения
  static Future<bool> show(BuildContext context, int photoCount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(photoCount: photoCount),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Удалить фотографии?'),
      content: Text(
        'Вы действительно хотите удалить $photoCount фото навсегда?\n\n'
        'Это действие нельзя отменить!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Удалить'),
        ),
      ],
    );
  }
}
