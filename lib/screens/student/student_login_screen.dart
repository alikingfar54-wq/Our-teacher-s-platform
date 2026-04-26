import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import 'student_register_screen.dart';
import 'student_main.dart';

// ===== شاشة تسجيل دخول الطالب =====
class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({super.key});

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'يرجى إدخال جميع البيانات');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final api = ApiService();
      final data = await api.studentLogin(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        await context.read<AuthProvider>().login(data['token'], 'student', data['student']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const StudentMainScreen()),
          (route) => false,
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
      data: studentTheme(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E27), Color(0xFF0D1340), Color(0xFF0F0C29)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 100 : 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // زر الرجوع
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.student),
                  ),

                  const SizedBox(height: 24),

                  // شعار وعنوان
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.student,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(
                              color: AppColors.student.withOpacity(0.5),
                              blurRadius: 20, spreadRadius: 4,
                            )],
                          ),
                          child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
                        ).animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

                        const SizedBox(height: 16),
                        Text('تسجيل دخول الطالب', style: GoogleFonts.cairo(
                          fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                        )).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                        Text('منصة أستاذنا', style: GoogleFonts.cairo(
                          fontSize: 14, color: Colors.white.withOpacity(0.4),
                        )).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // حقل البريد
                  _buildField(
                    controller: _emailCtrl,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.3),

                  const SizedBox(height: 16),

                  // حقل كلمة المرور
                  _buildField(
                    controller: _passCtrl,
                    label: 'كلمة المرور',
                    icon: Icons.lock_rounded,
                    obscureText: !_showPass,
                    suffixIcon: IconButton(
                      icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white.withOpacity(0.4)),
                      onPressed: () => setState(() => _showPass = !_showPass),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_error, style: GoogleFonts.cairo(
                      color: AppColors.error, fontSize: 13,
                    ), textAlign: TextAlign.right),
                  ],

                  const SizedBox(height: 28),

                  // زر الدخول
                  AnimatedButton(
                    label: 'تسجيل الدخول',
                    icon: Icons.login_rounded,
                    color: AppColors.student,
                    loading: _loading,
                    onTap: _login,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                  const SizedBox(height: 20),

                  // رابط التسجيل
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const StudentRegisterScreen())),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5), fontSize: 14),
                          children: [
                            const TextSpan(text: 'ليس لديك حساب؟ '),
                            TextSpan(
                              text: 'إنشاء حساب جديد',
                              style: GoogleFonts.cairo(
                                color: AppColors.student,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5)),
        prefixIcon: suffixIcon,
        suffixIcon: Icon(icon, color: AppColors.student.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.student.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.student.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.student.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.student, width: 2),
        ),
      ),
    );
  }
}
