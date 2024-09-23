import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentification/inscription.dart';
import 'firebase_options.dart';

import 'package:projetm/mobiles/acceuil/accueil.dart';
import 'package:projetm/mobiles/acceuil/histoire.dart';
import 'package:projetm/mobiles/notification/notification.dart';
import 'package:projetm/mobiles/profile/profile.dart';
import 'authentification/login_page.dart';
import 'dashbord/const/constant.dart';
import 'dashbord/screens/main_screen.dart';
import 'dashbord/screens/message_page.dart';
import 'dashbord/screens/profile_page.dart';
import 'dashbord/screens/publication_page.dart';
import 'dashbord/screens/signale_page.dart';
import 'dashbord/screens/user_page.dart';
import 'mobiles/acceuil/app_bar.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDIvgAc1Y8OGEO0ErHvHYRkejBUbJ_irm8',
      appId: '1:376188796304:web:586b5608bfaa4a5efc8715',
      messagingSenderId: '376188796304',
      projectId: 'projetm-b6fae',
      authDomain: 'projetm-b6fae.firebaseapp.com',
      storageBucket: 'projetm-b6fae.appspot.com',
    ),);

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
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.dark,
      ),

      routes: {
        // pour le Dashboard Admin
        '/dashboard': (context) => MainScreen(),
        '/utilisateur': (context) => UserPage(),
        '/publication': (context) => PublicationPage(),
        '/signale': (context) => SignalePage(),
        '/profile_admin': (context) => ProfilePage(),
        '/messager': (context) => MessagePage(),

        // pour les Membre
        '/login': (context) => LoginPage(),
        '/accueil': (context) => Accueil(),
        '/profile': (context) => Profile(),
        '/inscription': (context) => Inscription(),
        '/notification': (context) => NotificationPage(),
        '/histoire': (context) => Histoire(),

      },
       // home: CustomBottomAppBar(currentIndex: 1,),
      // home: Profile(),
      home:  const LoginPage(),
    );
  }
}