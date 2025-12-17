import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Ganti bagian MyApp di main.dart menjadi seperti ini:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: AuthService().userStatus,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Jika user sudah login, tampilkan halaman utama (kita buat nanti)
            return const HomeScreen(); 
          }
          // Jika belum login, tampilkan LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}

