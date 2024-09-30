import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("lib/assets/images/avatar.png"),
        const SizedBox(height: 40,),
        const Text(
          "Avec sa je veut que tu as de l'admiration",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 40,),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Si vous ete la c'est que vous avez de la chance, on a un systeme de coach adapter de toute type de proble",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
