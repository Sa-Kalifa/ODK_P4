import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../dashbord/screens/main_screen.dart';
import '../mobiles/acceuil/accueil.dart';
import 'login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Utilisateur connecté
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  final role = snapshot.data!['role'];

                  if (role == 'Admin') {
                    return  MainScreen();
                  } else if (role == 'Membre') {
                    return  Accueil();
                  }
                }

                return const LoginPage(); // Si le rôle n'est pas trouvé
              },
            );
          } else {
            // Utilisateur non connecté
            return const LoginPage();
          }
        },
      ),
    );
  }
}

Future<void> registerUser(String email, String password, String role) async {
  UserCredential userCredential = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password);

  // Ajouter un document utilisateur avec le rôle dans Firestore
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userCredential.user!.uid)
      .set({
    'email': email,
    'role': role,
  });
}










