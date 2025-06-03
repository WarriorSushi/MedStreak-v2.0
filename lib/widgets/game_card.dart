import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../models/medical_models.dart';
import '../utils/theme.dart';

class GameCard extends StatefulWidget {
  final MedicalParameter parameter;
  final double value;
  final UnitData unitData;
  final String displayValue;
  final ParameterDifficulty difficulty;
  final SexContext sexContext;
  final VoidCallback onCorrectSwipe;
  final VoidCallback onWrongSwipe;
  final Function(SwipeDirection) onSwipe;

  const GameCard({
    Key? key,
    required this.parameter,
    required this.value,
    required this.unitData,
    required this.displayValue,
    required this.difficulty,
    required this.sexContext,
    required this.onCorrectSwipe,
    required this.onWrongSwipe,
    required this.onSwipe,
  }) : super(key: key);

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _errorController;
  late AnimationController _glowController;
  
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _errorAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isAnimating = false;
  bool _showError = false;
  String _errorText = '';
  SwipeDirection? _lastSwipeDirection;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _positionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _errorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    _errorController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  SwipeDirection _getSwipeDirection(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    
    if (velocity.dx.abs() > velocity.dy.abs()) {
      return velocity.dx > 500 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return SwipeDirection.up;
    }
  }

  ValueType _getCorrectAnswer() {
    if (widget.value < widget.unitData.normalLow) {
      return ValueType.low;
    } else if (widget.value > widget.unitData.normalHigh) {
      return ValueType.high;
    } else {
      return ValueType.normal;
    }
  }

  bool _isSwipeCorrect(SwipeDirection direction) {
    final correctAnswer = _getCorrectAnswer();
    
    switch (direction) {
      case SwipeDirection.left:
        return correctAnswer == ValueType.low;
      case SwipeDirection.right:
        return correctAnswer == ValueType.high;
      case SwipeDirection.up:
        return correctAnswer == ValueType.normal;
    }
  }

  void _handleSwipe(SwipeDirection direction) async {
    if (_isAnimating) return;
    
    _isAnimating = true;
    _lastSwipeDirection = direction;
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    widget.onSwipe(direction);
    
    if (_isSwipeCorrect(direction)) {
      await _animateCorrectSwipe(direction);
      widget.onCorrectSwipe();
    } else {
      await _animateWrongSwipe(direction);
      widget.onWrongSwipe();
    }
  }

  Future<void> _animateCorrectSwipe(SwipeDirection direction) async {
    // Scale up slightly
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    await _scaleController.forward();
    
    // Fly out in swipe direction
    Offset targetOffset;
    switch (direction) {
      case SwipeDirection.left:
        targetOffset = const Offset(-2.0, 0.0);
        break;
      case SwipeDirection.right:
        targetOffset = const Offset(2.0, 0.0);
        break;
      case SwipeDirection.up:
        targetOffset = const Offset(0.0, 2.0);
        break;
    }
    
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeInBack,
    ));
    
    await _positionController.forward();
  }

  Future<void> _animateWrongSwipe(SwipeDirection direction) async {
    // Show error state
    setState(() {
      _showError = true;
      _errorText = _getErrorText(direction);
    });
    
    // Small bounce animation
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getErrorOffset(direction),
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    await Future.wait([
      _positionController.forward(),
      _scaleController.forward(),
      _errorController.forward(),
    ]);
    
    // Return to center
    await Future.delayed(const Duration(milliseconds: 500));
    
    await Future.wait([
      _positionController.reverse(),
      _scaleController.reverse(),
      _errorController.reverse(),
    ]);
    
    setState(() {
      _showError = false;
      _isAnimating = false;
    });
  }

  Offset _getErrorOffset(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return const Offset(-0.1, 0.0);
      case SwipeDirection.right:
        return const Offset(0.1, 0.0);
      case SwipeDirection.up:
        return const Offset(0.0, 0.1);
    }
  }

  String _getErrorText(SwipeDirection direction) {
    final correctAnswer = _getCorrectAnswer();
    switch (direction) {
      case SwipeDirection.left:
        return correctAnswer == ValueType.high ? 'Too HIGH! Swipe RIGHT →' : 
               correctAnswer == ValueType.normal ? 'NORMAL! Swipe DOWN ↓' : 'Wrong!';
      case SwipeDirection.right:
        return correctAnswer == ValueType.low ? 'Too LOW! Swipe LEFT ←' : 
               correctAnswer == ValueType.normal ? 'NORMAL! Swipe DOWN ↓' : 'Wrong!';
      case SwipeDirection.up:
        return correctAnswer == ValueType.low ? 'Too LOW! Swipe LEFT ←' : 
               correctAnswer == ValueType.high ? 'Too HIGH! Swipe RIGHT →' : 'Wrong!';
    }
  }

  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case ParameterDifficulty.easy:
        return Colors.green;
      case ParameterDifficulty.medium:
        return Colors.orange;
      case ParameterDifficulty.hard:
        return Colors.red;
      case ParameterDifficulty.legendary:
        return AppTheme.primaryNeon;
    }
  }

  String _getDifficultyText() {
    switch (widget.difficulty) {
      case ParameterDifficulty.easy:
        return 'EASY';
      case ParameterDifficulty.medium:
        return 'MEDIUM';
      case ParameterDifficulty.hard:
        return 'HARD';
      case ParameterDifficulty.legendary:
        return 'LEGENDARY';
    }
  }

  String _getSexContextText() {
    switch (widget.sexContext) {
      case SexContext.male:
        return '♂ MALE';
      case SexContext.female:
        return '♀ FEMALE';
      case SexContext.general:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (!_isAnimating) {
          final direction = _getSwipeDirection(details);
          _handleSwipe(direction);
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _positionAnimation,
          _scaleAnimation,
          _errorAnimation,
          _glowAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _positionAnimation.value.dx * MediaQuery.of(context).size.width,
              _positionAnimation.value.dy * MediaQuery.of(context).size.height,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.surfaceDark,
                      AppTheme.surfaceDark.withOpacity(0.8),
                      AppTheme.primaryNeon.withOpacity(0.1),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  border: Border.all(
                    color: _showError 
                        ? Colors.red.withOpacity(_errorAnimation.value)
                        : AppTheme.primaryNeon.withOpacity(_glowAnimation.value),
                    width: _showError ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _showError 
                          ? Colors.red.withOpacity(_errorAnimation.value * 0.5)
                          : AppTheme.primaryNeon.withOpacity(_glowAnimation.value * 0.3),
                      blurRadius: _showError ? 15 : 20,
                      spreadRadius: _showError ? 3 : 5,
                    ),
                    BoxShadow(
                      color: AppTheme.secondaryNeon.withOpacity(_glowAnimation.value * 0.2),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Difficulty badge
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getDifficultyColor(),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  _getDifficultyText(),
                                  style: TextStyle(
                                    color: _getDifficultyColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (_getSexContextText().isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryNeon.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.secondaryNeon,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    _getSexContextText(),
                                    style: const TextStyle(
                                      color: AppTheme.secondaryNeon,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Parameter name with Lottie logo
                          Row(
                            children: [
                              // Small logo animation
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: Lottie.asset(
                                  'assets/lottie/logo.json',
                                  repeat: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Parameter name
                              Expanded(
                                child: Text(
                                  widget.parameter.name,
                                  style: const TextStyle(
                                    color: AppTheme.textBright,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Parameter explanation
                          Text(
                            widget.parameter.explanation,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const Spacer(),
                          
                          // Value display
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  widget.displayValue,
                                  style: const TextStyle(
                                    color: AppTheme.textBright,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.unitData.unitSymbol,
                                  style: const TextStyle(
                                    color: AppTheme.secondaryNeon,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // Swipe hints
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildSwipeHint('← LOW', Colors.blue),
                              _buildSwipeHint('↑ NORMAL', Colors.green),
                              _buildSwipeHint('HIGH →', Colors.red),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Error overlay
                    if (_showError)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(_errorAnimation.value * 0.9),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: Text(
                            _errorText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSwipeHint(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color.withOpacity(0.7),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
