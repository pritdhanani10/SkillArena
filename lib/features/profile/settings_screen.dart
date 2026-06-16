import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../shared/widgets/fade_in_slide.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isUnlocked = false;
  String _enteredPin = "";

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.mpinEnabled && !_isUnlocked) {
      return _buildLockScreen(context, appState);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background subtle ambient lights
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 100,
                    spreadRadius: 50,
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom Premium Glassmorphic AppBar
                SliverAppBar(
                  expandedHeight: 80.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: const Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // Settings Contents list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Section: Visual & Preference Styling
                      const FadeInSlide(
                        delay: 50,
                        child: _SectionHeader(title: "VISUALS & PREFERENCES"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 80,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSwitchSetting(
                                context: context,
                                title: "Dark Mode Theme",
                                subtitle: "Toggle high-contrast dark vs clean light interface",
                                icon: appState.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                                value: appState.isDarkMode,
                                onChanged: (val) => appState.toggleDarkMode(val),
                              ),
                              const Divider(height: 24),
                              const Text(
                                "Accent Styling Palette",
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 10),
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.15,
                                children: [
                                  _buildThemeOption(context, appState, 'cyberpunk', 'Cyberpunk', [const Color(0xFF7C3AED), const Color(0xFF06B6D4)]),
                                  _buildThemeOption(context, appState, 'emerald', 'Forest', [const Color(0xFF10B981), const Color(0xFF34D399)]),
                                  _buildThemeOption(context, appState, 'sunset', 'Synthwave', [const Color(0xFFEC4899), const Color(0xFFF97316)]),
                                  _buildThemeOption(context, appState, 'glacier', 'Glacier', [const Color(0xFF0EA5E9), const Color(0xFF22D3EE)]),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildActionItem(
                                context: context,
                                title: "App Language",
                                subtitle: "Active translation: ${appState.language}",
                                icon: Icons.translate_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () => _showLanguageSelector(context, appState),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Membership & Billing
                      const FadeInSlide(
                        delay: 90,
                        child: _SectionHeader(title: "MEMBERSHIP & BILLING"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 100,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(
                            border: appState.isPremium 
                                ? Border.all(color: AppColors.secondary.withOpacity(0.4))
                                : null,
                          ),
                          child: _buildActionItem(
                            context: context,
                            title: appState.isPremium ? "Active Premium Plan" : "Upgrade to Premium",
                            subtitle: appState.isPremium 
                                ? "Manage your subscription, renewal date, or cancel" 
                                : "Unlock all placement preparation packages, ad-free experience",
                            icon: appState.isPremium ? Icons.verified : Icons.workspace_premium_outlined,
                            color: appState.isPremium ? AppColors.secondary : Theme.of(context).colorScheme.primary,
                            onTap: () {
                              Navigator.of(context).pushNamed("/premium");
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Audio & Feedback
                      const FadeInSlide(
                        delay: 110,
                        child: _SectionHeader(title: "AUDIO & HAPTICS"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 150,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: Column(
                            children: [
                              _buildSwitchSetting(
                                context: context,
                                title: "Sound Effects",
                                subtitle: "Play audio responses on scoring & interaction",
                                icon: Icons.volume_up_outlined,
                                value: appState.soundEffectsEnabled,
                                onChanged: (val) => appState.toggleSound(val),
                              ),
                              const Divider(height: 24),
                              _buildSwitchSetting(
                                context: context,
                                title: "Haptics Simulation",
                                subtitle: "Simulate tactile vibrations for dashboard events",
                                icon: Icons.vibration_outlined,
                                value: appState.hapticsEnabled,
                                onChanged: (val) => appState.toggleHaptics(val),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Placement & Arena Configuration
                      const FadeInSlide(
                        delay: 200,
                        child: _SectionHeader(title: "PLACEMENT ARENA CONFIG"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 250,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: Column(
                            children: [
                              _buildDropdownSetting<int>(
                                context: context,
                                title: "Quiz Timer Limit",
                                subtitle: "Choose default duration for timed aptitude quizzes",
                                icon: Icons.timer_outlined,
                                value: appState.quizTimeLimit,
                                items: const [
                                  DropdownMenuItem(value: 10, child: Text("10 seconds")),
                                  DropdownMenuItem(value: 20, child: Text("20 seconds")),
                                  DropdownMenuItem(value: 30, child: Text("30 seconds")),
                                ],
                                onChanged: (val) {
                                  if (val != null) appState.setQuizTimeLimit(val);
                                },
                              ),
                              const Divider(height: 24),
                              _buildDropdownSetting<String>(
                                context: context,
                                title: "Mock Interview Rigor",
                                subtitle: "Configure strictness & response keywords matching",
                                icon: Icons.gavel_outlined,
                                value: appState.interviewRigor,
                                items: const [
                                  DropdownMenuItem(value: "Lenient", child: Text("Lenient")),
                                  DropdownMenuItem(value: "Standard", child: Text("Standard")),
                                  DropdownMenuItem(value: "Strict", child: Text("Strict")),
                                ],
                                onChanged: (val) {
                                  if (val != null) appState.setInterviewRigor(val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Advertisement Config
                      const FadeInSlide(
                        delay: 300,
                        child: _SectionHeader(title: "ADVERTISEMENTS"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 350,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: _buildDropdownSetting<String>(
                            context: context,
                            title: "Simulated Ad Frequency",
                            subtitle: "Select mock advertisement trigger frequency",
                            icon: Icons.ad_units_outlined,
                            value: appState.adFrequency,
                            items: const [
                              DropdownMenuItem(value: "Standard", child: Text("Standard")),
                              DropdownMenuItem(value: "Ad-Free", child: Text("Ad-Free")),
                              DropdownMenuItem(value: "Developer Test", child: Text("Dev Mode")),
                            ],
                            onChanged: (val) {
                              if (val != null) appState.setAdFrequency(val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Security Settings
                      const FadeInSlide(
                        delay: 380,
                        child: _SectionHeader(title: "SECURITY CONTROLS"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 420,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: Column(
                            children: [
                              _buildSwitchSetting(
                                context: context,
                                title: "MPIN Lock Protection",
                                subtitle: "Require 4-digit PIN lock when opening settings",
                                icon: Icons.security_outlined,
                                value: appState.mpinEnabled,
                                onChanged: (val) {
                                  if (val) {
                                    _promptToSetMpin(context, appState);
                                  } else {
                                    _promptToDisableMpin(context, appState);
                                  }
                                },
                              ),
                              if (appState.mpinEnabled) ...[
                                const Divider(height: 24),
                                _buildActionItem(
                                  context: context,
                                  title: "Change Security MPIN",
                                  subtitle: "Update your settings security PIN code",
                                  icon: Icons.pin_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  onTap: () {
                                    _promptToChangeMpin(context, appState);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: System & Data Control
                      const FadeInSlide(
                        delay: 400,
                        child: _SectionHeader(title: "DATA & SYSTEM CONTROLS"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 450,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: Column(
                            children: [
                              _buildSwitchSetting(
                                context: context,
                                title: "Live Firebase Sync",
                                subtitle: "Keep progress synchronized with cloud replica in real time",
                                icon: Icons.cloud_sync_outlined,
                                value: appState.liveSyncEnabled,
                                onChanged: (val) => appState.toggleLiveSync(val),
                              ),
                              const Divider(height: 24),
                              _buildActionItem(
                                context: context,
                                title: "Clear Workspace Sync Logs",
                                subtitle: "Wipe all console log printouts from dashboard viewer",
                                icon: Icons.cleaning_services_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                                onTap: () {
                                  appState.clearSyncLogs();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Firebase sync log history cleared.")),
                                  );
                                },
                              ),
                              const Divider(height: 24),
                              _buildActionItem(
                                context: context,
                                title: "Test Streak Notification",
                                subtitle: "Trigger and inspect sliding notification animations",
                                icon: Icons.notification_important_outlined,
                                color: AppColors.accentYellow,
                                onTap: () {
                                  appState.testStreakNotification();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Streak notification triggered!"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Danger Zone
                      const FadeInSlide(
                        delay: 500,
                        child: _SectionHeader(title: "DANGER ZONE", isDanger: true),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 550,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(
                            border: Border.all(color: AppColors.accentPink.withOpacity(0.3), width: 1.5),
                          ),
                          child: _buildActionItem(
                            context: context,
                            title: "Reset Profile Progress",
                            subtitle: "Wipe all stats, achievements, coins, and custom templates",
                            icon: Icons.delete_forever_outlined,
                            color: AppColors.accentPink,
                            onTap: () => _showResetConfirmationDialog(context, appState),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Legal & Policies
                      const FadeInSlide(
                        delay: 600,
                        child: _SectionHeader(title: "LEGAL & ABOUT"),
                      ),
                      const SizedBox(height: 10),
                      FadeInSlide(
                        delay: 650,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppTheme.glassBox(),
                          child: Column(
                            children: [
                              _buildActionItem(
                                context: context,
                                title: "Privacy Policy",
                                subtitle: "View data guidelines and sync replication policies",
                                icon: Icons.privacy_tip_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () => _showLegalSheet(context, "Privacy Policy", _privacyPolicyContent),
                              ),
                              const Divider(height: 24),
                              _buildActionItem(
                                context: context,
                                title: "Terms & Conditions",
                                subtitle: "Review quantitative mock arena usage agreements",
                                icon: Icons.description_outlined,
                                color: Theme.of(context).colorScheme.secondary,
                                onTap: () => _showLegalSheet(context, "Terms & Conditions", _termsContent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Section: App Version Footer
                      FadeInSlide(
                        delay: 700,
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
                                ),
                                child: Text(
                                  "SkillArena v1.2.4",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.secondary,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Crafted with ♥ for premium career growth",
                                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final activeThemeColor = Theme.of(context).colorScheme.secondary;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activeThemeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: activeThemeColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: activeThemeColor,
          activeTrackColor: activeThemeColor.withOpacity(0.3),
          inactiveThumbColor: AppColors.textSecondary,
          inactiveTrackColor: AppColors.border,
        ),
      ],
    );
  }

  Widget _buildDropdownSetting<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final activeThemeColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activeThemeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: activeThemeColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary, size: 18),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.withOpacity(0.7), size: 14),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.accentPink, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.accentPink, size: 28),
              SizedBox(width: 10),
              Text(
                "Reset Profile Stats?",
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "This action is permanent. It will reset all your coins, experience points (XP), unlocked achievement badges, daily challenges progress, and resumes back to their default initialization state.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                appState.resetProfileStats();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All profile progress has been wiped successfully."),
                    backgroundColor: AppColors.accentPink,
                  ),
                );
              },
              child: const Text("Confirm WIPE", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLockScreen(BuildContext context, AppState appState) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Enter MPIN", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              "Settings Locked",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please enter your 4-digit security PIN",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            // Pin indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFilled ? AppColors.secondary : Colors.transparent,
                    border: Border.all(
                      color: isFilled ? AppColors.secondary : AppColors.border,
                      width: 2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 48),
            
            // Keypad
            Expanded(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      if (index == 9) {
                        // Left bottom: Exit/Cancel
                        return _buildKeypadButton(
                          child: const Icon(Icons.close, color: AppColors.textPrimary),
                          onTap: () => Navigator.of(context).pop(),
                        );
                      } else if (index == 10) {
                        // Bottom center: 0
                        return _buildKeypadButton(
                          child: const Text("0", style: TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          onTap: () => _handleKeyPress("0", appState),
                        );
                      } else if (index == 11) {
                        // Right bottom: Backspace
                        return _buildKeypadButton(
                          child: const Icon(Icons.backspace_outlined, color: AppColors.textPrimary),
                          onTap: _handleBackspace,
                        );
                      } else {
                        // Standard digits 1-9
                        final digit = (index + 1).toString();
                        return _buildKeypadButton(
                          child: Text(digit, style: const TextStyle(fontSize: 24, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          onTap: () => _handleKeyPress(digit, appState),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton({required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        if (Provider.of<AppState>(context, listen: false).hapticsEnabled) {
          HapticFeedback.lightImpact();
        }
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1),
        ),
        child: Center(child: child),
      ),
    );
  }

  void _handleKeyPress(String value, AppState appState) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += value;
      });
      
      if (_enteredPin.length == 4) {
        // Verify PIN
        if (_enteredPin == appState.mpinValue) {
          setState(() {
            _isUnlocked = true;
            _enteredPin = "";
          });
        } else {
          // Wrong PIN haptic feedback & reset
          if (appState.hapticsEnabled) {
            HapticFeedback.vibrate();
          }
          setState(() {
            _enteredPin = "";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Incorrect security MPIN! Please try again."),
              backgroundColor: AppColors.accentPink,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _promptToSetMpin(BuildContext context, AppState appState) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.secondary),
              SizedBox(width: 10),
              Text("Set Security MPIN", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Configure a 4-digit numeric code to protect your settings screen.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _dialogInputDeco("Enter 4-Digit PIN"),
                  validator: (val) {
                    if (val == null || val.length != 4 || int.tryParse(val) == null) {
                      return "Enter exactly 4 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _dialogInputDeco("Confirm 4-Digit PIN"),
                  validator: (val) {
                    if (val != pinController.text) {
                      return "PIN codes do not match";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  appState.enableMpin(pinController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("MPIN protection enabled successfully!"), backgroundColor: AppColors.accentGreen),
                  );
                }
              },
              child: const Text("Enable", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _promptToDisableMpin(BuildContext context, AppState appState) {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_open, color: AppColors.accentPink),
              SizedBox(width: 10),
              Text("Disable MPIN Lock", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Please enter your current security MPIN to disable lock protection.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: _dialogInputDeco("Enter Current PIN"),
                  validator: (val) {
                    if (val != appState.mpinValue) {
                      return "Incorrect MPIN";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPink, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  appState.disableMpin();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("MPIN protection disabled."), backgroundColor: AppColors.accentPink),
                  );
                }
              },
              child: const Text("Disable", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _promptToChangeMpin(BuildContext context, AppState appState) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit_road_outlined, color: AppColors.secondary),
              SizedBox(width: 10),
              Text("Change Security MPIN", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: currentController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dialogInputDeco("Current MPIN"),
                    validator: (val) {
                      if (val != appState.mpinValue) {
                        return "Incorrect current MPIN";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: newController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dialogInputDeco("New 4-Digit PIN"),
                    validator: (val) {
                      if (val == null || val.length != 4 || int.tryParse(val) == null) {
                        return "Enter exactly 4 digits";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dialogInputDeco("Confirm New PIN"),
                    validator: (val) {
                      if (val != newController.text) {
                        return "PIN codes do not match";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  appState.enableMpin(newController.text);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("MPIN updated successfully!"), backgroundColor: AppColors.accentGreen),
                  );
                }
              },
              child: const Text("Update", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _dialogInputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      counterText: "",
      filled: true,
      fillColor: AppColors.surfaceLight.withOpacity(0.3),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accentPink, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accentPink, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    AppState appState,
    String id,
    String name,
    List<Color> palette,
  ) {
    final isSelected = appState.selectedTheme == id;
    return InkWell(
      onTap: () {
        appState.setTheme(id);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? palette[0].withOpacity(0.12) : AppColors.surfaceLight.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? palette[0] : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: palette[0],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: palette[1],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, AppState appState) {
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
                "Select Language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              const Text(
                "Choose your preferred interface language",
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildLanguageItem(context, appState, "English", "🇺🇸"),
                    _buildLanguageItem(context, appState, "Spanish", "🇪🇸"),
                    _buildLanguageItem(context, appState, "Hindi", "🇮🇳"),
                    _buildLanguageItem(context, appState, "French", "🇫🇷"),
                    _buildLanguageItem(context, appState, "German", "🇩🇪"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(BuildContext context, AppState appState, String lang, String flag) {
    final isSelected = appState.language == lang;
    final activeThemeColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: () {
        appState.setLanguage(lang);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Language updated to $lang successfully!"),
            backgroundColor: activeThemeColor,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5), width: 1)),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 16),
            Text(
              lang,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: activeThemeColor, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLegalSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("I Understand", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  static const String _privacyPolicyContent =
      "Last updated: June 15, 2026\n\n"
      "Welcome to SkillArena! We are committed to protecting your personal data and your privacy. This Privacy Policy explains how we collect, use, and share information when you use our platform.\n\n"
      "1. Information We Collect\n"
      "- Account Information: When you create a mock account, sign up or log in via email, we store your username and credentials in our simulated cloud replica databases.\n"
      "- Game & Test Results: We keep a persistent log of your quantitative aptitude quiz metrics, solved coding practices, memory training results, and achievements to compute your ratings.\n"
      "- Device & Connection Data: We cache application options such as theme details, sound and vibration configurations local to your device using secure system storage.\n\n"
      "2. How We Use Information\n"
      "- To manage your account and maintain daily streak tracking and scoreboards.\n"
      "- To provide premium simulated features including customized resume templates and real-time console log monitoring.\n"
      "- To analyze performance trends, optimize quiz algorithms, and troubleshoot interface synchronization issues.\n\n"
      "3. Cloud Sync & Replication\n"
      "- If Live Cloud Sync is enabled, progress history is stored on Firestore nodes securely. When sync is deactivated, all analytics remain locally on your physical device storage.\n\n"
      "4. Security Controls\n"
      "- You can lock access to your profiles utilizing a 4-digit security code (MPIN) that is encrypted and stored locally.\n\n"
      "5. Contact Us\n"
      "For any inquiries regarding data protection policies or compliance queries, please drop an email at privacy@skillarena.com.";

  static const String _termsContent =
      "Last updated: June 15, 2026\n\n"
      "Please read these Terms and Conditions carefully before using the SkillArena platform.\n\n"
      "1. Agreement to Terms\n"
      "By accessing or using SkillArena, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the service.\n\n"
      "2. License and Intellectual Property\n"
      "- SkillArena grant you a limited, non-exclusive, non-transferable, revocable license to access practice arenas and tools for career training and evaluation.\n"
      "- All visual branding, quantitative questions, source code layouts, achievements assets, and sound designs remain the exclusive property of SkillArena.\n\n"
      "3. Practice Arena Rules\n"
      "- Users must participate in mock tests, quizzes, and resume creation fairly. Cheat tools, script injections, or replication attempts are strictly forbidden.\n"
      "- Multiplayer duels (e.g. Tic Tac Toe and Ludo) require cooperative behavior. Toxic communication, queue dodging, or spamming simulated databases is prohibited.\n\n"
      "4. Simulated Premium Services\n"
      "- Any virtual coins, badges, or ratings hold zero monetary value. Purchases made on the platform are simulated and strictly for gaming interface test purposes.\n\n"
      "5. Limitation of Liability\n"
      "SkillArena and its developers are not responsible for any career decisions, external job match failures, or data losses resulting from cache clearance.\n\n"
      "6. Governing Law\n"
      "These terms shall be governed and construed in accordance with the regulations of the jurisdiction of operations, without regard to conflicts of law provisions.";
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDanger;

  const _SectionHeader({
    required this.title,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.accentPink : Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: color,
          ),
        ),
      ],
    );
  }
}
