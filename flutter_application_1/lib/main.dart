import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      home: AuthWrapper(), // Changed from LoginScreen() to AuthWrapper()
      debugShowCheckedModeBanner: false,
      routes: {
        '/todo': (context) => TodoScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}

// New AuthWrapper widget to handle authentication state
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If user is logged in, go to TodoScreen
        if (snapshot.hasData && snapshot.data != null) {
          return TodoScreen();
        }

        // If user is not logged in, go to LoginScreen
        return LoginScreen();
      },
    );
  }
}
