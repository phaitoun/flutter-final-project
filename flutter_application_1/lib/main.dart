import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/todo_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAm9OlQf7SynPw3CqFDjnrVeCkKY4sSG8A",
      authDomain: "login-project-a2ba3.firebaseapp.com",
      projectId: "login-project-a2ba3",
      storageBucket: "login-project-a2ba3.firebasestorage.app",
      messagingSenderId: "851707731587",
      appId: "1:851707731587:web:7c3b8ffa81578b828385b6",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Name App',
      theme: AppTheme.lightTheme,
      home: TodoScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/todo': (context) => TodoScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
