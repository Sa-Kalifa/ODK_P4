import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projetm/mobiles/acceuil/app_bar.dart';
import 'dart:io';


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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        // Mise à jour de l'état avec les fichiers sélectionnés
        setState(() {
          _selectedFiles = result.paths.where((path) => path != null).map((path) => File(path!)).toList();
        });
      } else {
        // Aucun fichier sélectionné
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun fichier sélectionné.')),
        );
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
          'userName': _isAnonymous ? 'Anonyme' : (user.displayName ?? 'Utilisateur Anonyme'),
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
        backgroundColor: const Color(0xFFFAF3E0),
        title: const Center(
          child: Text(
            'Ajouter un Post',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ), // Titre centré
        automaticallyImplyLeading: false, // Retirer le bouton Back
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user != null)
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoURL ?? ''),
                        radius: 20,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        _isAnonymous ? 'Anonyme' : (user.displayName ?? 'Nom non disponible'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value;
                          });
                        },
                        activeColor: const Color(0xFF914b14),
                      ),
                    ],
                  ),
                const SizedBox(height: 50),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
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
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _categorie,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
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
                const SizedBox(height: 15),
                TextFormField(
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
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
                const SizedBox(height: 20), // Espacement avant le choix d'image
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedFiles.isEmpty ? 'Choisir des Images' : '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8), // Espace entre le texte et l'icône
                    IconButton(
                      icon: const Icon(
                        Icons.add_photo_alternate,
                        color: Colors.black,
                      ),
                      onPressed: _pickFiles,
                    ),
                  ],
                ),
                if (_selectedFiles.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedFiles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(
                            _selectedFiles[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF914b14),
                    ),
                    onPressed: _addPost,
                    child: const Text('Publier'),
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
