import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class MockAdWidgets {
  static void showInterstitialAd(BuildContext context, {required VoidCallback onClosed}) {
    final appState = Provider.of<AppState>(context, listen: false);
    final isPremium = appState.isPremium;
    final adFrequency = appState.adFrequency;
    if (isPremium || adFrequency == 'Ad-Free') {
      onClosed();
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _InterstitialAdDialog(onClosed: onClosed);
      },
    );
  }

  static void showRewardedAd(BuildContext context, {required VoidCallback onRewardEarned}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.95),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return _RewardedAdDialog(onRewardEarned: onRewardEarned);
      },
    );
  }
}

class MockBannerAd extends StatelessWidget {
  const MockBannerAd({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isPremium = appState.isPremium;
    final adFrequency = appState.adFrequency;
    if (isPremium || adFrequency == 'Ad-Free') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Become Placement Ready with SkillArena Premium!",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  "No Ads • Unlimited Hints • Premium Questions • ₹99/mo",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "AD",
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InterstitialAdDialog extends StatefulWidget {
  final VoidCallback onClosed;
  const _InterstitialAdDialog({required this.onClosed});

  @override
  State<_InterstitialAdDialog> createState() => _InterstitialAdDialogState();
}

class _InterstitialAdDialogState extends State<_InterstitialAdDialog> {
  int _secondsRemaining = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _secondsRemaining = 0;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "SPONSORED AD",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentOrange),
                    ),
                  ),
                  _secondsRemaining > 0
                      ? Text(
                          "Close in ${_secondsRemaining}s",
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        )
                      : IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onClosed();
                          },
                        ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.orangeGradient,
                ),
                child: const Icon(Icons.rocket_launch, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text(
                "CodeCraft Pro",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Learn Advanced System Design & Coding. Master interviews with interactive real-time editor exercises and mock code reviews.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text("Install App"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardedAdDialog extends StatefulWidget {
  final VoidCallback onRewardEarned;
  const _RewardedAdDialog({required this.onRewardEarned});

  @override
  State<_RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<_RewardedAdDialog> {
  int _secondsRemaining = 5;
  Timer? _timer;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress -= 0.02;
        if (_progress <= 0) {
          _progress = 0;
          _secondsRemaining = 0;
          _timer?.cancel();
        } else {
          _secondsRemaining = (_progress * 5).ceil();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.glassBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "VIDEO AD",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentPink),
                    ),
                  ),
                  _secondsRemaining > 0
                      ? Text(
                          "Reward in ${_secondsRemaining}s",
                          style: const TextStyle(color: AppColors.accentPink, fontSize: 13, fontWeight: FontWeight.bold),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "REWARD UNLOCKED",
                            style: TextStyle(color: AppColors.accentGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 24),
              // Simulated Video Player container
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gradient animated pulses
                    Opacity(
                      opacity: 0.3,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.pinkGradient,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_fill, size: 48, color: AppColors.accentPink),
                        const SizedBox(height: 8),
                        Text(
                          "SkillArena Ad: Placement Boosters",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Watch 5 seconds to claim 50 free coins!",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentPink),
              ),
              const SizedBox(height: 24),
              _secondsRemaining > 0
                  ? TextButton(
                      onPressed: null,
                      style: TextButton.styleFrom(
                        disabledForegroundColor: AppColors.textMuted,
                      ),
                      child: const Text("Skip Video (No Reward)"),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onRewardEarned();
                      },
                      child: const Text("Claim Reward"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
