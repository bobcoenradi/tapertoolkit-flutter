import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5ECE0), Color(0xFFEDE3D6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Safe & Secure badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'SAFE & SECURE',
                    style: AppTextStyles.caption(color: AppColors.textMid).copyWith(
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE8DDD0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 160,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 28),

                // Divider accent
                Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Your guided path to a steady\nand clear recovery.',
                  style: AppTextStyles.bodyLarge(color: AppColors.textMid),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 2),

                // Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: AppTextStyles.h4(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    'Log In',
                    style: AppTextStyles.label(color: AppColors.textMid),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'CLINICAL EXCELLENCE  •  HUMAN CENTERED',
                  style: AppTextStyles.caption(color: AppColors.textLight).copyWith(
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
