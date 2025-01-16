import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/download_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FastAPI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        "/home": (context) => const HomeScreen(), // 홈 화면
        "/auth": (context) => const LoginScreen(), // 로그인 화면
        "/upload": (context) => const UploadPage(), // 업로드
        "/download": (context) => const DownloadPage(), //다운로드
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/auth");
              },
              child: const Text("Go to Auth"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/upload");
              },
              child: const Text("Go to Upload"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/download");
              },
              child: const Text("Go to Download"),
            ),
          ],
        ),
      ),
    );
  }
}
