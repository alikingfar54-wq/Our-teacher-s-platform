import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import 'student_main.dart';

const List<String> kGrades = [
  'الأول متوسط', 'الثاني المتوسط', 'الثالث المتوسط',
  'الرابع الأدبي', 'الرابع العلمي',
  'الخامس الأدبي', 'الخامس العلمي',
  'السادس العلمي', 'السادس الأدبي',
];

// ===== شاشة تسجيل الطالب =====
class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  String? _selectedGrade;
  bool _showPass = false;
  bool _loading = false;
  String _error = '';

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty || _guardianCtrl.text.isEmpty || _selectedGrade == null) {
      setState(() => _error = 'يرجى تعبئة جميع الحقول');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final api = ApiService();
      final data = await api.studentRegister({
        'fullName': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'grade': _selectedGrade,
        'guardianPhone': _guardianCtrl.text.trim(),
      });
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
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _guardianCtrl.dispose();
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
                horizontal: isTablet ? 100 : 24, vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.student),
                  ),

                  // العنوان
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.student,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [BoxShadow(
                              color: AppColors.student.withOpacity(0.5),
                              blurRadius: 20,
                            )],
                          ),
                          child: const Icon(Icons.person_add_rounded, size: 36, color: Colors.white),
                        ).animate().scale(curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        Text('إنشاء حساب طالب', style: GoogleFonts.cairo(
                          fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                        )).animate().fadeIn(delay: 200.ms),
                        Text('منصة أستاذنا — أدخل بياناتك', style: GoogleFonts.cairo(
                          fontSize: 13, color: Colors.white.withOpacity(0.4),
                        )).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _field(_nameCtrl, 'الاسم الثلاثي', Icons.person_rounded, delay: 400),
                  const SizedBox(height: 14),

                  // اختيار الصف
                  _gradeDropdown().animate().fadeIn(delay: 500.ms).slideX(begin: 0.3),
                  const SizedBox(height: 14),

                  _field(_guardianCtrl, 'رقم ولي الأمر', Icons.phone_rounded,
                      keyboardType: TextInputType.phone, delay: 600),
                  const SizedBox(height: 14),

                  _field(_emailCtrl, 'البريد الإلكتروني', Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress, delay: 700),
                  const SizedBox(height: 14),

                  _field(_passCtrl, 'كلمة المرور', Icons.lock_rounded,
                      obscureText: !_showPass, delay: 800,
                      suffixIcon: IconButton(
                        icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withOpacity(0.4)),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      )),
                  const SizedBox(height: 14),

                  // ملاحظة الكود
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.student.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.student.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_rounded, color: AppColors.student, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'يمكنك الاشتراك لدى الأساتذة لاحقاً من تبويب "الدورات المتوفرة"',
                            style: GoogleFonts.cairo(
                              fontSize: 13, color: Colors.white.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 850.ms),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(_error, style: GoogleFonts.cairo(color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.right),
                  ],

                  const SizedBox(height: 28),

                  AnimatedButton(
                    label: 'إنشاء الحساب',
                    icon: Icons.arrow_forward_rounded,
                    color: AppColors.student,
                    loading: _loading,
                    onTap: _register,
                  ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gradeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGrade,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'الصف الدراسي',
        labelStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5)),
        suffixIcon: const Icon(Icons.layers_rounded, color: AppColors.student),
        filled: true,
        fillColor: AppColors.student.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.student.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.student.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.student, width: 2)),
      ),
      dropdownColor: const Color(0xFF0D1340),
      style: GoogleFonts.cairo(color: Colors.white),
      items: kGrades.map((g) => DropdownMenuItem(
        value: g,
        child: Text(g, style: GoogleFonts.cairo(color: Colors.white), textAlign: TextAlign.right),
      )).toList(),
      onChanged: (v) => setState(() => _selectedGrade = v),
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
        suffixIcon: Icon(icon, color: AppColors.student.withOpacity(0.7)),
        filled: true,
        fillColor: AppColors.student.withOpacity(0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.student.withOpacity(0.3))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.student.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.student, width: 2)),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.3);
  }
}
