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
import 'screens/sound_test_screen.dart';
import 'services/storage_service.dart';
import 'services/game_service.dart';
import 'utils/theme.dart';

// Simple direct provider for router configuration
final routerProvider = Provider<GoRouter>((ref) {
  // Create a direct reference to the storage service to check onboarding status
  // This ensures we're always getting the latest value from storage
  final userProfile = ref.watch(userProfileProvider);
  
  // Create a refresh notifier to force router refresh when needed
  final refreshNotifier = ref.watch(routerRefreshProvider);
  
  return GoRouter(
    refreshListenable: refreshNotifier, // Add refresh listener
    initialLocation: '/splash',
    debugLogDiagnostics: true,
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
      GoRoute(
        path: '/sound-test',
        builder: (context, state) => const SoundTestScreen(),
      ),
    ],
    // Improved redirect logic with direct storage check
    redirect: (context, state) {
      // Always allow splash screen
      if (state.fullPath == '/splash') return null;
      
      // Get onboarding status from both the provider and directly from storage
      // This ensures we have the most up-to-date value
      final hasCompletedOnboarding = userProfile.hasCompletedOnboarding;
      
      // Also check storage directly as a backup
      final onboardingCompleted = StorageService.isOnboardingCompleted();
      
      print('ROUTER: Path=${state.fullPath}, onboarding from provider=$hasCompletedOnboarding, from storage=$onboardingCompleted');
      
      // Use either source - if either says onboarding is complete, consider it complete
      final isOnboardingComplete = hasCompletedOnboarding || onboardingCompleted;
      
      // Simple redirect logic
      if (!isOnboardingComplete) {
        // Not completed onboarding - only allow onboarding screen
        return state.fullPath != '/onboarding' ? '/onboarding' : null;
      } else {
        // Completed onboarding - don't allow going back to onboarding
        return state.fullPath == '/onboarding' ? '/menu' : null;
      }
    },
  );
});

// Add a refresh notifier to force router refresh when needed
final routerRefreshProvider = ChangeNotifierProvider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier();
});

// Simple notifier to force router refresh
class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

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

