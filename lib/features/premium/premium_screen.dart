import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../core/routes/routes.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPaying = false;

  void _triggerPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPaying = true;
    });

    // Simulate Google Play Billing / Apple App Store purchase verification
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.buyPremium();

      setState(() {
        _isPaying = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Row(
              children: [
                Text("👑"),
                SizedBox(width: 8),
                Text("Premium Activated!"),
              ],
            ),
            content: const Text(
              "Thank you for upgrading! You now have full access to company specific placement packages, advanced analytical graphs, and an ad-free workspace.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop premium screen
                },
                child: const Text("Enter Premium Arena"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isGuest = !appState.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text("👑 Upgrade to Premium"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isGuest
          ? _buildGuestBlockView(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Promo card header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.premiumGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "SkillArena PRO",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                              ),
                              Text(
                                "₹99/mo",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Accelerate your campus placement preparation with unlimited mock assessments and premium question keys.",
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Feature details
                    const Text("VIP Membership Benefits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 12),
                    _buildPerkRow("Unlock Company Specific Placement Packs (Amazon, TCS, Infosys)"),
                    _buildPerkRow("Ad-free workspace (No banner, interstitial, or video ads)"),
                    _buildPerkRow("Unlimited quiz hints & explanations in timed modes"),
                    _buildPerkRow("Advanced analytics scorecard graphs & logs"),
                    _buildPerkRow("Exclusive 1v1 battle match tournaments"),
                    
                    const SizedBox(height: 32),

                    if (appState.isPremium) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.accentGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Membership Active", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  TextButton(
                                    onPressed: () {
                                      appState.cancelPremium();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Subscription deactivated.")),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text("Cancel Subscription", style: TextStyle(color: AppColors.accentPink, fontSize: 12)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ] else ...[
                      // Simulated Google Play Billing form
                      const Text("Simulated Payment Gateway", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDeco("Credit/Debit Card Number", Icons.credit_card),
                        validator: (val) {
                          if (val == null || val.length < 16) {
                            return "Please enter a valid 16-digit card";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDeco("Expiry Date (MM/YY)", Icons.date_range),
                              validator: (val) => val == null || val.isEmpty ? "Required" : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: _buildInputDeco("CVV", Icons.lock),
                              validator: (val) => val == null || val.length < 3 ? "Required" : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: _isPaying ? null : _triggerPayment,
                        child: _isPaying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                              )
                            : const Text("Activate Membership - ₹99/mo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildGuestBlockView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.all(32),
          decoration: AppTheme.glassBox(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header with premium gradient ring
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.premiumGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Authentication Required",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "You are currently exploring as a Guest. Guest mode does not support Premium activations because your progress, achievements, and transactions cannot be stored in the database.\n\nPlease log in or create a free account to upgrade your workspace.",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.auth);
                },
                child: const Text(
                  "Log In / Sign Up",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Go Back",
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerkRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.star, color: AppColors.accentYellow, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentPink, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accentPink, width: 1.5),
      ),
    );
  }
}
