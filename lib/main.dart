import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:quintou_app/core/routing/router.dart';
import 'package:quintou_app/features/chat/data/services/push_notification_service.dart';
import 'dart:async';
import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('chat_cache');
  
  // Try initializing Firebase
  try {
    await Firebase.initializeApp();
    
    // Configure error handlers after Firebase initialization
    await _setupErrorHandling();
    
    // Configure Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    // Initialize Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await PushNotificationService.initialize();
    
    print("Firebase initialized successfully");
  } catch (e, stack) {
    print("Failed to initialize Firebase: $e");
    print("Stack: $stack");
  }

  // Create provider container and set it for router auth checks
  final container = ProviderContainer();
  setProviderContainer(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

Future<void> _setupErrorHandling() async {
  // Enable Crashlytics collection
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  
  // Set up custom error logger
  FlutterError.onError = (FlutterErrorDetails details) {
    // Log to console in debug mode
    FlutterError.presentError(details);
    
    // Send to Crashlytics in release mode
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };
  
  print("Error handling configured");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      builder: BotToastInit(),
      title: 'Quintou',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB7F65E)),
        fontFamily: 'Inter',
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, // Textos e ícones pretos
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black, // Cor do texto da aba ativa (preto)
          unselectedItemColor: Colors.grey, // Cor do texto inativo
          selectedIconTheme: IconThemeData(color: Color(0xFFB7F65E)), // Apenas o ícone ganha cor
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
