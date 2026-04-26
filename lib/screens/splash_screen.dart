import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';
import 'student/student_main.dart';
import 'teacher/teacher_main.dart';
import 'owner/owner_dashboard_screen.dart';

// ===== شاشة البداية مع أنيميشن Fade + Scale احترافي =====
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;   // أنيميشن الشعار
  late AnimationController _glowController;   // أنيميشن التوهج المتكرر
  late AnimationController _textController;   // أنيميشن النص
  late AnimationController _progressCtrl;     // شريط التحميل

  late Animation<double> _logoScale;     // تكبير/تصغير الشعار
  late Animation<double> _logoFade;      // ظهور الشعار
  late Animation<double> _glowPulse;    // نبض التوهج
  late Animation<double> _textFade;     // ظهور النص
  late Animation<Offset> _textSlide;   // انزلاق النص لأعلى
  late Animation<double> _progress;    // تقدم شريط التحميل

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _runSequence();
  }

  void _initAnimations() {
    // الشعار: Scale من 0.3 إلى 1.0 مع Elastic + Fade
    _logoController = AnimationController(vsync: this, duration: 900.ms);
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.5)),
    );

    // التوهج: نبض متكرر
    _glowController = AnimationController(vsync: this, duration: 1600.ms)
      ..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // النص: Slide من أسفل + Fade
    _textController = AnimationController(vsync: this, duration: 600.ms);
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // شريط التحميل
    _progressCtrl = AnimationController(vsync: this, duration: 2200.ms);
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _runSequence() async {
    await Future.delayed(300.ms);
    _logoController.forward();      // ظهور الشعار

    await Future.delayed(700.ms);
    _textController.forward();      // ظهور النص

    await Future.delayed(200.ms);
    _progressCtrl.forward();        // شريط التحميل

    await Future.delayed(2600.ms);
    if (mounted) _navigate();
  }

  void _navigate() {
    final auth = context.read<AuthProvider>();
    Widget dest = const WelcomeScreen();
    if (auth.isLoggedIn) {
      if (auth.role == 'student') dest = const StudentMainScreen();
      else if (auth.role == 'teacher') dest = const TeacherMainScreen();
      else if (auth.role == 'owner') dest = const OwnerDashboardScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => dest,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 1.08, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOut),
            ),
            child: child,
          ),
        ),
        transitionDuration: 600.ms,
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF1A1050), Color(0xFF0A0820)],
          ),
        ),
        child: Stack(
          children: [
            // دوائر الخلفية الزخرفية مع نبض
            AnimatedBuilder(
              animation: _glowPulse,
              builder: (_, __) => Stack(
                children: [
                  _circle(-100, null, null, -100, 400, AppColors.student, 0.07),
                  _circle(null, 80, -80, null, 300, AppColors.owner, 0.05),
                  _circle(null, size.height * 0.45, null, -50, 200, AppColors.teacher, 0.04),
                ],
              ),
            ),

            // المحتوى المركزي
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ===== الشعار =====
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoController, _glowController]),
                    builder: (_, __) => Stack(
                      alignment: Alignment.center,
                      children: [
                        // التوهج
                        Transform.scale(
                          scale: _glowPulse.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.student.withOpacity(0.12 * _logoFade.value),
                            ),
                          ),
                        ),
                        // الشعار
                        Opacity(
                          opacity: _logoFade.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.student, AppColors.owner],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.student.withOpacity(0.6),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== النص =====
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, __) => Opacity(
                      opacity: _textFade.value,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            Text(
                              'منصة أستاذنا',
                              style: GoogleFonts.cairo(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'المنصة التعليمية الذكية',
                              style: GoogleFonts.cairo(
                                fontSize: 15,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 64),

                  // ===== شريط التحميل =====
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _progress.value,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 180,
                            child: Stack(
                              children: [
                                Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: _progress.value,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.student, AppColors.owner],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.student.withOpacity(0.7),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'جاري التحميل...',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double? top, double? bottom, double? left, double? right,
      double size, Color color, double opacity) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Transform.scale(
        scale: 1.0 + (_glowPulse.value - 1.0) * 0.2,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}

// مساعد Duration
extension IntDuration on int {
  Duration get ms => Duration(milliseconds: this);
}
