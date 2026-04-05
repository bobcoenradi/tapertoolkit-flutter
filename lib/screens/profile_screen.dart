import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfile? profile;
  const ProfileScreen({super.key, this.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _medicationCtrl;
  late final TextEditingController _startDoseCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nicknameCtrl = TextEditingController(text: p?.nickname ?? '');
    _firstNameCtrl = TextEditingController(text: p?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: p?.lastName ?? '');
    _medicationCtrl = TextEditingController(text: p?.medication ?? '');
    _startDoseCtrl = TextEditingController(text: p?.startDose?.toString() ?? '');
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _medicationCtrl.dispose();
    _startDoseCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.profile == null) return;
    setState(() => _saving = true);
    final updated = widget.profile!.copyWith(
      nickname: _nicknameCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim().isEmpty ? null : _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim().isEmpty ? null : _lastNameCtrl.text.trim(),
      medication: _medicationCtrl.text.trim().isEmpty ? null : _medicationCtrl.text.trim(),
      startDose: double.tryParse(_startDoseCtrl.text),
    );
    await AuthService.updateProfile(updated);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved'), backgroundColor: AppColors.primary),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Profile', style: AppTextStyles.h4()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primarySoft,
                    child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            _section('Account'),
            _field('Nickname', _nicknameCtrl),
            const SizedBox(height: 12),
            _field('First Name', _firstNameCtrl),
            const SizedBox(height: 12),
            _field('Last Name', _lastNameCtrl),

            const SizedBox(height: 24),
            _section('Taper Info'),
            _field('Medication', _medicationCtrl),
            const SizedBox(height: 12),
            _field('Starting Dose (mg)', _startDoseCtrl, keyboardType: TextInputType.number),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Save Changes', style: AppTextStyles.label(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title, style: AppTextStyles.label(color: AppColors.textLight).copyWith(letterSpacing: 1.0, fontSize: 11)),
  );

  Widget _field(String label, TextEditingController ctrl, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body(color: AppColors.textMid)),
        const SizedBox(height: 6),
        Container(
          decoration: AppDecorations.card(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            decoration: const InputDecoration(border: InputBorder.none),
            style: AppTextStyles.body(color: AppColors.textDark),
          ),
        ),
      ],
    );
  }
}
