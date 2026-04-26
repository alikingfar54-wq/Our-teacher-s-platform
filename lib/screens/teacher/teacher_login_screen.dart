import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import 'teacher_register_screen.dart';
import 'teacher_main.dart';

// ===== شاشة تسجيل دخول الأستاذ =====
class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  State<TeacherLoginScreen> createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
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
      final data = await api.teacherLogin(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        await context.read<AuthProvider>().login(data['token'], 'teacher', data['teacher']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TeacherMainScreen()),
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
      data: teacherTheme(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF020F0E), Color(0xFF051A18), Color(0xFF020F0E)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 100 : 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.teacher),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.teacher,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(
                              color: AppColors.teacher.withOpacity(0.5),
                              blurRadius: 20, spreadRadius: 4,
                            )],
                          ),
                          child: const Icon(Icons.menu_book_rounded, size: 40, color: Colors.white),
                        ).animate().scale(curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        Text('تسجيل دخول الأستاذ', style: GoogleFonts.cairo(
                          fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                        )).animate().fadeIn(delay: 200.ms),
                        Text('منصة أستاذنا', style: GoogleFonts.cairo(
                          fontSize: 14, color: Colors.white.withOpacity(0.4),
                        )).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _field(_emailCtrl, 'البريد الإلكتروني', Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress, delay: 400),
                  const SizedBox(height: 16),
                  _field(_passCtrl, 'كلمة المرور', Icons.lock_rounded,
                      obscureText: !_showPass, delay: 500,
                      suffixIcon: IconButton(
                        icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withOpacity(0.4)),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      )),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_error, style: GoogleFonts.cairo(color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.right),
                  ],

                  const SizedBox(height: 28),

                  AnimatedButton(
                    label: 'تسجيل الدخول',
                    icon: Icons.login_rounded,
                    color: AppColors.teacher,
                    loading: _loading,
                    onTap: _login,
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const TeacherRegisterScreen())),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5), fontSize: 14),
                          children: [
                            const TextSpan(text: 'ليس لديك حساب؟ '),
                            TextSpan(
                              text: 'تسجيل جديد',
                              style: GoogleFonts.cairo(
                                color: AppColors.teacher,
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

  Widget _field(TextEditingController ctrl, String label, IconData icon, {
    TextInputType? keyboardType, bool obscureText = false, Widget? suffixIcon, int delay = 400,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.cairo(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5)),
        prefixIcon: suffixIcon,
        suffixIcon: Icon(icon, color: AppColors.teacher.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.teacher.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.teacher.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.teacher.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.teacher, width: 2)),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.3);
  }
}
