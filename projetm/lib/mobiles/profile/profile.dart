import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:projetm/mobiles/profile/aide.dart';
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
  String? imageUrl; // URL de l'image de l'utilisateur
  File? _selectedImage; // Variable pour stocker l'image sélectionnée

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
            imageUrl = userDoc['image_url']; // Récupérer l'URL de l'image de Firestore
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

  // Méthode pour sélectionner une image à partir de la galerie
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker(); // Crée une instance de ImagePicker
    // Ouvre la galerie pour sélectionner une image
    final pickedImage = await imagePicker.pickImage( // Remplacer getImage par pickImage
      source: ImageSource.gallery, // Source de l'image : galerie
      imageQuality: 50, // Qualité de l'image (0 à 100)
    );

    // Si une image a été sélectionnée
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path); // Enregistrer l'image sélectionnée
      });
      // Télécharge l'image sur Firebase Storage
      await _uploadImage();
    }
  }

  // Méthode pour télécharger l'image sur Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage != null) {
      // Référence vers Firebase Storage pour stocker l'image
      final storageRef = FirebaseStorage.instance
          .ref('user_images') // Dossier où l'image sera stockée
          .child('${currentUser!.uid}.png'); // Nom de l'image avec l'ID utilisateur

      try {
        print('Début du téléchargement de l\'image...');

        // Télécharge l'image sur Firebase Storage
        await storageRef.putFile(_selectedImage!);
        print('Téléchargement réussi.');

        // Récupère l'URL de l'image téléchargée
        final downloadUrl = await storageRef.getDownloadURL();
        print('URL de téléchargement récupérée : $downloadUrl');

        // Enregistre l'URL dans Firestore
        await FirebaseFirestore.instance
            .collection('users') // Collection d'utilisateurs
            .doc(currentUser!.uid) // Document correspondant à l'utilisateur
            .update({'image_url': downloadUrl}); // Met à jour le champ image_url

        print('Mise à jour de l\'URL dans Firestore réussie.');

        setState(() {
          imageUrl = downloadUrl; // Mettre à jour l'URL de l'image dans l'état
        });
      } on FirebaseException catch (e) {
        print('Erreur lors du téléchargement : ${e.message}');
        _showErrorSnackBar('Échec du téléchargement de l\'image : ${e.message ?? 'Erreur inconnue'}');
      } catch (e) {
        print('Erreur inattendue : $e');
        _showErrorSnackBar('Erreur inattendue lors du téléchargement de l\'image.');
      }
    }
  }


  // Méthode pour afficher un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
            'Profile',
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
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Ouvre la galerie pour sélectionner une image
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) // Affiche l'image sélectionnée
                      : imageUrl != null ? NetworkImage(imageUrl!) : null, // Affiche l'image de Firestore si disponible
                  child: _selectedImage == null && imageUrl == null // Affiche une icône si aucune image
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
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
                'Aide',
                style: TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Aide()),
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