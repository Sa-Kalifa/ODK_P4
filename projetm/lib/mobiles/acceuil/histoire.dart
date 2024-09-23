import 'package:flutter/material.dart';

import 'app_bar.dart';

class Histoire extends StatefulWidget {
  const Histoire({super.key});

  @override
  State<Histoire> createState() => _HistoireState();
}

class _HistoireState extends State<Histoire> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 1),
    );
  }
}
