import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/screens/login_screen.dart';

class HomePage extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Text(
          "Login successful. Welcome ${user?.email ?? 'User'}!",
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          child: Text('Logout'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ),
    );
  }
}
