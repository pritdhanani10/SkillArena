import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Premium App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // App Name
                      Text(
                        'SkillArena',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [Colors.white, AppColors.primary, AppColors.secondary],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tagline
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTagDot(Colors.redAccent),
                          const SizedBox(width: 8),
                          const Text(
                            'Play',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildTagDot(Colors.tealAccent),
                          const SizedBox(width: 8),
                          const Text(
                            'Learn',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildTagDot(Colors.amberAccent),
                          const SizedBox(width: 8),
                          const Text(
                            'Get Placed',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Loading indicator
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTagDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ],
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glowing outer circle
    final glowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, radius - 5, glowPaint);

    // Inner shield/arena base
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.65)
      ..quadraticBezierTo(size.width / 2, size.height * 0.95, size.width * 0.2, size.height * 0.65)
      ..close();

    final shieldGradient = const LinearGradient(
      colors: [AppColors.primary, AppColors.secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final shieldPaint = Paint()
      ..shader = shieldGradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, shieldPaint);

    // Inner grid/pattern details (cyber arena effect)
    final linesPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawLine(Offset(size.width * 0.35, size.height * 0.2), Offset(size.width * 0.35, size.height * 0.74), linesPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.2), Offset(size.width * 0.5, size.height * 0.81), linesPaint);
    canvas.drawLine(Offset(size.width * 0.65, size.height * 0.2), Offset(size.width * 0.65, size.height * 0.74), linesPaint);
    
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.45), Offset(size.width * 0.8, size.height * 0.45), linesPaint);
    canvas.drawLine(Offset(size.width * 0.21, size.height * 0.6), Offset(size.width * 0.79, size.height * 0.6), linesPaint);

    // Core star/trophy glyph
    final glyphPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final glyphPath = Path();
    double cx = size.width / 2;
    double cy = size.height * 0.42;
    int points = 5;
    double outerRadius = 14;
    double innerRadius = 6;
    double rot = 3.14159 / 2 * 3;
    double step = 3.14159 / points;

    glyphPath.moveTo(cx, cy - outerRadius);
    for (int i = 0; i < points; i++) {
      double x = cx + MathCos(rot) * outerRadius;
      double y = cy + MathSin(rot) * outerRadius;
      glyphPath.lineTo(x, y);
      rot += step;

      x = cx + MathCos(rot) * innerRadius;
      y = cy + MathSin(rot) * innerRadius;
      glyphPath.lineTo(x, y);
      rot += step;
    }
    glyphPath.close();
    canvas.drawPath(glyphPath, glyphPaint);

    // Banner underneath the star
    final bannerPaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;
    
    final bannerPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.62)
      ..lineTo(size.width * 0.65, size.height * 0.62)
      ..lineTo(size.width * 0.6, size.height * 0.68)
      ..lineTo(size.width * 0.4, size.height * 0.68)
      ..close();
    
    canvas.drawPath(bannerPath, bannerPaint);
  }

  // Simple math helper approximations to avoid full math imports
  double MathCos(double radians) {
    // Basic approximation of Cosine
    double x = radians % (2 * 3.14159);
    if (x < 0) x += 2 * 3.14159;
    double val = 1.0 - (x * x / 2) + (x * x * x * x / 24) - (x * x * x * x * x * x / 720);
    if (x > 1.5707 && x < 4.7123) {
      return -val.abs();
    }
    return val.abs();
  }
  
  double MathSin(double radians) {
    // Basic approximation of Sine
    double x = radians % (2 * 3.14159);
    if (x < 0) x += 2 * 3.14159;
    double val = x - (x * x * x / 6) + (x * x * x * x * x / 120) - (x * x * x * x * x * x * x / 5040);
    if (x > 3.14159) {
      return -val.abs();
    }
    return val.abs();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
