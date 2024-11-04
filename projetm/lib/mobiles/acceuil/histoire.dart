// Assurez-vous que toutes les importations nécessaires sont présentes
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'app_bar.dart'; // Assurez-vous que ce fichier contient le CustomBottomAppBar que vous utilisez

class Histoire extends StatefulWidget {
  const Histoire({super.key});

  @override
  State<Histoire> createState() => _HistoireState();
}

class _HistoireState extends State<Histoire> {
  final _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;

  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  // Controllers pour les champs de texte
  final TextEditingController _titre = TextEditingController();
  final TextEditingController _description = TextEditingController();

  String _categorie = 'Autre'; // Catégorie par défaut
  bool _isAnonymous = false; // État du switch
  bool _isLoading = false;

  List<File> _selectedFiles = []; // Liste des fichiers sélectionnés
  final List<String> _categories = [
    'Immigration',
    'Violence',
    'Racisme',
    'Injustice',
    'Deplace',
    'Autre',
  ]; // Liste des catégories

  // Fonction pour sélectionner les fichiers
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'mp3', 'mp4'],
      allowMultiple: true, // Autoriser plusieurs fichiers
    );
    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
        print('Fichiers sélectionnés : ${_selectedFiles.length}');
      });
    }
  }

  // Fonction pour uploader les fichiers vers Firebase Storage
  Future<String> uploadFile(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final path = 'uploads/$fileName';
      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);

      final snapshot = await uploadTask!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('Fichier uploadé : $urlDownload');
      return urlDownload;
    } catch (e) {
      print('Erreur lors de l\'upload: $e');
      return '';
    }
  }

  // Fonction pour ajouter l'histoire dans la collection "histoires"
  Future<void> _addStory() async {
    if (user == null) {
      print("Utilisateur non authentifié. Veuillez vous connecter.");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<String> uploadedFilesUrls = [];

      // Uploader les fichiers sélectionnés
      for (var file in _selectedFiles) {
        final url = await uploadFile(file);
        if (url.isNotEmpty) {
          uploadedFilesUrls.add(url);
        }
      }

      if (uploadedFilesUrls.isEmpty) {
        print('Aucun fichier n\'a été uploadé.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aucun fichier n\'a été uploadé.')),
        );
      }

      // Ajouter les informations de l'histoire dans Firestore
      await db.collection('histoires').add({
        'titre': _titre.text,
        'categorie': _categorie,
        'description': _description.text,
        'isAnonymous': _isAnonymous,
        'userId': user?.uid ?? 'Utilisateur inconnu',
        'userName': _isAnonymous ? 'Anonyme' : (user?.displayName ?? user?.email ?? 'Nom non disponible'),
        'userPhoto': _isAnonymous ? '' : (user?.photoURL ?? ''),
        'createdAt': Timestamp.now(),
        'mediaUrls': uploadedFilesUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histoire ajoutée avec succès !')),
      );

      _titre.clear();
      _description.clear();
      setState(() {
        _selectedFiles = [];
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'histoire: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fonction pour récupérer les informations de l'utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF914b14),
        title: const Center(
          child: Text(
            'Ajouter une Histoire',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<Map<String, dynamic>?>(
        future: getUserInfo(), // Récupérer les informations de l'utilisateur
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement des données'));
          }
          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!;
            final userPhoto = userData['image_url'] ?? '';
            final userEmail = userData['email'] ?? 'Email non disponible';

            return Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(userPhoto),
                            radius: 20,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            _isAnonymous ? 'Anonyme' : userEmail,
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
                        controller: _titre,
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
                          filled: true,
                          fillColor: Color(0xFFFAF3E0),
                        ),
                        style: const TextStyle(color: Colors.black),
                        dropdownColor: Colors.white,
                        onChanged: (newValue) {
                          setState(() {
                            _categorie = newValue!;
                          });
                        },
                        selectedItemBuilder: (BuildContext context) {
                          return _categories.map((String value) {
                            return Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              color: Colors.white,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _description,
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
                      ),
                      const SizedBox(height: 15),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickFiles, // Utiliser la fonction de sélection de fichiers existante
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF914b14)),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library, // Icône de la galerie
                                color: Color(0xFF914b14),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Sélectionner des ressources', // Texte à côté de l'icône
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF914b14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Afficher les fichiers sélectionnés (sous forme de vignettes ou de texte)
                      _selectedFiles.isNotEmpty
                          ? Column(
                        children: _selectedFiles.map((file) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0E1D1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF914b14)),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // Ajout d'un défilement horizontal pour le nom de fichier
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        file.path.split('/').last, // Nom du fichier
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedFiles.remove(file); // Retirer le fichier de la liste
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                          : Container(), // Ne rien afficher si aucun fichier sélectionné
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _addStory,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF914b14),
                          ),
                          child: const Text('Publier', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('Utilisateur non trouvé'));
          }
        },
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 1),
    );
  }
}
