import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import 'student/student_login_screen.dart';
import 'teacher/teacher_login_screen.dart';
import 'owner/owner_login_screen.dart';

// ===== شاشة الترحيب - اختيار الدور =====
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // أنيميشن الضغط على البطاقات
  final List<bool> _pressedStates = [false, false, false];

  final List<Map<String, dynamic>> _roles = [
    {
      'label': 'طالب',
      'subtitle': 'تعلّم وطوّر مهاراتك',
      'icon': Icons.person_rounded,
      'color': AppColors.student,
      'bg': Color(0x1F4361EE),
      'route': StudentLoginScreen(),
    },
    {
      'label': 'أستاذ',
      'subtitle': 'أدر صفك ودروسك',
      'icon': Icons.menu_book_rounded,
      'color': AppColors.teacher,
      'bg': Color(0x1F0D9488),
      'route': TeacherLoginScreen(),
    },
    {
      'label': 'مالك التطبيق',
      'subtitle': 'إدارة المنصة',
      'icon': Icons.shield_rounded,
      'color': AppColors.owner,
      'bg': Color(0x1F7C3AED),
      'route': OwnerLoginScreen(),
    },
  ];

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => screen,
        transitionsBuilder: (ctx, anim, _, child) {
          // Hero-style slide transition
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF1A1050), Color(0xFF0F0C29)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 80 : 24,
            ),
            child: Column(
              children: [
                const Spacer(),

                // ===== الشعار والعنوان =====
                _buildHeader()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 50),

                // ===== نص اختيار الدور =====
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اختر نوع حسابك',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                // ===== بطاقات الأدوار =====
                ..._roles.asMap().entries.map((entry) {
                  final i = entry.key;
                  final role = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildRoleCard(role, i),
                  );
                }),

                const Spacer(),

                // ===== تذييل =====
                Text(
                  'جميع الحقوق محفوظة © 2025 منصة أستاذنا',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // الشعار
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.student, AppColors.owner],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.student.withOpacity(0.5),
                blurRadius: 24,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.school_rounded, size: 46, color: Colors.white),
        ),
        const SizedBox(height: 20),

        // الاسم
        Text(
          'منصة أستاذنا',
          style: GoogleFonts.cairo(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'المنصة التعليمية الذكية',
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(Map<String, dynamic> role, int index) {
    final color = role['color'] as Color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedStates[index] = true),
      onTapUp: (_) {
        setState(() => _pressedStates[index] = false);
        _navigateTo(role['route'] as Widget);
      },
      onTapCancel: () => setState(() => _pressedStates[index] = false),
      child: AnimatedScale(
        // تأثير Scale Down عند الضغط
        scale: _pressedStates[index] ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _pressedStates[index]
                ? color.withOpacity(0.15)
                : Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _pressedStates[index]
                  ? color.withOpacity(0.5)
                  : color.withOpacity(0.2),
            ),
            boxShadow: _pressedStates[index]
                ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 12, spreadRadius: 2)]
                : [],
          ),
          child: Row(
            children: [
              // أيقونة
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: role['bg'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(role['icon'] as IconData, color: color, size: 28),
              ),
              const SizedBox(width: 16),

              // نص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      role['label'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      role['subtitle'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(Icons.chevron_left_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + index * 120))
        .slideY(
          begin: 0.3,
          end: 0,
          delay: Duration(milliseconds: 400 + index * 120),
          curve: Curves.easeOutCubic,
        );
  }
}
