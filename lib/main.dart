// ignore_for_file: use_build_context_synchronously

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gemini_demo/auth.dart';
import 'package:gemini_demo/chat_screen.dart';
import 'package:gemini_demo/firebase_options.dart';
import 'package:gemini_demo/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gen-AI Demo",
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: "/chat",
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/":
            return MaterialPageRoute(
              builder: (context) => const Splash(),
            );
          case "/auth":
            return MaterialPageRoute(
              builder: (context) => const AuthScreen(),
            );
          case "/chat":
            return MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            );
          default:
            return null;
        }
      },
    );
  }
}
