import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../welcome_screen.dart';

// ===== الشاشة الرئيسية للأستاذ =====
class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final token = auth.token ?? '';
    final user = auth.user ?? {};

    final pages = [
      TeacherLecturesTab(token: token),
      TeacherNewsTab(token: token),
      TeacherExamsTab(token: token),
      TeacherChatTab(token: token),
      TeacherRecordsTab(token: token),
      TeacherCodesTab(token: token),
    ];

    return Theme(
      data: teacherTheme(),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(key: ValueKey(_currentIndex), child: pages[_currentIndex]),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.teacherBg,
            border: Border(top: BorderSide(color: AppColors.teacher.withOpacity(0.2))),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.teacher,
            unselectedItemColor: Colors.white.withOpacity(0.35),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600, fontSize: 10),
            unselectedLabelStyle: GoogleFonts.cairo(fontSize: 9),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.play_circle_rounded), label: 'المحاضرات'),
              BottomNavigationBarItem(icon: Icon(Icons.rss_feed_rounded), label: 'الأخبار'),
              BottomNavigationBarItem(icon: Icon(Icons.description_rounded), label: 'الامتحانات'),
              BottomNavigationBarItem(icon: Icon(Icons.message_rounded), label: 'التواصل'),
              BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: 'السجلات'),
              BottomNavigationBarItem(icon: Icon(Icons.key_rounded), label: 'الأكواد'),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== تبويب المحاضرات =====
class TeacherLecturesTab extends StatelessWidget {
  final String token;
  const TeacherLecturesTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return _TabBase(
      title: 'المحاضرات',
      icon: Icons.play_circle_rounded,
      color: AppColors.teacher,
      token: token,
      emptyMessage: 'لا توجد محاضرات',
      onAdd: () {},
    );
  }
}

// ===== تبويب الأخبار =====
class TeacherNewsTab extends StatefulWidget {
  final String token;
  const TeacherNewsTab({super.key, required this.token});

  @override
  State<TeacherNewsTab> createState() => _TeacherNewsTabState();
}

class _TeacherNewsTabState extends State<TeacherNewsTab> {
  List _news = [];
  bool _loading = true;
  final _contentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService(token: widget.token).getTeacherNews();
      if (mounted) setState(() { _news = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF051A18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('خبر جديد', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: _contentCtrl,
          maxLines: 4,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'محتوى الخبر...',
            hintStyle: GoogleFonts.cairo(color: Colors.white.withOpacity(0.3)),
            filled: true,
            fillColor: AppColors.teacher.withOpacity(0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () { _contentCtrl.clear(); Navigator.pop(context); },
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacher),
            onPressed: () async {
              try {
                await ApiService(token: widget.token).createNews(_contentCtrl.text.trim(), null);
                _contentCtrl.clear();
                if (mounted) { Navigator.pop(context); _load(); }
              } catch (_) {}
            },
            child: Text('نشر', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF020F0E), Color(0xFF051A18)]),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.small(
                    backgroundColor: AppColors.teacher,
                    onPressed: _showAddDialog,
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                  Text('الأخبار', style: GoogleFonts.cairo(
                    fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teacher))
                  : _news.isEmpty
                      ? Center(child: Text('لا توجد أخبار', style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.4))))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _news.length,
                          itemBuilder: (_, i) {
                            final n = _news[i] as Map;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: AppColors.teacher.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: AppColors.teacher.withOpacity(0.2)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(n['content'] ?? '', style: GoogleFonts.cairo(
                                  color: Colors.white,
                                ), textAlign: TextAlign.right),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== تبويبات بسيطة =====
class TeacherExamsTab extends StatelessWidget {
  final String token;
  const TeacherExamsTab({super.key, required this.token});
  @override
  Widget build(BuildContext context) => _TabBase(title: 'الامتحانات', icon: Icons.description_rounded, color: AppColors.teacher, token: token, emptyMessage: 'لا توجد امتحانات', onAdd: () {});
}

class TeacherRecordsTab extends StatelessWidget {
  final String token;
  const TeacherRecordsTab({super.key, required this.token});
  @override
  Widget build(BuildContext context) => _TabBase(title: 'سجل الطلاب', icon: Icons.people_rounded, color: AppColors.teacher, token: token, emptyMessage: 'لا توجد سجلات', onAdd: () {});
}

class TeacherCodesTab extends StatelessWidget {
  final String token;
  const TeacherCodesTab({super.key, required this.token});
  @override
  Widget build(BuildContext context) => _TabBase(title: 'الأكواد', icon: Icons.key_rounded, color: AppColors.teacher, token: token, emptyMessage: 'لا توجد أكواد', onAdd: () {});
}

// ===== تبويب التواصل للأستاذ =====
class TeacherChatTab extends StatefulWidget {
  final String token;
  const TeacherChatTab({super.key, required this.token});

  @override
  State<TeacherChatTab> createState() => _TeacherChatTabState();
}

class _TeacherChatTabState extends State<TeacherChatTab> {
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

  Future<void> _send(String text) async {
    if (_selectedConv == null || text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ApiService(token: widget.token).sendMessage(_selectedConv!['partnerId'], text);
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
    if (_selectedConv != null) return _buildChat();
    return _buildList();
  }

  Widget _buildList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF020F0E), Color(0xFF051A18)]),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('التواصل', style: GoogleFonts.cairo(
                fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white,
              )),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teacher))
                  : _conversations.isEmpty
                      ? Center(child: Text('لا توجد محادثات', style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.4))))
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          color: AppColors.teacher,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _conversations.length,
                            itemBuilder: (_, i) {
                              final c = _conversations[i] as Map;
                              final hasRequest = c['hasCodeRequest'] == true;
                              return GestureDetector(
                                onTap: () {
                                  setState(() { _selectedConv = Map<String, dynamic>.from(c); });
                                  _loadMessages(c['partnerId']);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: hasRequest
                                        ? AppColors.warning.withOpacity(0.05)
                                        : AppColors.teacher.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: hasRequest
                                        ? AppColors.warning.withOpacity(0.4)
                                        : AppColors.teacher.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      if (hasRequest)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Icon(Icons.key_rounded, color: AppColors.warning, size: 18),
                                        ),
                                      Container(
                                        width: 50, height: 50,
                                        decoration: BoxDecoration(color: AppColors.teacher, shape: BoxShape.circle),
                                        child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(c['partnerName'] ?? '', style: GoogleFonts.cairo(
                                              color: Colors.white, fontWeight: FontWeight.w700,
                                            )),
                                            if (c['partnerGrade'] != null)
                                              Text(c['partnerGrade'], style: GoogleFonts.cairo(
                                                color: AppColors.teacher, fontSize: 12,
                                              )),
                                            Text(c['lastMessage'] ?? 'ابدأ المحادثة...', style: GoogleFonts.cairo(
                                              color: Colors.white.withOpacity(0.5), fontSize: 12,
                                            ), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

  Widget _buildChat() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF020F0E), Color(0xFF051A18)]),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.teacher.withOpacity(0.2))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.teacher),
                    onPressed: () => setState(() { _selectedConv = null; _messages = []; }),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(_selectedConv?['partnerName'] ?? '', style: GoogleFonts.cairo(
                          color: Colors.white, fontWeight: FontWeight.w700,
                        )),
                        Text(_selectedConv?['partnerGrade'] ?? 'طالب', style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.4), fontSize: 12,
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.teacher, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final m = _messages[i] as Map;
                  final isMe = m['senderRole'] == 'teacher';
                  final isCodeReq = m['isCodeRequest'] == true && !isMe;
                  return Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      if (isCodeReq)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.key_rounded, color: AppColors.warning, size: 14),
                              const SizedBox(width: 6),
                              Text('طلب كود اشتراك', style: GoogleFonts.cairo(
                                color: AppColors.warning, fontSize: 12,
                              )),
                            ],
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.teacher : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(m['content'] ?? '', style: GoogleFonts.cairo(
                          color: Colors.white, fontSize: 14,
                        )),
                      ),
                    ],
                  );
                },
              ),
            ),
            // زر إرسال كود
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: GestureDetector(
                onTap: () async {
                  final code = await _showCodeDialog();
                  if (code != null && code.isNotEmpty) {
                    _send('🔑 كود الاشتراك الخاص بك: ${code.toUpperCase()}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.teacher.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.teacher.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.key_rounded, color: AppColors.teacher, size: 18),
                      const SizedBox(width: 8),
                      Text('إرسال كود للطالب', style: GoogleFonts.cairo(
                        color: AppColors.teacher, fontWeight: FontWeight.w600, fontSize: 13,
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _send(_inputCtrl.text.trim()),
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.teacher, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.teacher.withOpacity(0.4), blurRadius: 12)],
                      ),
                      child: _sending
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
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
                          borderSide: BorderSide(color: AppColors.teacher.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: AppColors.teacher.withOpacity(0.3)),
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

  Future<String?> _showCodeDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF051A18),
        title: Text('أدخل الكود', style: GoogleFonts.cairo(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.cairo(color: Colors.white, letterSpacing: 3),
          decoration: InputDecoration(
            hintText: 'XXXX-XXXX',
            filled: true,
            fillColor: AppColors.teacher.withOpacity(0.08),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.white.withOpacity(0.5)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teacher),
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: Text('إرسال', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }
}

// ===== قالب تبويب بسيط =====
class _TabBase extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String token;
  final String emptyMessage;
  final VoidCallback onAdd;

  const _TabBase({
    required this.title,
    required this.icon,
    required this.color,
    required this.token,
    required this.emptyMessage,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF020F0E), Color(0xFF051A18)]),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.small(
                    backgroundColor: color,
                    onPressed: onAdd,
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                  Text(title, style: GoogleFonts.cairo(
                    fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white,
                  )),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 60, color: color.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(emptyMessage, style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.4), fontSize: 15,
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
