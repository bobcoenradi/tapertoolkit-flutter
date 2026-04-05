import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/user_profile_model.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 1;

  // Step 1 fields
  final _nicknameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  String? _gender;
  final _ageCtrl = TextEditingController();
  bool _obscurePassword = true;

  // Step 2 fields
  String _purpose = 'tapering';
  String _taperDuration = 'less_than_6m';
  final _medicationCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  UserProfile? _createdProfile;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _medicationCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleStep1Next() async {
    if (_nicknameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Please choose a nickname');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty || !_emailCtrl.text.contains('@')) {
      setState(() => _error = 'Please enter a valid email');
      return;
    }
    if (_passwordCtrl.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final profile = await AuthService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        nickname: _nicknameCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
        gender: _gender,
        age: int.tryParse(_ageCtrl.text),
      );
      _createdProfile = profile;
      setState(() { _step = 2; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString().replaceAll('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _handleStep2Complete() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AuthService.updateTaperPath(
        purpose: _purpose,
        taperDuration: _taperDuration,
        medication: _medicationCtrl.text.trim().isEmpty ? null : _medicationCtrl.text.trim(),
        reasonForTapering: _reasonCtrl.text.trim().isEmpty ? null : _reasonCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _step == 1 ? _buildStep1() : _buildStep2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          if (_step > 1)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.textDark,
              onPressed: () => setState(() => _step--),
            )
          else
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              color: AppColors.textDark,
              onPressed: () => Navigator.of(context).pop(),
            ),
          Expanded(
            child: Center(
              child: Text(
                'Step $_step of 2',
                style: AppTextStyles.label(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        _ProgressBar(current: 1, total: 2),
        const SizedBox(height: 32),

        Text("Let's begin your journey.", style: AppTextStyles.h1()),
        const SizedBox(height: 12),
        Text(
          "Create your account to save your progress safely. Your well-being is a personal journey, and we're here to guide you.",
          style: AppTextStyles.body(),
        ),
        const SizedBox(height: 32),

        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_error!, style: AppTextStyles.body(color: AppColors.danger)),
          ),
          const SizedBox(height: 16),
        ],

        // Nickname
        _SectionCard(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nickname (for anonymous interactions)', style: AppTextStyles.label()),
            const SizedBox(height: 8),
            _TextField(controller: _nicknameCtrl, hint: 'e.g. SageGuide'),
          ],
        )),
        const SizedBox(height: 16),

        _LabelField(label: 'Email Address', child: _TextField(controller: _emailCtrl, hint: 'name@example.com', keyboardType: TextInputType.emailAddress)),
        const SizedBox(height: 16),

        _LabelField(
          label: 'Password',
          child: _TextField(
            controller: _passwordCtrl,
            hint: '••••••••',
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: AppColors.textLight),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _LabelField(label: 'First Name (Optional)', child: _TextField(controller: _firstNameCtrl, hint: '')),
        const SizedBox(height: 16),

        _LabelField(label: 'Last Name (Optional)', child: _TextField(controller: _lastNameCtrl, hint: '')),
        const SizedBox(height: 16),

        _LabelField(
          label: 'Gender',
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEEC),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _gender,
                hint: Text('Select an option', style: AppTextStyles.body(color: AppColors.textLight)),
                isExpanded: true,
                items: ['Male', 'Female', 'Non-binary', 'Prefer not to say']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g, style: AppTextStyles.body(color: AppColors.textDark))))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _LabelField(label: 'Age', child: _TextField(controller: _ageCtrl, hint: '25', keyboardType: TextInputType.number)),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _handleStep1Next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Next', style: AppTextStyles.h4(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: Text.rich(
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: AppTextStyles.caption(),
              children: [
                TextSpan(text: 'Privacy Policy', style: AppTextStyles.caption(color: AppColors.primary)),
                TextSpan(text: ' regarding your clinical data safety.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressBar(current: 2, total: 2),
        const SizedBox(height: 32),

        Text('Tell us about your path.', style: AppTextStyles.h1()),
        const SizedBox(height: 12),
        Text(
          'Help us tailor the toolkit to your needs. This information allows us to provide more relevant guidance and resources.',
          style: AppTextStyles.body(),
        ),
        const SizedBox(height: 32),

        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(_error!, style: AppTextStyles.body(color: AppColors.danger)),
          ),
          const SizedBox(height: 16),
        ],

        // Purpose
        Text('WHAT ARE YOU HERE FOR?', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.0)),
        const SizedBox(height: 8),
        ...[
          ('tapering', 'Currently tapering off'),
          ('helping', 'Looking to help someone'),
          ('looking', 'Just having a look'),
        ].map((e) => _RadioTile(
          value: e.$1,
          label: e.$2,
          groupValue: _purpose,
          onChanged: (v) => setState(() => _purpose = v!),
        )),

        const SizedBox(height: 24),

        // Duration
        Text('HOW LONG?', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.0)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFE8EEEC), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _taperDuration,
              isExpanded: true,
              items: [
                ('less_than_6m', 'Less than 6 months'),
                ('6m_to_1y', '6 months to 1 year'),
                ('1y_to_2y', '1–2 years'),
                ('over_2y', 'More than 2 years'),
              ].map((e) => DropdownMenuItem(value: e.$1, child: Text(e.$2, style: AppTextStyles.body(color: AppColors.textDark)))).toList(),
              onChanged: (v) => setState(() => _taperDuration = v!),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Medication
        Text('WHAT MEDICATION?', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.0)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFE8EEEC), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textLight, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _medicationCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search medication...',
                    hintStyle: AppTextStyles.body(color: AppColors.textLight),
                    border: InputBorder.none,
                  ),
                  style: AppTextStyles.body(color: AppColors.textDark),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Text('REASON FOR TAPERING', style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 1.0)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
              child: Text('OPTIONAL', style: AppTextStyles.caption()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFE8EEEC), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _reasonCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your story or goals here...',
              hintStyle: AppTextStyles.body(color: AppColors.textLight),
              border: InputBorder.none,
            ),
            style: AppTextStyles.body(color: AppColors.textDark),
          ),
        ),

        const SizedBox(height: 24),

        // Community social proof
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("You're not alone.", style: AppTextStyles.h4()),
              const SizedBox(height: 4),
              Text('Over 15,000 members have started their journey with us.', style: AppTextStyles.body()),
            ],
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _handleStep2Complete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Create My Path', style: AppTextStyles.h4(color: Colors.white)),
          ),
        ),

        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
            ),
            child: Text('Skip for now', style: AppTextStyles.label(color: AppColors.textMid)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('SAFE  •  PRIVATE  •  SUPPORTIVE',
              style: AppTextStyles.caption().copyWith(letterSpacing: 1.0)),
        ),
      ],
    );
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i < current;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEEC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _LabelField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabelField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label()),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _TextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEEC),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.body(color: AppColors.textLight),
                border: InputBorder.none,
              ),
              style: AppTextStyles.body(color: AppColors.textDark),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

class _RadioTile extends StatelessWidget {
  final String value;
  final String label;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _RadioTile({
    required this.value,
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTextStyles.body(color: AppColors.textDark))),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.textLight,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
