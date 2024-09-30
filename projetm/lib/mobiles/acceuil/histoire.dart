import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'app_bar.dart';

class Histoire extends StatefulWidget {
  const Histoire({super.key});

  @override
  State<Histoire> createState() => _HistoireState();
}

class _HistoireState extends State<Histoire> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String _titre = '';
  String _categorie = 'Violence'; // Catégorie par défaut
  String _description = '';
  bool _isAnonymous = false; // État du switch

  List<File> _selectedFiles = []; // Liste des fichiers sélectionnés
  bool _isLoading = false;

  // Liste des catégories disponibles
  final List<String> _categories = ['Violence', 'Incivisme', 'Racisme', 'Immigration', 'Autre'];

  // Méthode pour choisir des fichiers avec FilePicker
  Future<void> _pickFiles() async {
    try {
      // Utiliser FilePicker pour sélectionner des images
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths.map((path) => File(path!)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la sélection des fichiers : $e')),
      );
    }
  }

  // Méthode pour ajouter le post dans Firestore et stocker les images sur Firebase Storage
  Future<void> _addPost() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Obtenir l'utilisateur connecté
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez vous connecter avant de poster.')),
          );
          return;
        }

        // Téléverser les images sur Firebase Storage et obtenir leurs URLs
        List<String> imageUrls = [];
        for (File file in _selectedFiles) {
          final storageRef = _storage.ref().child('posts/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
          final uploadTask = await storageRef.putFile(file);
          final imageUrl = await uploadTask.ref.getDownloadURL();
          imageUrls.add(imageUrl);
        }

        // Ajouter le post dans Firestore
        await _firestore.collection('posts').add({
          'titre': _titre,
          'categorie': _categorie,
          'description': _description,
          'images': imageUrls,
          'uid': user.uid,
          'userName': user.displayName ?? 'Utilisateur Anonyme',
          'createdAt': Timestamp.now(),
          'isAnonymous': _isAnonymous,
        });

        // Réinitialiser le formulaire après l'ajout
        _formKey.currentState!.reset();
        setState(() {
          _selectedFiles = [];
          _isAnonymous = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post ajouté avec succès!')),
        );
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.message}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0), // Couleur de fond modifiée
      appBar: AppBar(
        title: const Center(child: Text('Ajouter un Post')), // Titre centré
        automaticallyImplyLeading: false, // Retirer le bouton Back
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image et nom de l'utilisateur avec le switch
                if (user != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user.photoURL ?? ''),
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(user.displayName ?? 'Anonyme'),
                        ],
                      ),
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                const SizedBox(height: 20), // Espacement entre l'élément utilisateur et le formulaire
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _titre = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                // DropdownButton pour la catégorie
                DropdownButtonFormField<String>(
                  value: _categorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _categorie = newValue!;
                    });
                  },
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                ),
                const SizedBox(height: 30), // Ajout d'espace avant 'Choisir des Images'
                const Center(
                  child: Text(
                    'Choisir des Images',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.add_photo_alternate, size: 50, color: Colors.blue),
                    onPressed: _pickFiles,
                  ),
                ),
                if (_selectedFiles.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            _selectedFiles[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _addPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF914b14),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Poster', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 1),
    );
  }
}
