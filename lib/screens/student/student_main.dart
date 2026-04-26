import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../welcome_screen.dart';

// ===== شاشة الطالب الرئيسية مع Bottom Navigation =====
class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: 300.ms);
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final token = auth.token ?? '';
    final user = auth.user ?? {};

    final pages = [
      StudentHomeTab(token: token, user: user),
      StudentNewsTab(token: token),
      StudentExamsTab(token: token),
      StudentChatTab(token: token),
      StudentCoursesTab(token: token, user: user),
    ];

    return Theme(
      data: studentTheme(),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: 300.ms,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: pages[_currentIndex],
          ),
        ),
        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }

  Widget _buildNavBar() {
    const items = [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
      BottomNavigationBarItem(icon: Icon(Icons.rss_feed_rounded), label: 'الأخبار'),
      BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'الامتحانات'),
      BottomNavigationBarItem(icon: Icon(Icons.message_rounded), label: 'التواصل'),
      BottomNavigationBarItem(icon: Icon(Icons.layers_rounded), label: 'الدورات'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.studentBg,
        border: Border(top: BorderSide(color: AppColors.student.withOpacity(0.2))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.student,
        unselectedItemColor: Colors.white.withOpacity(0.35),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 10),
        items: items,
      ),
    );
  }
}

// ===== تبويب الرئيسية =====
class StudentHomeTab extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  const StudentHomeTab({super.key, required this.token, required this.user});

  @override
  State<StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<StudentHomeTab> {
  bool _loading = true;
  List _lectures = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // نحمل البيانات
      await Future.delayed(800.ms);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.user['fullName'] ?? 'الطالب';
    final grade = widget.user['grade'] ?? '';
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'صباح الخير' : hour < 17 ? 'مساء الخير' : 'مساء النور';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E27), Color(0xFF0D1340), Color(0xFF0F0C29)],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // رأس الصفحة
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
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
                              color: AppColors.student.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.student.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.logout_rounded, color: AppColors.student, size: 20),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$greeting،', style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(0.5), fontSize: 14,
                            )),
                            Text(name, style: GoogleFonts.cairo(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800,
                            )),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // بطاقة الصف
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.student, AppColors.student.withBlue(200)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                          color: AppColors.student.withOpacity(0.4),
                          blurRadius: 20, offset: const Offset(0, 8),
                        )],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.school_rounded, color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('صفك الدراسي', style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.7), fontSize: 13,
                                )),
                                Text(grade, style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700,
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                  ],
                ),
              ),
            ),

            // شبكة المواد
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildListDelegate(_subjectCards()),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  List<Widget> _subjectCards() {
    final subjects = [
      {'icon': Icons.calculate_rounded, 'name': 'الرياضيات', 'color': AppColors.student},
      {'icon': Icons.science_rounded, 'name': 'الكيمياء', 'color': AppColors.owner},
      {'icon': Icons.biotech_rounded, 'name': 'الأحياء', 'color': const Color(0xFF059669)},
      {'icon': Icons.electric_bolt_rounded, 'name': 'الفيزياء', 'color': const Color(0xFFD97706)},
      {'icon': Icons.book_rounded, 'name': 'العربي', 'color': const Color(0xFFDC2626)},
      {'icon': Icons.language_rounded, 'name': 'الإنكليزي', 'color': const Color(0xFF0891B2)},
    ];

    return subjects.asMap().entries.map((e) {
      final s = e.value;
      final color = s['color'] as Color;
      return GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: 200.ms,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s['icon'] as IconData, color: color, size: 30),
              const SizedBox(height: 8),
              Text(s['name'] as String, style: GoogleFonts.cairo(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
              ), textAlign: TextAlign.center),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 300 + e.key * 80))
            .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
      );
    }).toList();
  }
}

// ===== تبويب الأخبار =====
class StudentNewsTab extends StatefulWidget {
  final String token;
  const StudentNewsTab({super.key, required this.token});

  @override
  State<StudentNewsTab> createState() => _StudentNewsTabState();
}

class _StudentNewsTabState extends State<StudentNewsTab> {
  bool _loading = true;
  List _news = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService(token: widget.token).getStudentNews();
      if (mounted) setState(() { _news = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E27), Color(0xFF0D1340)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('الأخبار', style: GoogleFonts.cairo(
                fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
              )),
            ),
            Expanded(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: ShimmerList(
                        baseColor: const Color(0xFF0D1340),
                        highlightColor: const Color(0xFF1A2060),
                      ),
                    )
                  : _news.isEmpty
                      ? Center(
                          child: Text('لا توجد أخبار', style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.4), fontSize: 16,
                          )),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _news.length,
                          itemBuilder: (_, i) {
                            final n = _news[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(n['content'] ?? '', style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 15,
                                ), textAlign: TextAlign.right),
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: i * 100));
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== تبويب الامتحانات =====
class StudentExamsTab extends StatelessWidget {
  final String token;
  const StudentExamsTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A0E27), Color(0xFF0D1340)]),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('الامتحانات', style: GoogleFonts.cairo(
                fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
              )),
            ),
            Expanded(
              child: Center(
                child: Text('اشترك لدى أستاذ لتظهر الامتحانات هنا', style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.4), fontSize: 15,
                ), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== تبويب التواصل =====
class StudentChatTab extends StatefulWidget {
  final String token;
  const StudentChatTab({super.key, required this.token});

  @override
  State<StudentChatTab> createState() => _StudentChatTabState();
}

class _StudentChatTabState extends State<StudentChatTab> {
  List _conversations = [];
  bool _loading = true;
  Map<String, dynamic>? _selectedConv;
  List _messages = [];
  final _inputCtrl = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService(token: widget.token).getChatConversations();
      if (mounted) setState(() { _conversations = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMessages(int partnerId) async {
    try {
      final data = await ApiService(token: widget.token).getChatMessages(partnerId);
      if (mounted) setState(() => _messages = data);
    } catch (_) {}
  }

  Future<void> _send({bool isCodeRequest = false}) async {
    if (_selectedConv == null) return;
    final text = isCodeRequest ? '🔑 أطلب كود الاشتراك في الدورة' : _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ApiService(token: widget.token).sendMessage(
        _selectedConv!['partnerId'], text, isCodeRequest: isCodeRequest,
      );
      _inputCtrl.clear();
      await _loadMessages(_selectedConv!['partnerId']);
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedConv != null) return _buildChatView();
    return _buildConversationsList();
  }

  Widget _buildConversationsList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A0E27), Color(0xFF0D1340)]),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('التواصل', style: GoogleFonts.cairo(
                    fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                  Text('راسل أساتذتك مباشرة', style: GoogleFonts.cairo(
                    fontSize: 14, color: Colors.white.withOpacity(0.4),
                  )),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.student))
                  : _conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.message_rounded,
                                  size: 60, color: AppColors.student.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text('لا توجد محادثات', style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.5), fontSize: 16,
                              )),
                              Text('اشترك لدى أستاذ من "الدورات"', style: GoogleFonts.cairo(
                                color: Colors.white.withOpacity(0.3), fontSize: 13,
                              )),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          color: AppColors.student,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _conversations.length,
                            itemBuilder: (_, i) {
                              final c = _conversations[i] as Map;
                              return GestureDetector(
                                onTap: () {
                                  setState(() { _selectedConv = Map<String, dynamic>.from(c); });
                                  _loadMessages(c['partnerId']);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.student.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.student.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50, height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.student,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.menu_book_rounded,
                                            color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(c['partnerName'] ?? '', style: GoogleFonts.cairo(
                                              color: Colors.white, fontWeight: FontWeight.w700,
                                            )),
                                            Text(c['lastMessage'] ?? 'ابدأ المحادثة...', style: GoogleFonts.cairo(
                                              color: Colors.white.withOpacity(0.5), fontSize: 13,
                                            ), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      if ((c['unreadCount'] ?? 0) > 0)
                                        Container(
                                          margin: const EdgeInsets.only(right: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.student,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text('${c['unreadCount']}', style: GoogleFonts.cairo(
                                            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                                          )),
                                        ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: Duration(milliseconds: i * 80)),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A0E27), Color(0xFF0D1340)]),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // رأس المحادثة
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.student.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.student),
                    onPressed: () => setState(() { _selectedConv = null; _messages = []; }),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_selectedConv?['partnerName'] ?? '', style: GoogleFonts.cairo(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16,
                        )),
                        Text('أستاذ', style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.4), fontSize: 12,
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.student, shape: BoxShape.circle),
                    child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // الرسائل
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i] as Map;
                  final isMe = m['senderRole'] == 'student';
                  return Align(
                    alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.student : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18).copyWith(
                          bottomLeft: isMe ? const Radius.circular(4) : null,
                          bottomRight: isMe ? null : const Radius.circular(4),
                        ),
                      ),
                      child: Text(m['content'] ?? '', style: GoogleFonts.cairo(
                        color: Colors.white, fontSize: 14,
                      )),
                    ),
                  );
                },
              ),
            ),

            // زر طلب كود
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: GestureDetector(
                onTap: () => _send(isCodeRequest: true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.key_rounded, color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Text('طلب كود اشتراك', style: GoogleFonts.cairo(
                        color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 13,
                      )),
                    ],
                  ),
                ),
              ),
            ),

            // حقل الإدخال
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _send(),
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.student,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.student.withOpacity(0.4), blurRadius: 12)],
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        hintStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: AppColors.student.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: AppColors.student.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}

// ===== تبويب الدورات =====
class StudentCoursesTab extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  const StudentCoursesTab({super.key, required this.token, required this.user});

  @override
  State<StudentCoursesTab> createState() => _StudentCoursesTabState();
}

class _StudentCoursesTabState extends State<StudentCoursesTab> {
  List _courses = [];
  bool _loading = true;
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService(token: widget.token).getStudentCourses();
      if (mounted) setState(() { _courses = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('الاشتراك بكود', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أدخل الكود الذي حصلت عليه من الأستاذ', style: GoogleFonts.cairo(
              color: Colors.white.withOpacity(0.6), fontSize: 13,
            ), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, letterSpacing: 3),
              decoration: InputDecoration(
                hintText: 'XXXX-XXXX',
                hintStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.student),
            onPressed: () async {
              try {
                await ApiService(token: widget.token).studentSubscribe(_codeCtrl.text.trim());
                if (mounted) {
                  Navigator.pop(context);
                  _codeCtrl.clear();
                  _load();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('تم الاشتراك بنجاح!', style: GoogleFonts.cairo())),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString(), style: GoogleFonts.cairo()), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: Text('اشتراك', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0A0E27), Color(0xFF0D1340)]),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _showSubscribeDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.student.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.student.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: AppColors.student, size: 18),
                          const SizedBox(width: 6),
                          Text('اشترك بكود', style: GoogleFonts.cairo(color: AppColors.student, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('الدورات المتوفرة', style: GoogleFonts.cairo(
                        fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
                      )),
                      Text('صفك: ${widget.user['grade'] ?? ''}', style: GoogleFonts.cairo(
                        fontSize: 13, color: Colors.white.withOpacity(0.4),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: ShimmerList(baseColor: const Color(0xFF0D1340), highlightColor: const Color(0xFF1A2060)),
                    )
                  : _courses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.layers_rounded, size: 60, color: AppColors.student.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text('لا توجد دورات', style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5))),
                              GestureDetector(
                                onTap: _showSubscribeDialog,
                                child: Text('اضغط هنا للاشتراك بكود', style: GoogleFonts.cairo(
                                  color: AppColors.student, decoration: TextDecoration.underline,
                                )),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: AppColors.student,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _courses.length,
                            itemBuilder: (_, i) {
                              final c = _courses[i] as Map;
                              final isSubscribed = c['isSubscribed'] == true;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSubscribed
                                      ? AppColors.success.withOpacity(0.08)
                                      : AppColors.student.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSubscribed
                                        ? AppColors.success.withOpacity(0.3)
                                        : AppColors.student.withOpacity(0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        if (isSubscribed)
                                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(c['name'] ?? '', style: GoogleFonts.cairo(
                                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16,
                                          ), textAlign: TextAlign.right),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (!isSubscribed)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: _showSubscribeDialog,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.student,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text('اشترك بكود', style: GoogleFonts.cairo(
                                              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13,
                                            )),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
