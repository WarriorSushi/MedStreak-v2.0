import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/splash_screen.dart';
import 'screens/game_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/practice_screen.dart';
import 'services/storage_service.dart';
import 'services/game_service.dart';
import 'utils/theme.dart';

// Define the router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameScreen(),
      ),
      GoRoute(
        path: '/practice',
        builder: (context, state) => const PracticeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    redirect: (context, state) {
      // Handle redirections based on app state
      if (state.fullPath == '/splash') {
        return null; // Don't redirect splash screen
      }
      
      // If user hasn't completed onboarding, redirect to onboarding
      if (!userProfile.hasCompletedOnboarding && 
          state.fullPath != '/onboarding') {
        return '/onboarding';
      }
      
      return null; // No redirection needed
    },
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage service
  await StorageService.init();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const ProviderScope(child: MedStreakApp()));
}

class MedStreakApp extends ConsumerWidget {
  const MedStreakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'MedStreak',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.darkTheme,
    );
  }
}

