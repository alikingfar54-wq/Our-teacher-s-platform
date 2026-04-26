import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import 'teacher_main.dart';

// ===== شاشة تفعيل الأستاذ =====
class TeacherActivateScreen extends StatefulWidget {
  final int teacherId;
  const TeacherActivateScreen({super.key, required this.teacherId});

  @override
  State<TeacherActivateScreen> createState() => _TeacherActivateScreenState();
}

class _TeacherActivateScreenState extends State<TeacherActivateScreen> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _activate() async {
    if (_codeCtrl.text.length < 8) {
      setState(() => _error = 'يرجى إدخال الكود الصحيح');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await ApiService().teacherActivate(widget.teacherId, _codeCtrl.text.trim());
      if (mounted) {
        await context.read<AuthProvider>().login(data['token'], 'teacher', data['teacher']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TeacherMainScreen()),
          (r) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: teacherTheme(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF020F0E), Color(0xFF051A18)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.teacher.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.teacher, width: 2),
                    ),
                    child: const Icon(Icons.lock_open_rounded, size: 44, color: AppColors.teacher),
                  ).animate().scale(curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  Text('تفعيل الحساب', style: GoogleFonts.cairo(
                    fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                  )).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 8),
                  Text(
                    'أدخل كود التفعيل الذي حصلت عليه من مالك المنصة',
                    style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5), fontSize: 14),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _codeCtrl,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: GoogleFonts.cairo(
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w700, letterSpacing: 4,
                    ),
                    decoration: InputDecoration(
                      hintText: 'XXXX-XXXX-XXXX',
                      hintStyle: GoogleFonts.cairo(
                        color: Colors.white.withOpacity(0.3), fontSize: 18, letterSpacing: 2,
                      ),
                      filled: true,
                      fillColor: AppColors.teacher.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.teacher.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.teacher.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.teacher, width: 2),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_error, style: GoogleFonts.cairo(color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.center),
                  ],

                  const SizedBox(height: 28),

                  AnimatedButton(
                    label: 'تفعيل الحساب',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.teacher,
                    loading: _loading,
                    onTap: _activate,
                  ).animate().fadeIn(delay: 500.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
