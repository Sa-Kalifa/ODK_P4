import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Vous êtes déconnecté.',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
