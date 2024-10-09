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
        print('Fichiers sélectionnés : ${_selectedFiles.length}'); // Vérifiez le nombre de fichiers sélectionnés
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
      print('Fichier uploadé : $urlDownload'); // Vérifiez l'URL du fichier uploadé
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
    } else {
      print("Utilisateur connecté : ${user?.email}");
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      final List<String> uploadedFilesUrls = [];

      // Uploader les fichiers sélectionnés
      for (var file in _selectedFiles) {
        final url = await uploadFile(file);
        if (url.isNotEmpty) {
          uploadedFilesUrls.add(url);
        }
      }

      // Afficher un message si aucun fichier n'a été uploadé
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
        'mediaUrls': uploadedFilesUrls, // Ajouter les URL des fichiers uploadés
      });

      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histoire ajoutée avec succès !')),
      );

      // Réinitialiser le formulaire après l'ajout
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF3E0),
        title: const Center(
          child: Text(
            'Ajouter une Histoire',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
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
                        _isAnonymous ? 'Anonyme' : (user.displayName ?? user.email ?? 'Nom non disponible'),
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
                    fillColor: Color(0xFFFAF3E0), // Couleur de fond du champ
                  ),
                  style: const TextStyle(color: Colors.black), // Style de texte général
                  dropdownColor: Colors.white, // Couleur de fond du menu déroulant
                  onChanged: (newValue) {
                    setState(() {
                      _categorie = newValue!;
                    });
                  },
                  // This property controls the appearance of the selected item
                  selectedItemBuilder: (BuildContext context) {
                    return _categories.map((String value) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.black, // Assurer que le texte reste noir
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
                        color: Colors.white, // Couleur de fond des éléments du menu
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.black, // Couleur du texte des éléments
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une catégorie';
                    }
                    return null;
                  },
                ),const SizedBox(height: 15),
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
                const SizedBox(height: 20),
                // Remplacez cette partie de votre code par les modifications suivantes :
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    file.path.split('/').last, // Nom du fichier
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
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
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 1),
    );
  }
}