import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';
import '../notifiers/user_profile_notifier.dart';
import '../main.dart'; // Import for routerRefreshProvider

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

// Define OnboardingPage class at the top level before it's used
class OnboardingPage {
  final String title;
  final String description;
  final String animation;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.animation,
    required this.color,
  });
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to MedStreak",
      description: "Master medical parameter ranges through intuitive swipe actions.",
      animation: 'assets/lottie/doctor_wave.json',
      color: AppTheme.primaryNeon,
    ),
    OnboardingPage(
      title: "Swipe to Categorize",
      description: "Swipe LEFT for LOW values, RIGHT for HIGH values, and DOWN for NORMAL values.",
      animation: 'assets/lottie/shape_change.json',
      color: AppTheme.secondaryNeon,
    ),
    OnboardingPage(
      title: "Build Your Streak",
      description: "Correct answers build your streak. How long can you maintain it?",
      animation: 'assets/lottie/trophy.json',
      color: AppTheme.accentNeon,
    ),
    OnboardingPage(
      title: "Practice Mode",
      description: "Use practice mode to see normal ranges and master specific categories.",
      animation: 'assets/lottie/doctor_reading.json',
      color: Colors.green,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.8,
                colors: [
                  _pages[_currentPage].color.withOpacity(0.2),
                  AppTheme.backgroundDark,
                ],
              ),
            ),
          ),
          
          // Page content
          SafeArea(
            child: Column(
              children: [
                // Skip button at top-right
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _completeOnboarding,
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        color: _pages[_currentPage].color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),
                
                // Bottom buttons
                _buildBottomButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: AppTheme.neonShadow(
                page.color,
                intensity: 0.3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Lottie.asset(
                page.animation,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBright,
              shadows: [
                Shadow(
                  color: page.color.withOpacity(0.8),
                  blurRadius: 10,
                ),
                Shadow(
                  color: page.color.withOpacity(0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: _isLoading ? null : () {
                print('DEBUG: Skip button tapped');
                _completeOnboarding();
              },
              child: _isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Skip', style: TextStyle(fontSize: 16)),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            onPressed: _isLoading ? null : () {
              print('DEBUG: Next/Start button tapped');
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _completeOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: _isLoading && _currentPage == _pages.length - 1
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Start',
                  style: const TextStyle(fontSize: 16),
                ),
          ),
        ],
      ),
    );
  }
  
  void _completeOnboarding() async {
    if (_isLoading) {
      print('DEBUG: Already processing onboarding completion, ignoring tap');
      return; // Prevent multiple taps
    }
    
    setState(() => _isLoading = true);
    print('DEBUG: Completing onboarding...');
    
    try {
      // Use the simplified method to directly update the state
      final notifier = ref.read(userProfileProvider.notifier);
      
      // Update state first
      notifier.setOnboardingCompleted();
      print('DEBUG: Onboarding state updated in memory');
      
      // Save profile and wait for it to complete
      await notifier.saveProfile();
      print('DEBUG: Profile saved successfully');
      
      // Force router refresh by notifying the router refresh provider
      ref.read(routerRefreshProvider.notifier).refresh();
      
      // Add a small delay to ensure the router has time to process the refresh
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Navigate after saving is complete
      if (mounted) {
        print('DEBUG: Navigating to /menu');
        // Use pushReplacement to force a complete navigation
        context.pushReplacement('/menu');
      }
    } catch (e) {
      print('ONBOARDING EXCEPTION: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        // Show error to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing onboarding. Please try again.'))
        );
      }
    } finally {
      // Ensure loading state is reset
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
