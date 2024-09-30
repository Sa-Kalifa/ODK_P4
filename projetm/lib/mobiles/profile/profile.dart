import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../acceuil/app_bar.dart';
import 'edit_profile_page.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? currentUser;
  String userName = 'Chargement...'; // Placeholder par défaut pour le nom
  String userRole = 'Chargement...'; // Placeholder par défaut pour le rôle

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Récupérer les données de l'utilisateur connecté depuis Firestore
  Future<void> _getUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      print("UID de l'utilisateur connecté : ${currentUser!.uid}");

      try {
        // Requête Firestore pour récupérer les données de l'utilisateur
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users') // Collection: utilisateurs
            .doc(currentUser!.uid) // ID de l'utilisateur connecté
            .get();

        // Vérifiez si le document existe
        if (userDoc.exists) {
          print("Données de l'utilisateur récupérées : ${userDoc.data()}");

          setState(() {
            userName = userDoc['nom'] ?? 'Nom non disponible'; // Nom de l'utilisateur
            userRole = userDoc['role'] ?? 'Rôle non disponible'; // Rôle de l'utilisateur
          });
        } else {
          print("Aucun document trouvé pour cet utilisateur.");
        }
      } catch (e) {
        print('Erreur lors de la récupération des données Firestore: $e');

        if (e is FirebaseException) {
          print('Code de l\'erreur Firestore: ${e.code}');
          print('Message d\'erreur Firestore: ${e.message}');
        }
      }
    } else {
      print("Aucun utilisateur connecté.");
    }
  }


  // Déconnexion de l'utilisateur
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        title: const Text(
            'Profil',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const SizedBox.shrink(), // Retire l'icône de retour
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://via.placeholder.com/100'), // Image de l'utilisateur
              ),
            ),
            const SizedBox(height: 16),
            // Affichage du nom récupéré de Firestore
            Center(
              child: Text(
                userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF914b14)),
              ),
            ),
            // Affichage du rôle récupéré de Firestore
            Center(
              child: Text(
                'Rôle: $userRole',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 32),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF914b14)),
              title: const Text(
                'Modifier son Compte',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks_outlined, color: Color(0xFF914b14)),
              title: const Text(
                'Mes Publications',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz_outlined, color: Color(0xFF914b14)),
              title: const Text(
                'Mes Quizz',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Se Déconnecter',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                _signOut();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 3),
    );
  }
}
