// Core imports for Flutter, Firebase, and state management
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';

// Imports for app-specific screens and providers
import 'services/background/app_lifecycle_manager.dart';
import 'services/background/app_state_sync.service.dart';
import 'services/background/background_fetch.service.dart';
import 'services/objectbox/object_box.dart';
import 'services/firebase/firebase_options.dart';
import 'layouts/on_boarding.dart';
import 'layouts/splash_screen.dart';
import 'providers/app_keys.provider.dart';
import 'utilities/theme/theme_provider.dart';

// Track if it's the first time viewing the app
bool? isFirstTimeView;

ObjectBox? objectbox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  objectbox = await ObjectBox.create();

  // Get shared preferences to check first-time view status
  SharedPreferences preferences = await SharedPreferences.getInstance();
  isFirstTimeView = preferences.getBool('isFirstTimeView') ?? true;

  // Set app orientation to portrait mode only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set the status bar to be transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Fully transparent
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  await BackgroundFetchService.configureBackgroundFetch();

  // Start the app with Riverpod state management
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with CustomThemeDataMixin {
  final AppLifecycleHandler _lifecycleHandler = AppLifecycleHandler();
  final AppStateSync appStateSyncService = AppStateSync();

  @override
  void initState() {
    super.initState();
    _lifecycleHandler.initialize();
    // Defer the sync service to avoid blocking startup UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appStateSyncService.startSync();
    });
  }

  @override
  void dispose() {
    _lifecycleHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider).keys.first;
    final appKeys = ref.watch(appKeysProvider);

    return MaterialApp(
      title: "Scrapuncle",
      key: appKeys.restartKey,
      scaffoldMessengerKey: appKeys.scaffoldMessengerKey,
      navigatorKey: appKeys.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: isFirstTimeView == true ? OnBoarding() : SplashScreen(),
    );
  }
}
