import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:dashboard/pages/login.dart';
import 'package:dashboard/pages/messager.dart';
import 'package:dashboard/pages/profile.dart';
import 'package:dashboard/pages/publication.dart';
import 'package:dashboard/pages/signale.dart';
import 'package:dashboard/pages/utilisateur.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

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
    return MaterialApp.router(
      title: 'Maaya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF3E0), // Couleur de fond de la page
        brightness: Brightness.light,
        primaryColor: const Color(0xFF914B14), // Couleur principale de l'application
      ),
      // Utilisation de GoRouter pour la gestion des routes
      routerConfig: _router,
    );
  }
}

// Routeur défini de manière globale
final GoRouter _router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => FirebaseAuth.instance.currentUser == null ? '/login' : '/dashboard',
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => Dashboard(),
    ),
    GoRoute(
      path: '/utilisateur',
      name: 'utilisateur',
      builder: (context, state) => Utilisateur(),
    ),
    GoRoute(
      path: '/publication',
      name: 'publication',
      builder: (context, state) => Publication(),
    ),
    GoRoute(
      path: '/signale',
      name: 'signale',
      builder: (context, state) => Signale(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const Profile(),
    ),
    GoRoute(
      path: '/messager',
      name: 'messager',
      builder: (context, state) => const Messager(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const Login(),
    ),
  ],
  // Gestion des erreurs de navigation (page introuvable)
  errorBuilder: (context, state) => const Scaffold(
    body: Center(
      child: Text('404: Page non trouvée'),
    ),
  ),
);
