import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medical_models.dart';
import '../utils/theme.dart';

// Particle class for success animation
class Particle {
  final Color color;
  final double size;
  final double initialDirection;
  final double speed;
  double x = 0;
  double y = 0;
  
  Particle({
    required this.color,
    required this.size,
    required this.initialDirection,
    required this.speed,
  });
  
  void update(double animationValue) {
    // Update particle position based on direction and animation progress
    final distance = speed * animationValue;
    x = math.cos(initialDirection) * distance;
    y = math.sin(initialDirection) * distance - 
        (30 * animationValue * animationValue); // Apply gravity-like effect
  }
}

// Custom painter to render particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  
  ParticlePainter({
    required this.particles,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final particle in particles) {
      // Calculate particle position
      final position = center.translate(particle.x, particle.y);
      
      // Calculate opacity based on animation progress
      final opacity = 1.0 - animationValue;
      
      // Draw particle
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.srcOver;
      
      canvas.drawCircle(position, particle.size * (1.0 - animationValue * 0.5), paint);
      
      // Add glow effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(position, particle.size * 1.3 * (1.0 - animationValue * 0.5), glowPaint);
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}

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
    super.key,
    required this.parameter,
    required this.value,
    required this.unitData,
    required this.displayValue,
    required this.difficulty,
    required this.sexContext,
    required this.onCorrectSwipe,
    required this.onWrongSwipe,
    required this.onSwipe,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late AnimationController _errorController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _errorAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  
  bool _isAnimating = false;
  bool _showError = false;
  bool _showSuccess = false;
  String _errorText = '';
  
  // For success particles
  final List<Color> _particleColors = [
    Colors.green,
    AppTheme.primaryNeon,
    Colors.cyanAccent,
    Colors.yellowAccent,
  ];
  final List<Particle> _particles = [];

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
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

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
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));
    
    // Generate particle effects
    _generateParticles();
    
    // Listen to particle animation
    _particleController.addListener(() {
      if (_showSuccess && mounted) {
        setState(() {}); // Redraw particles
      }
    });
  }
  
  void _generateParticles() {
    final rnd = math.Random();
    _particles.clear();
    
    // Generate 20 particles for success animation
    for (int i = 0; i < 20; i++) {
      final color = _particleColors[rnd.nextInt(_particleColors.length)];
      final size = rnd.nextDouble() * 12 + 5;  // 5-17 pixel particles
      final initialDirection = rnd.nextDouble() * math.pi * 2; // Random direction
      final speed = rnd.nextDouble() * 100 + 50; // 50-150 pixels per second
      
      _particles.add(Particle(
        color: color,
        size: size,
        initialDirection: initialDirection,
        speed: speed,
      ));
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    _errorController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
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
    // Stronger haptic feedback on correct answer
    HapticFeedback.mediumImpact();
    
    // Show success particles
    setState(() {
      _showSuccess = true;
    });
    
    // Scale up slightly
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15, // Scale up more for correct answers
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    // Start particle animation
    _particleController.forward(from: 0.0);
    
    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 200)); // Hold briefly to see the effect
    
    // Fly out in swipe direction with nice physics
    Offset targetOffset;
    switch (direction) {
      case SwipeDirection.left:
        targetOffset = const Offset(-2.5, 0.0);
        break;
      case SwipeDirection.right:
        targetOffset = const Offset(2.5, 0.0);
        break;
      case SwipeDirection.up:
        targetOffset = const Offset(0.0, -2.5); // Changed to negative for upward motion
        break;
    }
    
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeInOutBack,
    ));
    
    await _positionController.forward();
    
    // Reset success state for next card
    setState(() {
      _showSuccess = false;
    });
  }

  Future<void> _animateWrongSwipe(SwipeDirection direction) async {
    // More intense haptic feedback for wrong answers
    HapticFeedback.heavyImpact();
    
    // Show error state with visual feedback
    setState(() {
      _showError = true;
      _errorText = _getErrorText(direction);
    });
    
    // Small bounce animation with more realistic physics
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: _getErrorOffset(direction),
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.elasticOut,
    ));
    
    // Shake and scale down slightly
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92, // Scale down more for emphasis
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
    
    await Future.wait([
      _positionController.forward(),
      _scaleController.forward(),
      _errorController.forward(),
    ]);
    
    // Hold error state longer so user can read the message
    await Future.delayed(const Duration(milliseconds: 800));
    
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

  // ... (rest of the code remains the same)

  @override
  Widget build(BuildContext context) {
    // Update particles if success animation is active
    if (_showSuccess) {
      for (final particle in _particles) {
        particle.update(_particleAnimation.value);
      }
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (_isAnimating) return;
        
        final velocity = details.velocity.pixelsPerSecond;
        final SwipeDirection direction;
        
        if (velocity.dx > 500) {
          direction = SwipeDirection.right;
        } else if (velocity.dx < -500) {
          direction = SwipeDirection.left;
        } else {
          return; // Not enough velocity to trigger
        }
        
        _handleSwipe(direction);
      },
      onVerticalDragEnd: (details) {
        if (_isAnimating) return;
        
        final velocity = details.velocity.pixelsPerSecond;
        if (velocity.dy < -500) {
          _handleSwipe(SwipeDirection.up);
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Success particles layer (drawn behind card)
                if (_showSuccess)
                  AnimatedBuilder(
                    animation: _particleAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(300, 400),
                        painter: ParticlePainter(
                          particles: _particles,
                          animationValue: _particleAnimation.value,
                        ),
                      );
                    },
                  ),
                // Card layer
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Transform.translate(
                    offset: _positionAnimation.value,
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
                                const SizedBox(height: 20),
                                
                                // Parameter name
                                Text(
                                  widget.parameter.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Parameter explanation
                                Text(
                                  widget.parameter.explanation,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                
                                const Spacer(),
                                
                                // Value display
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.displayValue,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.unitData.unitSymbol,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const Spacer(),
                                
                                // Swipe instructions
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        'Swipe to classify',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Error overlay
                          if (_showError)
                            Positioned.fill(
                              child: AnimatedOpacity(
                                opacity: _errorAnimation.value,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        _errorText,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
