import 'package:flutter/material.dart';
import '../widgets/menu_widget.dart';

  class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
  }

  class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Page Principale'),
      backgroundColor: Color(0xFF1E212D),
      ),
      drawer: SideMenuWidget(), // Utilisation du menu personnalisé
      body: const  Center(
      child: Text('Contenu de la page principale'),
      ),
    );
  }
  }
