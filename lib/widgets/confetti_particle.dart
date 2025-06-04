import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A particle system for celebratory confetti when the user hits streak milestones
class ConfettiParticleSystem extends StatefulWidget {
  final bool active;
  final Duration duration;
  final int particleCount;
  final Color? color;
  
  const ConfettiParticleSystem({
    Key? key, 
    this.active = false, 
    this.duration = const Duration(seconds: 3),
    this.particleCount = 50,
    this.color,
  }) : super(key: key);

  @override
  State<ConfettiParticleSystem> createState() => _ConfettiParticleSystemState();
}

class _ConfettiParticleSystemState extends State<ConfettiParticleSystem> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _generateParticles();
    
    if (widget.active) {
      _controller.forward(from: 0.0);
    }
  }
  
  @override
  void didUpdateWidget(ConfettiParticleSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.active && !_controller.isAnimating) {
      // Reset and generate new particles
      _generateParticles();
      _controller.forward(from: 0.0);
    }
  }
  
  void _generateParticles() {
    _particles = List.generate(widget.particleCount, (_) => ConfettiParticle(
      color: widget.color ?? _getRandomColor(),
      position: Offset(_random.nextDouble(), _random.nextDouble() * 0.2),
      size: 5.0 + _random.nextDouble() * 10.0,
      velocity: Offset(
        -0.5 + _random.nextDouble() * 1.0,  // x velocity (-0.5 to 0.5)
        -2.5 - _random.nextDouble() * 2.0,  // y velocity (upward)
      ),
      rotationSpeed: _random.nextDouble() * 0.2,
      shape: _random.nextInt(3),  // 0: circle, 1: square, 2: triangle
    ));
  }
  
  Color _getRandomColor() {
    final colors = [
      Colors.red.shade300,
      Colors.blue.shade300,
      Colors.green.shade300,
      Colors.yellow.shade300,
      Colors.orange.shade300,
      Colors.purple.shade300,
      AppTheme.primaryNeon,
      AppTheme.secondaryNeon,
    ];
    return colors[_random.nextInt(colors.length)];
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class ConfettiParticle {
  final Color color;
  Offset position;  // 0-1 based on screen size
  final double size;
  final Offset velocity;
  final double rotationSpeed;
  double rotation = 0;
  final int shape;  // 0: circle, 1: square, 2: triangle
  
  ConfettiParticle({
    required this.color,
    required this.position,
    required this.size,
    required this.velocity,
    required this.rotationSpeed,
    required this.shape,
  });
  
  void update(double dt, Size screenSize) {
    // Add gravity
    final velocityWithGravity = Offset(
      velocity.dx,
      velocity.dy + 0.05, // gravity
    );
    
    // Update position based on velocity
    position = Offset(
      position.dx + (velocityWithGravity.dx * dt),
      position.dy + (velocityWithGravity.dy * dt),
    );
    
    // Update rotation
    rotation += rotationSpeed;
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  
  ConfettiPainter({
    required this.particles,
    required this.progress,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    
    final paint = Paint();
    
    for (final particle in particles) {
      // Update particle physics
      particle.update(0.05, size);
      
      // Calculate actual position on screen
      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );
      
      paint.color = particle.color.withOpacity(
        progress < 0.7 ? 1.0 : 1.0 - ((progress - 0.7) / 0.3),
      );
      
      // Save the current canvas state
      canvas.save();
      
      // Move to particle position and rotate
      canvas.translate(position.dx, position.dy);
      canvas.rotate(particle.rotation);
      
      // Draw different shapes based on particle type
      switch (particle.shape) {
        case 0:  // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
          break;
        case 1:  // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2:  // Triangle
          final path = Path();
          path.moveTo(0, -particle.size / 2);
          path.lineTo(particle.size / 2, particle.size / 2);
          path.lineTo(-particle.size / 2, particle.size / 2);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
      
      // Restore the canvas state
      canvas.restore();
    }
  }
  
  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
