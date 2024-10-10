import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projetm/poste.dart';
import 'authentification/inscription.dart';
import 'firebase_options.dart';

import 'package:projetm/mobiles/acceuil/accueil.dart';
import 'package:projetm/mobiles/acceuil/histoire.dart';
import 'package:projetm/mobiles/notification/notification.dart';
import 'authentification/login_page.dart';
import 'mobiles/introduction/intro_page.dart';
import 'mobiles/profile/profile.dart';



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
      // routerConfig: routerConfig,
      routes: {
        // Routes pour la navigation
        /*
          '/dashboard': (context) => MainScreen(),
          '/utilisateur': (context) => UserPage(),
          '/publication': (context) => PublicationPage(),
          '/signale': (context) => SignalePage(),
          '/profile_admin': (context) => ProfilePage(),
          '/messager': (context) => MessagePage(),
*/
        '/login': (context) => LoginPage(),
        '/accueil': (context) => Accueil(),
        '/profile': (context) => Profile(),
        '/inscription': (context) => Inscription(),
        '/notification': (context) => NotificationPage(),
        '/histoire': (context) => Histoire(),
      },
      // Définissez la page d'accueil ou la page par défaut de votre application
      home: Accueil(),
    );
  }
}