import 'package:flutter/material.dart';
import 'package:projetm/mobiles/profile/aide.dart';
import 'package:url_launcher/url_launcher.dart';

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
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Politique de Confidentialité'),
                      content: const SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text('Nom de l\'application : Plateforme d\'échange d\'expérience et de témoignage'),
                            SizedBox(height: 10),
                            Text('Version de l\'application : 1.0.0'),
                            SizedBox(height: 10),
                            Text('Date de mise à jour : 12 octobre 2024'),
                            SizedBox(height: 10),
                            Text('Votre confidentialité est importante pour nous. Nous recueillons vos informations ...'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Fermer'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Politique de Confidentialité'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('À propos du Développeur'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: [
                            Text('Nom : Votre Nom'),
                            SizedBox(height: 10),
                            Text('Description : Développeur passionné par la technologie et l\'innovation.'),
                            SizedBox(height: 10),
                            Text('Vous pouvez me trouver ici :'),
                            SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                // Lien vers le portfolio
                                launchURL('https://votre-portfolio.com');
                              },
                              child: Text('Portfolio'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Lien vers le CV
                                launchURL('https://votre-cv.com');
                              },
                              child: Text('CV'),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Fermer'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('À propos du développeur'),
            ),
            SizedBox(height: 20), // Ajoutez un espacement
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Aide()),
                );
              },
              child: Row(
                children: [
                  const Icon(Icons.quiz_outlined, color: Color(0xFF914b14)),
                  SizedBox(width: 8), // Espace entre l'icône et le texte
                  const Text(
                    'Aide',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
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
