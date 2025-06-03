import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';
import '../notifiers/user_profile_notifier.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
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
                    onPressed: _completeOnboarding,
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
                
                // Page indicator and next button
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => _buildPageIndicator(index),
                        ),
                      ),
                      
                      // Next/Done button
                      GestureDetector(
                        onTap: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: _pages[_currentPage].color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: _pages[_currentPage].color,
                              width: 2,
                            ),
                            boxShadow: AppTheme.neonShadow(
                              _pages[_currentPage].color,
                              intensity: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _currentPage == _pages.length - 1 ? 'START' : 'NEXT',
                                style: TextStyle(
                                  color: _pages[_currentPage].color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _pages.length - 1 
                                    ? Icons.check_circle
                                    : Icons.arrow_forward,
                                color: _pages[_currentPage].color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animation
          Container(
            height: 220,
            width: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.1),
              border: Border.all(
                color: page.color.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: AppTheme.neonShadow(page.color, intensity: 0.4),
            ),
            padding: const EdgeInsets.all(24),
            child: Lottie.asset(
              page.animation,
              fit: BoxFit.contain,
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
  
  Widget _buildPageIndicator(int index) {
    bool isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        color: isActive 
            ? _pages[_currentPage].color 
            : _pages[_currentPage].color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
        boxShadow: isActive 
            ? [
                BoxShadow(
                  color: _pages[_currentPage].color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ] 
            : null,
      ),
    );
  }
  
  void _completeOnboarding() {
    // Mark onboarding as completed and navigate to main menu
    // Set the hasCompletedOnboarding flag to true
    final currentProfile = ref.read(userProfileProvider);
    // Create an updated profile with completed onboarding flag
    final updatedProfile = currentProfile.copyWith(hasCompletedOnboarding: true);
    // Update the profile state with the updated profile
    ref.read(userProfileProvider.notifier).updateSettings(updatedProfile.settings);
    
    Navigator.of(context).pushReplacementNamed('/menu');
  }
}

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
