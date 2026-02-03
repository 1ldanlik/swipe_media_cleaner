import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/deleted_photo.dart';
import 'models/app_statistics.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DeletedPhotoAdapter());
  Hive.registerAdapter(AppStatisticsAdapter());
  await Hive.openBox<DeletedPhoto>('deleted_photos');
  await Hive.openBox<AppStatistics>('statistics');
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Media Cleaner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
