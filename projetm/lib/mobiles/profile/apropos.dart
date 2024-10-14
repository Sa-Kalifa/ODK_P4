import 'package:flutter/material.dart';
import 'package:projetm/mobiles/profile/aide.dart';
import 'package:projetm/mobiles/profile/apropos_confd.dart';
import 'package:projetm/mobiles/profile/apropos_dev.dart';

class Apropos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'À propos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF914b14),
        iconTheme: const IconThemeData(color: Colors.white), // Change la couleur du back button en blanc
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            ListTile(
              leading: const Icon(Icons.policy, color: Color(0xFF914b14)),
              title: const Text(
                'Politique de Confidentialité',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AproposConfd()),
                );
              },
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.accessibility_new_rounded, color: Color(0xFF914b14)),
              title: const Text(
                'À propos du développeur',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AproposDev()),
                );
              },
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF914b14)),
              title: const Text(
                'Aide',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Aide()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}