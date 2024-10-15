import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/parametre/couleur.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? user;
  String? userProfileUrl;
  String? userRole;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserData();
  }

  void _loadUserData() async {
    if (user != null) {
      DocumentSnapshot userData =
      await _firestore.collection('users').doc(user!.uid).get();

      // Récupération de l'URL de la photo de profil dans Firebase Storage
      String storagePath = "user_images/${user!.uid}.jpg";
      try {
        userProfileUrl = await _storage.ref(storagePath).getDownloadURL();
      } catch (e) {
        print("Erreur lors de la récupération de l'image : $e");
      }

      setState(() {
        _nameController.text = userData['nom'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['telephone'];
        userRole = userData['role'];
      });
    }
  }

  void _updateProfile() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'nom': _nameController.text,
        'email': _emailController.text,
        'telephone': _phoneController.text,
      });
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Couleur.bg,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Couleur.blanc, fontSize: 20),),
        backgroundColor: Couleur.pr,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white,),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const SizedBox(height: 40,),
            // Première ligne: Image, Email, Rôle à gauche + Bouton Modifier à droite
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: userProfileUrl != null
                          ? NetworkImage(userProfileUrl!)
                          : null,
                      child: userProfileUrl == null
                          ? Icon(Icons.person, size: 40, color: Colors.black)
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                              color: Couleur.pr,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userRole ?? 'Utilisateur',
                          style: const TextStyle(
                              color: Couleur.pr, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Couleur.pr,
                  ),
                  child: const Text('Modifier', style: TextStyle(color: Couleur.blanc),),
                ),
              ],
            ),
            const SizedBox(height: 70),

            // Deuxième section: Formulaire en deux colonnes
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colonne de gauche: Nom et Téléphone
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Nom et Prénom',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Colonne de droite: Email et Mot de Passe
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Adresse Email',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Mot de Passe',
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
