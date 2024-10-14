import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AproposDev extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'À propos du Développeur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF914b14),
        iconTheme: const IconThemeData(color: Colors.white), // Change la couleur du back button en blanc
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nom de l\'application : Plateforme d\'échange d\'expérience et de témoignage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              const Text(
                'Version de l\'application : 1.0.0',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              const Text(
                'Date de mise à jour : 12 octobre 2024',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              const Text(
                'Nom du Developpeur: Kalifa Sanogo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Description : Développeur passionné par la technologie et l\'innovation.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vous pouvez me trouver ici :',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Lien vers le portfolio
                  launchURL('https://votre-portfolio.com');
                },
                child: const Text('Portfolio'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Lien vers le CV
                  launchURL('https://votre-cv.com');
                },
                child: const Text('CV'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void launchURL(String url) async {
    // Utilisez le package url_launcher pour ouvrir les liens
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
