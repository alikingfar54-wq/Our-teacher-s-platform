import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import 'teacher_activate_screen.dart';

const List<String> kAllGrades = [
  'الأول متوسط', 'الثاني المتوسط', 'الثالث المتوسط',
  'الرابع الأدبي', 'الرابع العلمي',
  'الخامس الأدبي', 'الخامس العلمي',
  'السادس العلمي', 'السادس الأدبي',
];

const List<String> kAllSubjects = [
  'الرياضيات', 'الكيمياء', 'الأحياء', 'الفيزياء',
  'اللغة العربية', 'اللغة الإنكليزية', 'التاريخ', 'الجغرافية',
  'الفيزياء والكيمياء', 'العلوم',
];

// ===== شاشة تسجيل الأستاذ =====
class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final Set<String> _selectedGrades = {};
  final Set<String> _selectedSubjects = {};
  bool _showPass = false;
  bool _loading = false;
  String _error = '';

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty || _phoneCtrl.text.isEmpty) {
      setState(() => _error = 'يرجى تعبئة جميع الحقول');
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      final data = await ApiService().teacherRegister({
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'phone': _phoneCtrl.text.trim(),
        'grades': _selectedGrades.toList(),
        'subjects': _selectedSubjects.toList(),
      });
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => TeacherActivateScreen(teacherId: data['teacher']['id'])),
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
    _passCtrl.dispose(); _phoneCtrl.dispose();
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
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.teacher,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [BoxShadow(color: AppColors.teacher.withOpacity(0.5), blurRadius: 20)],
                          ),
                          child: const Icon(Icons.person_add_rounded, size: 36, color: Colors.white),
                        ).animate().scale(curve: Curves.elasticOut),
                        const SizedBox(height: 12),
                        Text('إنشاء حساب أستاذ', style: GoogleFonts.cairo(
                          fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                        )).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _field(_nameCtrl, 'الاسم الكامل', Icons.person_rounded, delay: 400),
                  const SizedBox(height: 14),
                  _field(_phoneCtrl, 'رقم الهاتف', Icons.phone_rounded,
                      keyboardType: TextInputType.phone, delay: 500),
                  const SizedBox(height: 14),
                  _field(_emailCtrl, 'البريد الإلكتروني', Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress, delay: 600),
                  const SizedBox(height: 14),
                  _field(_passCtrl, 'كلمة المرور', Icons.lock_rounded,
                      obscureText: !_showPass, delay: 700,
                      suffixIcon: IconButton(
                        icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white.withOpacity(0.4)),
                        onPressed: () => setState(() => _showPass = !_showPass),
                      )),

                  const SizedBox(height: 20),

                  // اختيار الصفوف
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('الصفوف الدراسية', style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600,
                    )),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: kAllGrades.map((g) {
                      final selected = _selectedGrades.contains(g);
                      return FilterChip(
                        label: Text(g, style: GoogleFonts.cairo(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        )),
                        selected: selected,
                        onSelected: (v) => setState(() => v ? _selectedGrades.add(g) : _selectedGrades.remove(g)),
                        selectedColor: AppColors.teacher.withOpacity(0.3),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        checkmarkColor: AppColors.teacher,
                        side: BorderSide(color: selected ? AppColors.teacher : Colors.white.withOpacity(0.2)),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 20),

                  // اختيار المواد
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('المواد الدراسية', style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600,
                    )),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: kAllSubjects.map((s) {
                      final selected = _selectedSubjects.contains(s);
                      return FilterChip(
                        label: Text(s, style: GoogleFonts.cairo(
                          color: selected ? Colors.white : Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        )),
                        selected: selected,
                        onSelected: (v) => setState(() => v ? _selectedSubjects.add(s) : _selectedSubjects.remove(s)),
                        selectedColor: AppColors.teacher.withOpacity(0.3),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        checkmarkColor: AppColors.teacher,
                        side: BorderSide(color: selected ? AppColors.teacher : Colors.white.withOpacity(0.2)),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 900.ms),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(_error, style: GoogleFonts.cairo(color: AppColors.error, fontSize: 13),
                        textAlign: TextAlign.right),
                  ],

                  const SizedBox(height: 28),

                  AnimatedButton(
                    label: 'إنشاء الحساب',
                    icon: Icons.arrow_forward_rounded,
                    color: AppColors.teacher,
                    loading: _loading,
                    onTap: _register,
                  ).animate().fadeIn(delay: 1000.ms),
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
      style: GoogleFonts.cairo(color: Colors.white),
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
