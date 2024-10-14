import 'package:flutter/material.dart';

class AproposConfd extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Politique de Confidentialité',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF914b14),
        iconTheme: const IconThemeData(color: Colors.white), // Change la couleur du back button en blanc
      ),
      body: const Padding(
        padding: EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plateforme d\'échange d\'expérience et de témoignage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Votre confidentialité est importante pour nous. Nous recueillons vos informations personnelles uniquement dans le but de fournir un meilleur service. Voici quelques points clés de notre politique de confidentialité :',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '- Nous ne partagerons pas vos informations avec des tiers sans votre consentement.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '- Vous pouvez demander la suppression de vos données à tout moment.',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '- Nous utilisons des mesures de sécurité pour protéger vos informations.',
                style: TextStyle(fontSize: 16),
              ),
              // Ajoutez plus d'informations sur la confidentialité si nécessaire
            ],
          ),
        ),
      ),
    );
  }
}
