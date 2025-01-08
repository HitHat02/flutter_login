import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000/auth"; // FastAPI 서버 주소
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // 회원가입
  Future<bool> signUp(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print("Signup Failed: ${response.body}");
      return false;
    }
  }

  // 로그인
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // JWT 토큰 저장
      await storage.write(key: "token", value: responseData["token"]);
      return true;
    } else {
      print("Login Failed: ${response.body}");
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await storage.delete(key: "token");
  }

  // 토큰 읽기
  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }
}
