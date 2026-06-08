import 'package:flutter/material.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    // Header Widget
    final Widget logoHeader = Row(
      mainAxisAlignment: isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'SkillArena',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );

    // Illustration Banner Widget
    final Widget bannerCard = Container(
      height: isWide ? 300 : 240,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/welcome_banner.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    "PLAY. STUDY. WIN.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Title and Subtitle Text Column
    final Widget textContent = Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Become Placement Ready\nthrough Fun Learning',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: isWide ? 34 : 28,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Gamified aptitude tests, coding challenges, resume builders, and multiplayer matches. Explore all features completely free.',
          textAlign: isWide ? TextAlign.left : TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );

    // Buttons Widget
    final Widget actionButtons = Column(
      children: [
        // Let's Explore (Direct Guest Entrance)
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
          },
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Let's Explore",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Login/Signup Action
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.auth);
          },
          child: const Text(
            "Login / Signup",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

    final Widget narrowBody = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    logoHeader,
                    bannerCard,
                    textContent,
                    const SizedBox(height: 24),
                    actionButtons,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    final Widget wideBody = SafeArea(
      child: Row(
        children: [
          // Left interactive panel
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  logoHeader,
                  const SizedBox(height: 48),
                  textContent,
                  const SizedBox(height: 48),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: actionButtons,
                  ),
                ],
              ),
            ),
          ),
          // Right graphics panel
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: WelcomeGraphicsPainter(),
                  ),
                ),
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: bannerCard,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background ambient lights
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.12),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),
          // Content
          isWide ? wideBody : narrowBody,
        ],
      ),
    );
  }
}

class WelcomeGraphicsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill background gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0F121F), Color(0xFF191E36)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw glowing circles
    final glowPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 60, glowPaint);
    glowPaint.color = AppColors.primary.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 80, glowPaint);

    // Paint a cyber grid floor
    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.4)
      ..strokeWidth = 1.0;
    
    double startY = size.height * 0.5;
    for (int i = 0; i <= 10; i++) {
      double pct = i / 10;
      double x = size.width * pct;
      canvas.drawLine(Offset(x, startY), Offset(size.width * (0.5 + (pct - 0.5) * 2.5), size.height), gridPaint);
    }
    
    for (int i = 0; i < 6; i++) {
      double pct = i / 5;
      double y = startY + (size.height - startY) * (pct * pct);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Paint books/dashboard element in center
    final center = Offset(size.width / 2, size.height * 0.45);

    // Draw circular cyber glow ring
    final ringPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 120, height: 40),
      ringPaint,
    );

    // Trophy cup painter
    final trophyPaint = Paint()..color = AppColors.accentYellow;
    final trophyGlow = Paint()
      ..color = AppColors.accentYellow.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    
    canvas.drawCircle(center - const Offset(0, 8), 12, trophyGlow);
    canvas.drawCircle(center - const Offset(0, 8), 12, trophyPaint);
    
    // Stem
    canvas.drawRect(Rect.fromLTWH(center.dx - 3, center.dy, 6, 15), trophyPaint);
    // Base
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 12, center.dy + 15, 24, 6), const Radius.circular(3)),
      trophyPaint,
    );
    
    // Handles
    final handlePaint = Paint()
      ..color = AppColors.accentYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawArc(
      Rect.fromCenter(center: center - const Offset(10, 8), width: 14, height: 16),
      1.57,
      3.14,
      false,
      handlePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: center + const Offset(10, -8), width: 14, height: 16),
      -1.57,
      3.14,
      false,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
