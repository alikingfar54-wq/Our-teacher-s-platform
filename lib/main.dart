import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/student/student_main.dart';
import 'screens/teacher/teacher_main.dart';
import 'screens/owner/owner_login_screen.dart';
import 'screens/owner/owner_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إخفاء شريط الحالة لتجربة ممتازة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // منع تدوير الشاشة لتجربة موحدة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const OstaznaApp(),
    ),
  );
}

// ===== مزود المصادقة =====
class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _role; // 'student' | 'teacher' | 'owner'
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  String? get token => _token;
  String? get role => _role;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _role != null;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _role = prefs.getString('role');
    final userStr = prefs.getString('user');
    if (userStr != null) {
      // بسيط - يمكن استخدام json_serializable لاحقاً
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String token, String role, Map<String, dynamic> user) async {
    _token = token;
    _role = role;
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}

// ===== التطبيق الرئيسي =====
class OstaznaApp extends StatelessWidget {
  const OstaznaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'منصة أستاذنا',
      debugShowCheckedModeBanner: false,
      // RTL للغة العربية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: studentTheme(), // ثيم افتراضي
      home: const SplashScreen(),
      routes: {
        '/welcome': (ctx) => const WelcomeScreen(),
        '/student': (ctx) => const StudentMainScreen(),
        '/teacher': (ctx) => const TeacherMainScreen(),
        '/owner/login': (ctx) => const OwnerLoginScreen(),
        '/owner/dashboard': (ctx) => const OwnerDashboardScreen(),
      },
    );
  }
}
