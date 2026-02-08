import 'package:flutter/material.dart';

/// Диалог подтверждения восстановления фотографий
class RestoreConfirmationDialog extends StatelessWidget {
  final int photoCount;

  const RestoreConfirmationDialog({
    super.key,
    required this.photoCount,
  });

  /// Показать диалог и вернуть результат подтверждения
  static Future<bool> show(BuildContext context, int photoCount) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RestoreConfirmationDialog(photoCount: photoCount),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Восстановить фотографии?'),
      content: Text(
        'Вы действительно хотите восстановить $photoCount фото?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Восстановить'),
        ),
      ],
    );
  }
}
