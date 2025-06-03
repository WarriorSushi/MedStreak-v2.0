import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/game_card.dart';
import '../services/game_service.dart';
import '../models/medical_models.dart';
import '../utils/theme.dart';

class CardContainer extends ConsumerStatefulWidget {
  const CardContainer({Key? key}) : super(key: key);

  @override
  ConsumerState<CardContainer> createState() => _CardContainerState();
}

class _CardContainerState extends ConsumerState<CardContainer>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _backgroundController;
  late Animation<double> _entryAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundAnimation;

  GameQuestion? _previousQuestion;
  bool _showingCard = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _entryAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _entryController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _animateNewCard() {
    _entryController.reset();
    _entryController.forward();
    setState(() {
      _showingCard = true;
    });
  }

  void _hideCard() {
    setState(() {
      _showingCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameServiceProvider);
    final gameService = ref.read(gameServiceProvider.notifier);

    // Check if we have a new question
    if (gameState.currentQuestion != null && 
        gameState.currentQuestion != _previousQuestion) {
      _previousQuestion = gameState.currentQuestion;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateNewCard();
      });
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0 + (_backgroundAnimation.value * 0.3),
                    colors: [
                      AppTheme.primaryNeon.withOpacity(0.05 + (_backgroundAnimation.value * 0.05)),
                      AppTheme.secondaryNeon.withOpacity(0.03 + (_backgroundAnimation.value * 0.03)),
                      AppTheme.backgroundDark,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              );
            },
          ),

          // Floating particles effect
          ...List.generate(8, (index) => _buildFloatingParticle(index)),

          // Card area
          Center(
            child: AnimatedBuilder(
              animation: _entryAnimation,
              builder: (context, child) {
                if (!_showingCard || gameState.currentQuestion == null) {
                  return _buildEmptyState();
                }

                return Transform.translate(
                  offset: Offset(
                    _slideAnimation.value.dx * MediaQuery.of(context).size.width,
                    _slideAnimation.value.dy * MediaQuery.of(context).size.height,
                  ),
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _entryAnimation.value,
                      child: GameCard(
                        parameter: gameState.currentQuestion!.parameter,
                        value: gameState.currentQuestion!.value,
                        unitData: gameState.currentQuestion!.unitData,
                        displayValue: gameState.currentQuestion!.displayValue,
                        difficulty: gameState.currentQuestion!.parameter.difficulty,
                        sexContext: gameState.currentQuestion!.sexContext,
                        onCorrectSwipe: () {
                          _hideCard();
                          // Play success sound
                          HapticFeedback.mediumImpact();
                        },
                        onWrongSwipe: () {
                          // Play error sound
                          HapticFeedback.heavyImpact();
                        },
                        onSwipe: (direction) {
                          gameService.handleSwipe(direction);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Unit toggle button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _buildUnitToggleButton(gameState, gameService),
          ),

          // Streak counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildStreakCounter(gameState.currentStreak),
          ),

          // Practice mode indicator
          if (gameState.isPracticeMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + 70,
              left: 16,
              child: _buildPracticeModeIndicator(),
            ),
            
          // Normal range display in practice mode
          if (gameState.isPracticeMode && gameState.currentQuestion != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: _buildNormalRangeDisplay(gameState.currentQuestion!),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticle(int index) {
    final random = index * 0.2;
    final randomSize = 4.0 + (index * 2.0);
    final randomOpacity = 0.1 + (index * 0.05);
    
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        return Positioned(
          top: size.height * (0.2 + 
               (math.sin(_backgroundController.value * 2 * math.pi + random) * 0.3)),
          left: size.width * (0.1 + 
                (math.cos(_backgroundController.value * 2 * math.pi + random) * 0.4)),
          child: Container(
            width: randomSize,
            height: randomSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index.isEven 
                  ? AppTheme.primaryNeon.withOpacity(randomOpacity)
                  : AppTheme.secondaryNeon.withOpacity(randomOpacity),
              boxShadow: [
                BoxShadow(
                  color: index.isEven 
                      ? AppTheme.primaryNeon.withOpacity(randomOpacity)
                      : AppTheme.secondaryNeon.withOpacity(randomOpacity),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.refresh,
          size: 64,
          color: AppTheme.primaryNeon.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Loading next question...',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUnitToggleButton(GameState gameState, GameService gameService) {
    final currentSystem = gameState.currentQuestion?.unitData.unitType ?? UnitSystem.conventional;
    
    return GestureDetector(
      onTap: () => gameService.toggleUnitSystem(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.secondaryNeon,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondaryNeon.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz,
              color: AppTheme.secondaryNeon,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              currentSystem == UnitSystem.si ? 'SI' : 'CONV',
              style: const TextStyle(
                color: AppTheme.secondaryNeon,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCounter(int streak) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryNeon.withOpacity(0.2),
            AppTheme.secondaryNeon.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.primaryNeon,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeon.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppTheme.primaryNeon,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            '$streak',
            style: const TextStyle(
              color: AppTheme.textBright,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeModeIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.green,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 6),
          const Text(
            'PRACTICE MODE',
            style: TextStyle(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNormalRangeDisplay(GameQuestion question) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NORMAL RANGE',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRangeIndicator(question.unitData.normalLow, question.unitData.unitSymbol, Colors.blue),
                const Text(
                  ' - ',
                  style: TextStyle(color: AppTheme.textBright, fontSize: 18),
                ),
                _buildRangeIndicator(question.unitData.normalHigh, question.unitData.unitSymbol, Colors.red),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              question.sexContext == SexContext.general 
                ? 'General population'
                : question.sexContext == SexContext.male 
                  ? 'Adult males'
                  : 'Adult females',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRangeIndicator(double value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        '${value.toString()} $unit',
        style: TextStyle(
          color: AppTheme.textBright,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
