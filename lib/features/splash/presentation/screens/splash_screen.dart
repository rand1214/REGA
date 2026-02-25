import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  int activeLight = 0;
  late AnimationController _loadingController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
    
    _scaleController.forward();
    _startAnimation();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _startAnimation() async {
    setState(() => activeLight = 0);
    
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => activeLight = 1);
    
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => activeLight = 2);
    
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    
    // Fade out before navigation
    await _fadeController.forward();
    if (!mounted) return;
    
    context.go('/welcome');
  }

  Widget _buildLight(Color color, bool isActive) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 3D Visor - outer shadow layer
        Positioned(
          top: -12,
          left: -10,
          right: -10,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.9),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // 3D Visor - main body
        Positioned(
          top: -10,
          left: -8,
          right: -8,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.58,
              child: Container(
                width: 101,
                height: 101,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    center: Alignment.center,
                    startAngle: 3.14,
                    endAngle: 6.28,
                    colors: [
                      const Color(0xFF050505),
                      const Color(0xFF1A1A1A),
                      const Color(0xFF2D2D2D),
                      const Color(0xFF1A1A1A),
                      const Color(0xFF050505),
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        // 3D Visor - inner edge highlight
        Positioned(
          top: -6,
          left: -4,
          right: -4,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.52,
              child: Container(
                width: 93,
                height: 93,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.grey.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0D0D0D),
            border: Border.all(
              color: Colors.black,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 8,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inactive state
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                opacity: isActive ? 0.0 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.25, 0.65, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Pixelated grid overlay
                      ClipOval(
                        child: CustomPaint(
                          painter: _PixelGridPainter(),
                          size: const Size(85, 85),
                        ),
                      ),
                      // Dotted outline
                      Center(
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.15),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Active state
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                opacity: isActive ? 1.0 : 0.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Bottom half glow
                    CustomPaint(
                      painter: _BottomGlowPainter(color),
                      size: const Size(85, 85),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            color.withValues(alpha: 1.0),
                            color.withValues(alpha: 0.85),
                            color.withValues(alpha: 0.6),
                          ],
                          stops: const [0.0, 0.25, 0.65, 1.0],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Pixelated grid overlay
                          ClipOval(
                            child: CustomPaint(
                              painter: _PixelGridPainter(),
                              size: const Size(85, 85),
                            ),
                          ),
                          // Dotted outline
                          Center(
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  width: 1.5,
                                  strokeAlign: BorderSide.strokeAlignInside,
                                ),
                              ),
                            ),
                          ),
                          // Center highlight
                          Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.7),
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
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
        ),
      ],
    );
  }

  Widget _buildLoadingDot(int index) {
    return AnimatedBuilder(
      animation: _loadingController,
      builder: (context, child) {
        final delay = index * 0.2;
        final value = (_loadingController.value - delay) % 1.0;
        final scale = value < 0.5
            ? 1.0 + (value * 2) * 0.6
            : 1.6 - ((value - 0.5) * 2) * 0.6;
        
        return Transform.scale(
          scale: scale.clamp(1.0, 1.6),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _BackgroundPainter(),
              ),
            ),
            Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 140),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF1A1A1A),
                        Color(0xFF4A4A4A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Rêga',
                      style: TextStyle(
                        fontFamily: 'Prototype',
                        fontSize: 64,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(4, 4),
                            blurRadius: 12,
                          ),
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(2, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Container(
                    width: 165,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: -5,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLight(Colors.red.shade700, activeLight == 0),
                        Container(
                          height: 2.5,
                          width: 85,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        _buildLight(Colors.amber.shade500, activeLight == 1),
                        Container(
                          height: 2.5,
                          width: 85,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        _buildLight(Colors.green.shade600, activeLight == 2),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLoadingDot(0),
                        const SizedBox(width: 14),
                        _buildLoadingDot(1),
                        const SizedBox(width: 14),
                        _buildLoadingDot(2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.5,
        colors: [
          Colors.white,
          const Color(0xFFFAFAFA),
          const Color(0xFFF5F5F5),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomGlowPainter extends CustomPainter {
  final Color color;
  
  _BottomGlowPainter(this.color);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw multiple layers for smooth fade
    for (int i = 3; i > 0; i--) {
      final layerRadius = radius + (i * 15.0);
      final opacity = 0.15 / i;
      
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 * i);
      
      // Draw only bottom half arc
      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: layerRadius),
        0,
        3.14159,
      );
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PixelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    const gridSize = 6.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
