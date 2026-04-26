import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../welcome_screen.dart';

// ===== لوحة تحكم المالك =====
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  List _teachers = [];
  bool _loading = true;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final data = await ApiService(token: auth.token).getTeachers();
      if (mounted) setState(() { _teachers = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generateCode(int teacherId, String teacherName) async {
    try {
      final auth = context.read<AuthProvider>();
      final data = await ApiService(token: auth.token).generateTeacherCode(teacherId);
      if (mounted) {
        setState(() => _generatedCode = data['code']);
        _showCodeDialog(teacherName, data['code']);
      }
    } catch (_) {}
  }

  void _showCodeDialog(String name, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1030),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('كود تفعيل — $name', style: GoogleFonts.cairo(
          color: Colors.white, fontWeight: FontWeight.w700,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.owner.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.owner.withOpacity(0.3)),
              ),
              child: Text(code, style: GoogleFonts.cairo(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                letterSpacing: 3,
              ), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            Text('صالح لمدة سنة كاملة', style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.5), fontSize: 13,
            )),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.owner),
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
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
              colors: [Color(0xFF0F0A1E), Color(0xFF1A1030), Color(0xFF0F0A1E)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // رأس الصفحة
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 40 : 20,
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await context.read<AuthProvider>().logout();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                              (r) => false,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.owner.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.owner.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.logout_rounded, color: AppColors.ownerLight, size: 20),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('لوحة التحكم', style: GoogleFonts.cairo(
                            fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white,
                          )),
                          Text('منصة أستاذنا', style: GoogleFonts.cairo(
                            fontSize: 13, color: Colors.white.withOpacity(0.4),
                          )),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

                // إحصائيات
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: Row(
                    children: [
                      _statCard('المعلمون', '${_teachers.length}', Icons.people_rounded, AppColors.owner),
                      const SizedBox(width: 12),
                      _statCard('المفعّلون', '${_teachers.where((t) => t['isActivated'] == true).length}', Icons.check_circle_rounded, AppColors.success),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('قائمة الأساتذة', style: GoogleFonts.cairo(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
                    )),
                  ),
                ),

                const SizedBox(height: 12),

                // قائمة المعلمين
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 16),
                    child: _loading
                        ? ShimmerList(
                            baseColor: const Color(0xFF1A1030),
                            highlightColor: const Color(0xFF251848),
                          )
                        : _teachers.isEmpty
                            ? Center(
                                child: Text('لا يوجد أساتذة مسجلون', style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.4),
                                )),
                              )
                            : RefreshIndicator(
                                onRefresh: _load,
                                color: AppColors.owner,
                                child: ListView.builder(
                                  itemCount: _teachers.length,
                                  itemBuilder: (_, i) {
                                    final t = _teachers[i] as Map;
                                    final isActive = t['isActivated'] == true;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.owner.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isActive
                                              ? AppColors.success.withOpacity(0.3)
                                              : AppColors.owner.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              // أزرار
                                              Row(
                                                children: [
                                                  // توليد كود
                                                  GestureDetector(
                                                    onTap: () => _generateCode(t['id'], t['name']),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.owner.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: const Icon(Icons.key_rounded, color: AppColors.ownerLight, size: 18),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // معلومات
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        if (isActive)
                                                          Container(
                                                            margin: const EdgeInsets.only(left: 8),
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.success.withOpacity(0.15),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text('مفعّل', style: GoogleFonts.cairo(
                                                              color: AppColors.success, fontSize: 11,
                                                            )),
                                                          )
                                                        else
                                                          Container(
                                                            margin: const EdgeInsets.only(left: 8),
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: AppColors.warning.withOpacity(0.15),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text('غير مفعّل', style: GoogleFonts.cairo(
                                                              color: AppColors.warning, fontSize: 11,
                                                            )),
                                                          ),
                                                        Text(t['name'] ?? '', style: GoogleFonts.cairo(
                                                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15,
                                                        )),
                                                      ],
                                                    ),
                                                    Text(t['email'] ?? '', style: GoogleFonts.cairo(
                                                      color: Colors.white.withOpacity(0.5), fontSize: 12,
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
                                  },
                                ),
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: GoogleFonts.cairo(
                    fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                  Text(label, style: GoogleFonts.cairo(
                    fontSize: 12, color: Colors.white.withOpacity(0.5),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
