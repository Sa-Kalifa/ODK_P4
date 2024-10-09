import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page Contenue Ajustée"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Réduction de la taille de l'image en utilisant width et height
            Image.asset(
              "lib/assets/images/anonymous.png",
              width: 150, // Largeur de l'image réduite
              height: 150, // Hauteur de l'image réduite
            ),
            const SizedBox(height: 30),
            const Text(
              "Avec ça je veux que tu aies de l'admiration",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 24,
                color: Colors.black,
              ),
              textAlign: TextAlign.center, // Centrer le texte
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Si vous êtes là, c'est que vous avez de la chance. "
                    "Nous avons un système de coaching adapté à tout type de problème.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
