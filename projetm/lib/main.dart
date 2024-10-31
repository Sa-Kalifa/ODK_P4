import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projetm/mobiles/introduction/intro_page.dart';
import 'package:projetm/authentification/inscription.dart';
import 'package:projetm/firebase_options.dart';

import 'package:projetm/mobiles/acceuil/accueil.dart';
import 'package:projetm/mobiles/acceuil/histoire.dart';
import 'package:projetm/mobiles/notification/notification.dart';
import 'package:projetm/authentification/login_page.dart';
import 'package:projetm/mobiles/profile/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maaya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF3E0), // Couleur de fond de la page
        brightness: Brightness.light,
        primaryColor: const Color(0xFF914B14), // Couleur principale de l'application
      ),

      // Gestionnaire de routes dynamiques pour le passage de paramètres
      onGenerateRoute: (settings) {
        if (settings.name == '/notification') {
          // Obtient le paramètre otherUserId passé comme argument
          final String otherUserId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => NotificationPage(otherUserId: otherUserId),
          );
        }
        // Ajoutez d'autres routes dynamiques si besoin
        return null;
      },

      // Routes de navigation statiques
      routes: {
        '/login': (context) => LoginPage(),
        '/accueil': (context) => Accueil(),
        '/profile': (context) => Profile(),
        '/inscription': (context) => Inscription(),
        '/histoire': (context) => Histoire(),
      },
      // Page d'accueil de l'application
      home: LoginPage(),
    );
  }
}
