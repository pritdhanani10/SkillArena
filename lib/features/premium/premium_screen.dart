import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../core/routes/routes.dart';

enum PremiumAnimationState { none, purchaseSuccess, cancelSuccess }

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPaying = false;

  // Controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // Focus Nodes
  final _cardNumberFocus = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvvFocus = FocusNode();
  final _cardHolderFocus = FocusNode();

  bool _showBack = false;
  PremiumAnimationState _animationState = PremiumAnimationState.none;

  @override
  void initState() {
    super.initState();
    _cvvFocus.addListener(_onCvvFocusChange);
    _cardNumberController.addListener(_onCardDataChanged);
    _expiryController.addListener(_onCardDataChanged);
    _cvvController.addListener(_onCardDataChanged);
    _cardHolderController.addListener(_onCardDataChanged);
  }

  @override
  void dispose() {
    _cvvFocus.removeListener(_onCvvFocusChange);
    _cardNumberController.removeListener(_onCardDataChanged);
    _expiryController.removeListener(_onCardDataChanged);
    _cvvController.removeListener(_onCardDataChanged);
    _cardHolderController.removeListener(_onCardDataChanged);

    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();

    _cardNumberFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    _cardHolderFocus.dispose();
    super.dispose();
  }

  void _onCvvFocusChange() {
    setState(() {
      _showBack = _cvvFocus.hasFocus;
    });
  }

  void _onCardDataChanged() {
    setState(() {});
  }

  String _getCardBrand() {
    final cleanNumber = _cardNumberController.text.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (RegExp(r'^5[1-5]').hasMatch(cleanNumber) || RegExp(r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[0-1][0-9]|720)').hasMatch(cleanNumber)) {
      return 'Mastercard';
    } else if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      return 'Amex';
    } else if (cleanNumber.startsWith('60') || cleanNumber.startsWith('65') || cleanNumber.startsWith('81') || cleanNumber.startsWith('82')) {
      return 'RuPay';
    } else if (cleanNumber.startsWith('6011') || cleanNumber.startsWith('65') || cleanNumber.startsWith('64')) {
      return 'Discover';
    }
    return 'Unknown';
  }

  void _triggerPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isPaying = true;
    });

    // Simulate Payment Gateway checkout verification
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.buyPremium();

      setState(() {
        _isPaying = false;
        _animationState = PremiumAnimationState.purchaseSuccess;
      });

      // Immersive checkmark celebration screen for 2.6s, then transition into subscription overview
      await Future.delayed(const Duration(milliseconds: 2600));
      if (mounted) {
        setState(() {
          _animationState = PremiumAnimationState.none;
        });
      }
    }
  }

  void _triggerCancelSubscription(AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cancel Premium Subscription?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Active Plan", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text("SkillArena PRO", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 18),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Billing Cycle", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text("Monthly (Simulated)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Membership Cost", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text("₹99/mo", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Warning: You will lose access to amazon, tcs, and infosys prep packs, unlimited hints, and ad-free workspace immediately.",
                style: TextStyle(fontSize: 12, color: AppColors.accentPink, height: 1.4, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 46),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Keep Benefits", style: TextStyle(color: AppColors.textPrimary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(double.infinity, 46),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop(); // pop sheet
                        setState(() {
                          _animationState = PremiumAnimationState.cancelSuccess;
                        });
                        appState.cancelPremium();
                        
                        await Future.delayed(const Duration(milliseconds: 2500));
                        if (mounted) {
                          setState(() {
                            _animationState = PremiumAnimationState.none;
                          });
                        }
                      },
                      child: const Text("Confirm Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final bool isGuest = !appState.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text("👑 Upgrade to Premium", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          isGuest
              ? _buildGuestBlockView(context)
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  physics: const BouncingScrollPhysics(),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: appState.isPremium
                            ? KeyedSubtree(
                                key: const ValueKey('premium_active_view'),
                                child: _buildActivePremiumView(context, appState),
                              )
                            : KeyedSubtree(
                                key: const ValueKey('checkout_form_view'),
                                child: _buildCheckoutFormView(context, appState),
                              ),
                      ),
                    ),
                  ),
                ),
          
          // Purchase Success overlay
          if (_animationState == PremiumAnimationState.purchaseSuccess)
            _buildSuccessOverlay(),

          // Cancel Success overlay
          if (_animationState == PremiumAnimationState.cancelSuccess)
            _buildCancelSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildCheckoutFormView(BuildContext context, AppState appState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic animated card preview
          AnimatedCardPreview(
            cardNumber: _cardNumberController.text,
            cardHolder: _cardHolderController.text,
            expiryDate: _expiryController.text,
            cvv: _cvvController.text,
            showBack: _showBack,
            cardBrand: _getCardBrand(),
          ),
          const SizedBox(height: 28),

          // VIP Perk details
          const Text("VIP Membership Benefits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildPerkRow("Unlock Amazon, TCS, Infosys Company Assessment Packs"),
          _buildPerkRow("100% Ad-free experience (No banners or video popups)"),
          _buildPerkRow("Unlimited quiz hints & explanations in timed practice modes"),
          _buildPerkRow("Advanced analytics dashboard logs & scorecards"),

          const SizedBox(height: 28),
          const Text("Simulated Payment Form", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 12),

          // Card number field
          TextFormField(
            controller: _cardNumberController,
            focusNode: _cardNumberFocus,
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.number,
            inputFormatters: [
              CardNumberInputFormatter(),
            ],
            decoration: _buildInputDeco("Credit/Debit Card Number", Icons.credit_card),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return "Card number is required";
              }
              final clean = val.replaceAll(' ', '');
              if (clean.length != 16) {
                return "Enter a valid 16-digit card number";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Card holder field
          TextFormField(
            controller: _cardHolderController,
            focusNode: _cardHolderFocus,
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.name,
            inputFormatters: [
              CardHolderNameInputFormatter(),
            ],
            decoration: _buildInputDeco("Card Holder Name", Icons.person_outline),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return "Card holder name is required";
              }
              if (val.trim().length < 3) {
                return "Name must be at least 3 characters";
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Expiry and CVV Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  focusNode: _expiryFocus,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    ExpiryDateInputFormatter(),
                  ],
                  decoration: _buildInputDeco("Expiry (MM/YY)", Icons.date_range),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Required";
                    }
                    final parts = val.split('/');
                    if (parts.length != 2) {
                      return "Invalid format";
                    }
                    final month = int.tryParse(parts[0]);
                    final year = int.tryParse(parts[1]);
                    if (month == null || month < 1 || month > 12) {
                      return "Invalid month";
                    }
                    if (year == null || year < 26 || year > 40) {
                      return "Invalid year";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  focusNode: _cvvFocus,
                  style: const TextStyle(color: AppColors.textPrimary),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    CvvInputFormatter(),
                  ],
                  decoration: _buildInputDeco("CVV", Icons.lock_outline),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Required";
                    }
                    if (val.length < 3 || val.length > 4) {
                      return "3-4 digits CVV";
                    }
                    return null;
                  },
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActivePremiumView(BuildContext context, AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promo card header showing PRO status
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 15,
                offset: const Offset(0, 4),
              )
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SkillArena PRO",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text("ACTIVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "You have full access to placement preparation packs, memory games, vocabulary trackers, and ad-free assessments.",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        const Text("Active Benefits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        _buildPerkRow("Access Amazon, TCS, Infosys Company assessment modules"),
        _buildPerkRow("No advertisement banners or interstitial popups"),
        _buildPerkRow("Unlimited hints & step-by-step quiz answer logs"),
        _buildPerkRow("Full analytics scorecard & mock logs data tracking"),
        
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassBox(
            border: Border.all(color: AppColors.accentGreen.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    "Subscription Details",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Plan Name", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text("SkillArena PRO Membership", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12)),
                ],
              ),
              const Divider(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Price", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text("₹99/mo (Simulated)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Renewal Date", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(
                    _getRenewalDateString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPink.withOpacity(0.12),
                  foregroundColor: AppColors.accentPink,
                  side: const BorderSide(color: AppColors.accentPink, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => _triggerCancelSubscription(appState),
                child: const Text("Cancel Premium Subscription", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _getRenewalDateString() {
    final now = DateTime.now();
    final renewalDate = DateTime(now.year, now.month + 1, now.day);
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[renewalDate.month - 1]} ${renewalDate.day}, ${renewalDate.year}";
  }

  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.background.withOpacity(0.95),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: AppTheme.glassBox(
                border: Border.all(color: AppColors.accentGreen.withOpacity(0.5), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentGreen.withOpacity(0.12),
                      border: Border.all(color: AppColors.accentGreen, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.accentGreen,
                        size: 54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Payment Successful",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your membership is active! Access premium features instantly.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelSuccessOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.background.withOpacity(0.95),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: AppTheme.glassBox(
                border: Border.all(color: AppColors.accentPink.withOpacity(0.5), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentPink.withOpacity(0.12),
                      border: Border.all(color: AppColors.accentPink, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.remove_shopping_cart_outlined,
                        color: AppColors.accentPink,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Subscription Cancelled",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your membership has been reverted back to the free plan.",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPink),
                    ),
                  ),
                ],
              ),
            ),
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
                  color: AppColors.textPrimary,
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

class AnimatedCardPreview extends StatelessWidget {
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final bool showBack;
  final String cardBrand;

  const AnimatedCardPreview({
    super.key,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.cvv,
    required this.showBack,
    required this.cardBrand,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showBack ? 180 : 0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, val, child) {
        final angle = val * math.pi / 180.0;
        final isBack = val >= 90.0;
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // perspective depth
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _buildCardBack(),
                )
              : _buildCardFront(),
        );
      },
    );
  }

  Widget _buildCardFront() {
    final displayNo = cardNumber.isEmpty ? "•••• •••• •••• ••••" : cardNumber;
    final displayName = cardHolder.isEmpty ? "CARDHOLDER NAME" : cardHolder.toUpperCase();
    final displayExpiry = expiryDate.isEmpty ? "MM/YY" : expiryDate;

    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.contactless, color: Colors.white, size: 28),
              _buildBrandEmblem(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            displayNo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "CARD HOLDER",
                      style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EXPIRES",
                    style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayExpiry,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    final displayCvv = cvv.isEmpty ? "•••" : cvv;

    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 44,
            color: Colors.black.withOpacity(0.85),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Container(
                  width: 65,
                  height: 38,
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: Text(
                    displayCvv,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AUTHORIZED SIGNATURE",
                  style: TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.bold),
                ),
                _buildBrandEmblem(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandEmblem() {
    Color cardColor;
    String symbol;
    switch (cardBrand) {
      case 'Visa':
        cardColor = Colors.blue.shade900;
        symbol = 'VISA';
        break;
      case 'Mastercard':
        cardColor = Colors.red.shade700;
        symbol = 'MC';
        break;
      case 'Amex':
        cardColor = Colors.cyan.shade600;
        symbol = 'AMEX';
        break;
      case 'RuPay':
        cardColor = Colors.teal.shade800;
        symbol = 'RuPay';
        break;
      case 'Discover':
        cardColor = Colors.amber.shade900;
        symbol = 'DISCOVER';
        break;
      default:
        cardColor = Colors.white12;
        symbol = 'CARD';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Text(
        symbol,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length > 16) {
      return oldValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      buffer.write(cleanDigits[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != cleanDigits.length) {
        buffer.write(' ');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length > 4) {
      return oldValue;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < cleanDigits.length; i++) {
      buffer.write(cleanDigits[i]);
      if (i == 1 && cleanDigits.length > 2) {
        buffer.write('/');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CvvInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.length > 4) {
      return oldValue;
    }
    return TextEditingValue(
      text: cleanDigits,
      selection: TextSelection.collapsed(offset: cleanDigits.length),
    );
  }
}

class CardHolderNameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cleanName = newValue.text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
    return TextEditingValue(
      text: cleanName,
      selection: TextSelection.collapsed(offset: cleanName.length),
    );
  }
}
