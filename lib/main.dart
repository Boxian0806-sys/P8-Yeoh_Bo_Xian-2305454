import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: LoginScreen(), // This forces the app to start at the Auth screen
      debugShowCheckedModeBanner: false, 
    );
  }
}