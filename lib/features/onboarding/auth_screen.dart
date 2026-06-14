import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/routes/routes.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';
import '../../core/services/firebase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      
      if (_isLoginMode) {
        if (!FirebaseService.isConfigured) {
          // Offline replica login fallback
          final uid = "offline_replica_${email.split('@')[0]}";
          String finalUsername = email.split('@')[0];
          if (finalUsername.isNotEmpty) {
            finalUsername = finalUsername[0].toUpperCase() + finalUsername.substring(1);
          }
          
          await appState.login(uid: uid, username: finalUsername, email: email, syncData: false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome back, $finalUsername! Running in Offline Replica mode."),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          }
        } else {
          // Live login
          final credential = await FirebaseService.login(email, password);
          if (credential == null || credential.user == null) {
            throw Exception("Authentication failed. Firebase service is offline/disabled.");
          }
          
          final uid = credential.user!.uid;
          // Fetch existing user data
          Map<String, dynamic>? data;
          bool isOfflineMode = false;
          try {
            data = await FirebaseService.fetchUserData(uid, rethrowError: true);
          } catch (e) {
            debugPrint("Failed to fetch user data (using offline fallback): $e");
            isOfflineMode = true;
          }
          
          String finalUsername = email.split('@')[0];
          if (finalUsername.isNotEmpty) {
            finalUsername = finalUsername[0].toUpperCase() + finalUsername.substring(1);
          }

          if (data != null) {
            // User exists in Database
            if (data.containsKey('profile') && data['profile'] is Map) {
              finalUsername = data['profile']['username'] ?? finalUsername;
            }
            await appState.login(uid: uid, username: finalUsername, email: email, syncData: false);
            await appState.restoreUserData(data);
          } else {
            // First time logging in (or missing database node). Sync current local cache profile if online.
            await appState.login(uid: uid, username: finalUsername, email: email, syncData: !isOfflineMode);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isOfflineMode
                    ? "Welcome back, $finalUsername! Running in Offline Mode (local sync active)."
                    : "Welcome back, $finalUsername! Sync complete."),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          }
        }
      } else {
        if (!FirebaseService.isConfigured) {
          // Offline replica signup fallback
          final uid = "offline_replica_${email.split('@')[0]}";
          
          await appState.login(uid: uid, username: username, email: email, syncData: false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Account created! Running in Offline Replica mode, $username."),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          }
        } else {
          // Live Signup
          final credential = await FirebaseService.signUp(email, password);
          if (credential == null || credential.user == null) {
            throw Exception("Registration failed. Firebase service is offline/disabled.");
          }
          
          final uid = credential.user!.uid;
          
          // Write initial data to Firebase Realtime Database
          await FirebaseService.syncUserProfile(
            uid,
            username: username,
            email: email,
            xp: 180, // initial xp
            coins: 120, // initial coins
            streak: 3, // initial streak
            isPremium: false,
          );

          // Save local state
          await appState.login(uid: uid, username: username, email: email, syncData: true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Account created! Welcome, $username."),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.dashboard,
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An authentication error occurred.";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "An account already exists for this email.";
      } else if (e.code == 'weak-password') {
        errorMessage = "The password is too weak.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "The email address is invalid.";
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;

    final Widget authForm = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Header text
                Text(
                  _isLoginMode ? "Welcome Back!" : "Create Account",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoginMode 
                      ? "Log in to sync your progress with Firebase Database" 
                      : "Join the arena and match up against active players",
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 40),
                
                // Form fields container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.glassBox(),
                  child: Column(
                    children: [
                      if (!_isLoginMode) ...[
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration(
                            label: "Username",
                            icon: Icons.person_outline,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Please enter a username";
                            }
                            if (val.trim().length < 3) {
                              return "Username must be at least 3 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                      ],
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          label: "Email Address",
                          icon: Icons.email_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Please enter an email address";
                          }
                          if (!_emailRegExp.hasMatch(val)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        decoration: _buildInputDecoration(
                          label: "Password",
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                                return "Please enter a password";
                          }
                          if (val.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      
                      // Submit Button
                      GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: _isLoginMode 
                                ? AppColors.primaryGradient 
                                : AppColors.pinkGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    _isLoginMode ? "Login" : "Sign Up",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // Switch modes button
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                        _formKey.currentState?.reset();
                      });
                    },
                    child: Text(
                      _isLoginMode 
                          ? "Don't have an account? Sign Up" 
                          : "Already have an account? Log In",
                      style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                // Skip button to explore as guest
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                    },
                    child: const Text(
                      "Skip & Explore as Guest",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );

    final Widget wideBody = SafeArea(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: authForm,
          ),
          Expanded(
            flex: 1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ambient glow ring
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.05),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withOpacity(0.08),
                        blurRadius: 100,
                        spreadRadius: 40,
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "🎓",
                      style: TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Placement Ready Platform",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Database Synchronization Enabled",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontFamily: 'Courier New'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: 20,
            right: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 80,
                    spreadRadius: 40,
                  )
                ],
              ),
            ),
          ),
          
          isWide ? wideBody : SafeArea(child: authForm),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.surfaceLight.withOpacity(0.5),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }
}
