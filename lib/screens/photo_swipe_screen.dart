import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/month_group.dart';
import '../models/photo_item.dart';
import '../providers/deleted_photos_provider.dart';
import '../widgets/swipeable_photo_card.dart';

class PhotoSwipeScreen extends ConsumerStatefulWidget {
  final MonthGroup monthGroup;

  const PhotoSwipeScreen({
    super.key,
    required this.monthGroup,
  });

  @override
  ConsumerState<PhotoSwipeScreen> createState() => _PhotoSwipeScreenState();
}

class _PhotoSwipeScreenState extends ConsumerState<PhotoSwipeScreen> {
  int currentIndex = 0;
  List<PhotoItem> remainingPhotos = [];
  List<PhotoItem> markedForDeletion = [];

  @override
  void initState() {
    super.initState();
    remainingPhotos = List.from(widget.monthGroup.photos);
  }

  void _handleKeep() {
    if (currentIndex < remainingPhotos.length) {
      // Увеличиваем счетчик просмотренных
      final service = ref.read(deletedPhotosServiceProvider);
      service.incrementCheckedPhotos();
      
      setState(() {
        currentIndex++;
      });
      _checkIfFinished();
    }
  }

  Future<void> _handleDelete() async {
    if (currentIndex < remainingPhotos.length) {
      final photo = remainingPhotos[currentIndex];
      
      // Увеличиваем счетчик просмотренных
      final service = ref.read(deletedPhotosServiceProvider);
      service.incrementCheckedPhotos();
      
      // Сохраняем в кэш
      await service.markForDeletion(photo);
      
      setState(() {
        markedForDeletion.add(photo);
        currentIndex++;
      });
      _checkIfFinished();
    }
  }

  void _checkIfFinished() {
    if (currentIndex >= remainingPhotos.length) {
      _showSummaryDialog();
    }
  }

  void _showSummaryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Готово!'),
        content: Text(
          'Вы просмотрели все фотографии.\n\n'
          'Отмечено к удалению: ${markedForDeletion.length}\n'
          'Оставлено: ${remainingPhotos.length - markedForDeletion.length}\n\n'
          'Фото перемещены в корзину. Вы можете удалить их окончательно на вкладке "Корзина".',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Завершить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = remainingPhotos.isEmpty
        ? 0.0
        : (currentIndex / remainingPhotos.length).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.monthGroup.monthName} ${widget.monthGroup.year}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${currentIndex + 1} / ${remainingPhotos.length}',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
      body: currentIndex < remainingPhotos.length
          ? SwipeablePhotoCard(
              photo: remainingPhotos[currentIndex],
              onSwipeLeft: _handleDelete,
              onSwipeRight: _handleKeep,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 100,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Все фотографии просмотрены!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Завершить'),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: currentIndex < remainingPhotos.length
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    heroTag: 'delete',
                    onPressed: _handleDelete,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.close, size: 32),
                  ),
                  FloatingActionButton(
                    heroTag: 'keep',
                    onPressed: _handleKeep,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.check, size: 32),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
