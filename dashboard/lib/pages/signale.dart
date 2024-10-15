import 'package:flutter/material.dart';

class Signale extends StatefulWidget {
  const Signale({super.key});

  @override
  State<Signale> createState() => _SignaleState();
}

class _SignaleState extends State<Signale> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Gestion des signalements',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
