
/*
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Poste extends StatefulWidget {
  const Poste({super.key});

  @override
  State<Poste> createState() => _PosteState();
}

class _PosteState extends State<Poste> {
  bool _obscurePassword = true;
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

    Future<void> uploadImageToFirebase(File image) async {
      setState(() {
        isLoading = true;
      });
      try {
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("image/${DateTime.now().microsecondsSinceEpoch}.png");
        await reference.putFile(image).whenComplete(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              content: Text("Image Enregistre avec Succes"),
            ),
          );
        });
        imageUrl = await reference.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Image non Enregistre"),
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    }

    Future<void> pickImage() async {
      try {
        XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (res != null) {
          await uploadImageToFirebase(File(res.path));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Image non Enregistre"),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.amber[200],
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: CircleAvatar(
                      radius: 100,
                      child: imageUrl == null
                          ? const Icon(Icons.person,
                              color: Colors.grey, size: 200)
                          : SizedBox(
                              height: 200,
                              child: ClipOval(
                                  child: Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                              ))),
                    ),
                  ),
                ),

                // Position de l'image lors de la selectionne et afficher
                if (isLoading)
                  const Positioned(
                    top: 70,
                    right: 190,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),

                // Position de l'image par defaut

              ],
            ),
            const SizedBox(
              height: 40,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.black), // Texte en noir
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email,
                    color: Colors.black), // Icône pour l'email
                labelStyle: TextStyle(
                    color: Colors.black), // Style de texte pour l'étiquette
                border: OutlineInputBorder(), // Bordure pour le champ
              ),
              keyboardType:
                  TextInputType.emailAddress, // Type de saisie pour l'email
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
              style: const TextStyle(color: Colors.black), // Texte en noir
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock,
                    color: Colors.black), // Icône pour le mot de passe
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off, // Icône pour afficher/masquer
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword =
                          !_obscurePassword; // Permet de masquer ou afficher le mot de passe
                    });
                  },
                ),
                labelStyle: const TextStyle(
                    color: Colors.black), // Style de l'étiquette
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
          ],
        ),
      ),
    );
  }
}
*/