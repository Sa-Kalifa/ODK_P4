import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../parametre/couleur.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  bool _obscurePassword = true;
  final formkey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  // Méthode pour se connecter avec Firebase Auth
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
      // Authentification avec Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      // Vérifier si le compte est bloqué en récupérant le champ `isBlocked` dans Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userSnapshot.exists && userSnapshot['isBlocked'] == true) {
        Navigator.pop(context);  // Fermer le chargement
        _showBlockedMessage(context);
        return;
      }

      // Si l'utilisateur n'est pas bloqué, continuer avec la vérification du rôle
      await RoleManager().checkUserRole(context, userCredential.user!);

    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);  // Ferme le chargement
      if (e.code == 'user-not-found') {
        emailMessage(context);
      } else if (e.code == 'wrong-password') {
        passwordMessage(context);
      }
    }
  }

// Affiche un message si le compte est bloqué
  void _showBlockedMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Compte bloqué'),
          content: Text('Votre compte a été bloqué. Veuillez contacter l\'administrateur.'),
        );
      },
    );
  }


  // Affiche un message d'erreur pour l'email incorrect
  void emailMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Email incorrect'),
        );
      },
    );
  }

  // Affiche un message d'erreur pour le mot de passe incorrect
  void passwordMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Mot de passe incorrect'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Couleur.bg, Couleur.blanc],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Row(
            children: [
              if (isDesktop) Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Image.asset(
                    'lib/assets/images/Logo01.png', // Image illustrative moderne
                    fit: BoxFit.contain,
                    height: 300,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 40.0,
                    horizontal: isDesktop ? 80.0 : 20.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(40.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Bienvenue',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Champ de saisie pour l'Email
                          TextFormField(
                            controller: emailcontroller,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined, color: Couleur.pr),
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Champ de saisie pour le mot de passe
                          TextFormField(
                            controller: passwordcontroller,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: Icon(Icons.lock_outline, color: Couleur.pr),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Couleur.pr,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              labelStyle: const TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Mot de passe oublié?',
                              style: TextStyle(color: Couleur.pr),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Bouton "Se connecter"
                          GestureDetector(
                            onTap: () {
                              if (formkey.currentState!.validate()) {
                                signUserIn(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Couleur.pr,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Se connecter',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Pas de compte?",
                                style: TextStyle(color: Colors.black),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/inscription');
                                },
                                child: const Text(
                                  "S'inscrire",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Couleur.pr,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleManager {
  // Méthode pour vérifier le rôle de l'utilisateur après connexion
  Future<void> checkUserRole(BuildContext context, User user) async {
    try {
      // Récupération des informations de l'utilisateur dans Firestore
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final role = snapshot['role'];

        // Vérifie si l'utilisateur est un administrateur
        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>  Dashboard(),
            ),
          );
          //Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          // Si l'utilisateur n'est pas un admin, affiche une page d'erreur
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ErrorPage(),
            ),
          );
        }
      } else {
        Navigator.pop(context); // Fermer le chargement en cas d'erreur
        print('Document utilisateur non trouvé');
      }
    } catch (e) {
      Navigator.pop(context); // Fermer le chargement en cas d'erreur
      print('Erreur lors de la récupération du rôle: $e');
    }
  }
}

// Page d'erreur pour les utilisateurs non-admins
class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Accès refusé",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Seuls les administrateurs peuvent accéder à cette page.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Retour à la page de connexion', style: TextStyle(color: Couleur.pr),),
            ),
          ],
        ),
      ),
    );
  }
}