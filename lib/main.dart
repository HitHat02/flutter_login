import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FastAPI Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      routes: {
        "/home": (context) => const HomeScreen(), // 홈 화면 예제
      },
    );
  }
}

// 간단한 홈 화면 예제
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(child: Text("Welcome to the app!")),
    );
  }
}

class AuthService {
  final String baseUrl = "http://0.0.0.0:8000"; // FastAPI 서버 URL

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true; // 로그인 성공
    } else {
      return false; // 로그인 실패
    }
  }
}
