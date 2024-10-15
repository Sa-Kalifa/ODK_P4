import 'package:flutter/material.dart';

class Messager extends StatefulWidget {
  const Messager({super.key});

  @override
  State<Messager> createState() => _MessagerState();
}

class _MessagerState extends State<Messager> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Messager',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
