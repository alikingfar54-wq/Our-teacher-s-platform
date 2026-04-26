import 'dart:convert';
import 'package:http/http.dart' as http;

// ===== رابط API - غير هذا الرابط بعد النشر =====
const String kApiBase = 'https://YOUR_API_DOMAIN/api';

class ApiService {
  final String? token;

  const ApiService({this.token});

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ===== تسجيل دخول المالك =====
  Future<Map<String, dynamic>> ownerLogin(String email, String password) async {
    final res = await http.post(
      Uri.parse('$kApiBase/owner/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== تسجيل دخول الأستاذ =====
  Future<Map<String, dynamic>> teacherLogin(String email, String password) async {
    final res = await http.post(
      Uri.parse('$kApiBase/auth/teacher/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== تسجيل أستاذ جديد =====
  Future<Map<String, dynamic>> teacherRegister(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$kApiBase/auth/teacher/register'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== تفعيل حساب الأستاذ =====
  Future<Map<String, dynamic>> teacherActivate(int teacherId, String code) async {
    final res = await http.post(
      Uri.parse('$kApiBase/auth/teacher/activate'),
      headers: _headers,
      body: jsonEncode({'teacherId': teacherId, 'code': code}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== تسجيل دخول الطالب =====
  Future<Map<String, dynamic>> studentLogin(String email, String password) async {
    final res = await http.post(
      Uri.parse('$kApiBase/auth/student/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== تسجيل طالب جديد =====
  Future<Map<String, dynamic>> studentRegister(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$kApiBase/auth/student/register'),
      headers: _headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== اشتراك الطالب بكود =====
  Future<Map<String, dynamic>> studentSubscribe(String teacherCode) async {
    final res = await http.post(
      Uri.parse('$kApiBase/auth/student/subscribe'),
      headers: _headers,
      body: jsonEncode({'teacherCode': teacherCode}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== قائمة المعلمين (مالك) =====
  Future<List<dynamic>> getTeachers() async {
    final res = await http.get(Uri.parse('$kApiBase/owner/teachers'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ في جلب البيانات';
    return jsonDecode(res.body);
  }

  // ===== توليد كود تفعيل للأستاذ =====
  Future<Map<String, dynamic>> generateTeacherCode(int teacherId) async {
    final res = await http.post(
      Uri.parse('$kApiBase/owner/teachers/$teacherId/generate-code'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== تبديل تفعيل الأستاذ =====
  Future<Map<String, dynamic>> toggleTeacherActivation(int teacherId) async {
    final res = await http.post(
      Uri.parse('$kApiBase/owner/teachers/$teacherId/toggle-activation'),
      headers: _headers,
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== أخبار الطالب =====
  Future<List<dynamic>> getStudentNews() async {
    final res = await http.get(Uri.parse('$kApiBase/student/news'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== امتحانات الطالب =====
  Future<List<dynamic>> getStudentExams() async {
    final res = await http.get(Uri.parse('$kApiBase/student/exams'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== تسليم امتحان =====
  Future<Map<String, dynamic>> submitExam(int examId, Map<String, String> answers) async {
    final res = await http.post(
      Uri.parse('$kApiBase/student/exams/$examId/submit'),
      headers: _headers,
      body: jsonEncode({'answers': answers}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== دورات الطالب المتاحة =====
  Future<List<dynamic>> getStudentCourses() async {
    final res = await http.get(Uri.parse('$kApiBase/student/courses'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== محاضرات الأستاذ =====
  Future<List<dynamic>> getTeacherLectures() async {
    final res = await http.get(Uri.parse('$kApiBase/teacher/lectures'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== أخبار الأستاذ =====
  Future<List<dynamic>> getTeacherNews() async {
    final res = await http.get(Uri.parse('$kApiBase/teacher/news'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== إنشاء خبر =====
  Future<Map<String, dynamic>> createNews(String content, String? targetGroup) async {
    final res = await http.post(
      Uri.parse('$kApiBase/teacher/news'),
      headers: _headers,
      body: jsonEncode({'content': content, 'targetGroup': targetGroup}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) throw data['error'] ?? 'خطأ';
    return data;
  }

  // ===== محادثات الدردشة =====
  Future<List<dynamic>> getChatConversations() async {
    final res = await http.get(Uri.parse('$kApiBase/chat/conversations'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== رسائل محادثة =====
  Future<List<dynamic>> getChatMessages(int partnerId) async {
    final res = await http.get(Uri.parse('$kApiBase/chat/messages/$partnerId'), headers: _headers);
    if (res.statusCode != 200) throw 'خطأ';
    return jsonDecode(res.body);
  }

  // ===== إرسال رسالة =====
  Future<Map<String, dynamic>> sendMessage(int receiverId, String content, {bool isCodeRequest = false}) async {
    final res = await http.post(
      Uri.parse('$kApiBase/chat/send'),
      headers: _headers,
      body: jsonEncode({'receiverId': receiverId, 'content': content, 'isCodeRequest': isCodeRequest}),
    );
    final data = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) throw data['error'] ?? 'خطأ';
    return data;
  }
}
