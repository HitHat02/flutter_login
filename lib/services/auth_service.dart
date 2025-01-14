import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://13.211.150.198:8000"; // FastAPI 서버 URL

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    // 서버 응답 확인
    if (response.statusCode == 200) {
      return true; // 로그인 성공
    } else {
      return false; // 로그인 실패 (아이디 또는 비밀번호 불일치)
    }
  }
}
