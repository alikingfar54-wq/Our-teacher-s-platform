import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import 'owner_dashboard_screen.dart';

// ===== شاشة دخول المالك (إيميل + كلمة مرور) =====
class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'يرجى إدخال الإيميل وكلمة المرور');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await ApiService().ownerLogin(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        await context.read<AuthProvider>().login(data['token'], 'owner', {'email': data['email']});
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
          (r) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Theme(
      data: ownerTheme(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F0A1E), Color(0xFF1A1030), Color(0xFF0F0A1E)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 100 : 24, vertical: 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.owner),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // الشعار
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.owner,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [BoxShadow(
                        color: AppColors.owner.withOpacity(0.6),
                        blurRadius: 30, spreadRadius: 5,
                      )],
                    ),
                    child: const Icon(Icons.shield_rounded, size: 46, color: Colors.white),
                  ).animate().scale(curve: Curves.elasticOut),

                  const SizedBox(height: 20),

                  Text('نسخة المالك', style: GoogleFonts.cairo(
                    fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                  )).animate().fadeIn(delay: 200.ms),

                  Text('منصة أستاذنا — لوحة الإدارة', style: GoogleFonts.cairo(
                    fontSize: 14, color: Colors.white.withOpacity(0.4),
                  )).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 48),

                  // حقل الإيميل
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('البريد الإلكتروني', style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600,
                    )),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.cairo(color: Colors.white),
                    decoration: _inputDeco('البريد الإلكتروني', Icons.email_rounded),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),

                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('كلمة المرور', style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600,
                    )),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.cairo(color: Colors.white),
                    decoration: _inputDeco('كلمة المرور', Icons.lock_rounded,
                        prefix: IconButton(
                          icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white.withOpacity(0.4)),
                          onPressed: () => setState(() => _showPass = !_showPass),
                        )),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(_error, style: GoogleFonts.cairo(color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.center),
                  ],

                  const SizedBox(height: 32),

                  AnimatedButton(
                    label: 'دخول',
                    icon: Icons.login_rounded,
                    color: AppColors.owner,
                    loading: _loading,
                    onTap: _login,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.3)),
      prefixIcon: prefix,
      suffixIcon: Icon(icon, color: AppColors.ownerLight.withOpacity(0.7)),
      filled: true,
      fillColor: AppColors.owner.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.owner.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.owner.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.owner, width: 2),
      ),
    );
  }
}
