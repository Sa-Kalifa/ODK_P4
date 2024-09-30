import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../dashbord/screens/main_screen.dart';
import '../mobiles/acceuil/accueil.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text editing controller
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool _obscurePassword = true; // Variable pour cacher ou montrer le mot de passe


  // Clé de formulaire pour validation
  final formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  // Méthode pour email et mot de passe
  void signUserIn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      // Appel de la méthode pour gérer les rôles après la connexion réussie
      RoleManager().RoleUser(context);

    } on FirebaseAuthException catch (e) {
      // Arrêt de la fenêtre de chargement
      Navigator.pop(context);
      // Gérer l'erreur ici
      if (e.code == 'user-not-found') {
        emailMessage(context);
      } else if (e.code == 'wrong-password') {
        passwordMessage(context);
      }
    }
  }

  // Les Méthodes de Message d'erreur
  // Email
  void emailMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Email Incorrect'),
        );
      },
    );
  }

  // Mot de Passe
  void passwordMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Mot de Passe Incorrect'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF3E0),
      body: SafeArea(
        child: Center(
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/images/Logo01.png', height: 80),
                const SizedBox(height: 25),
                const Text(
                  'Se Connecter',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

// ************************ Les Inputs ************************************

          // Champ de saisie pour l'Email
                TextFormField(
                  controller: emailcontroller,
                  style: const TextStyle(color: Colors.black), // Texte en noir
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.black), // Icône pour l'email
                    labelStyle: TextStyle(color: Colors.black), // Style de texte pour l'étiquette
                    border: OutlineInputBorder(), // Bordure pour le champ
                  ),
                  keyboardType: TextInputType.emailAddress, // Type de saisie pour l'email
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },

                ),
                const SizedBox(height: 20), // Espacement entre les champs

            // Champ de saisie pour le mot de passe
                TextFormField(
                  controller: passwordcontroller,
                  style: const TextStyle(color: Colors.black), // Texte en noir
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock, color: Colors.black), // Icône pour le mot de passe
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off, // Icône pour afficher/masquer
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword; // Permet de masquer ou afficher le mot de passe
                        });
                      },
                    ),
                    labelStyle: const TextStyle(color: Colors.black), // Style de l'étiquette
                    border: const OutlineInputBorder(), // Bordure pour le champ
                  ),
                  obscureText: _obscurePassword, // Gérer l'affichage du texte
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },

                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Mot de passe Oublié',
                        style: TextStyle(
                          color: Color(0xFF914b14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                MyBouton(
                  onTap: () {
                    if (formkey.currentState!.validate()) {
                      signUserIn(context);
                    }
                  },
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Vous n’avez pas de compte ?,",
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/inscription');
                      },
                      child: const Text(
                        "S’inscrire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF914b14), // Couleur du lien
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ******************** La gestion de Role **********************************

class RoleManager {
  // Méthode qui gère les rôles des utilisateurs
  void RoleUser(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (snapshot.exists) {
          final role = snapshot['role'];
          print("Rôle trouvé: $role");

          if (role == 'Admin') {
            print("Redirection vers AdminDashboard");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else if (role == 'Membre') {
            print("Redirection vers Accueil");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Accueil()),
            );
          } else if (role == 'Partenaire') {
            print("Redirection vers Accueil");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Accueil()),
            );
          }
          else {
            print("Rôle inconnu. Redirection vers LoginPage");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        } else {
          print("Document utilisateur non trouvé. Redirection vers LoginPage");
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) =>  Accueil()),
          );
        }
      } else {
        print("Utilisateur non authentifié. Redirection vers LoginPage");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      print("Erreur lors de la récupération du rôle: $e");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }


  // Fonction pour enregistrer un utilisateur avec un rôle
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
}

// ************************ Boutton ****************************************
class MyBouton extends StatelessWidget {
  final Function()? onTap;
  const MyBouton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 50),
        decoration: BoxDecoration(
          color: Color(0xFF914b14),
          borderRadius: BorderRadius.circular(8),
        ),
        child:const Text(
          "Connexion",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white
          ),
        ),
      ),
    );
  }
}
