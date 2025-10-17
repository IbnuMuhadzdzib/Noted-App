import 'package:flutter/material.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/widgets/login_page.dart';
import 'widgets/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Catatan Lengkap',
      theme: ThemeData(
         colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFFFEC325), // Lavender Soda
          onPrimary: Colors.white,
          secondary: const Color(0xFFF1D384),
          onSecondary: Colors.black,
          error: Colors.redAccent,
          onError: Colors.white,
          background: const Color(0xFFFFE1A8),
          onBackground: Colors.black,
          surface: const Color(0xFFF1D384),
          onSurface: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
