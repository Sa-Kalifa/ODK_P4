import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetm/mobiles/profile/profile.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Déclaration des TextEditingControllers
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Charger les données de l'utilisateur connecté
  }

  @override
  void dispose() {
    // Dispose des contrôleurs pour éviter les fuites de mémoire
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  // Charger les données de l'utilisateur connecté depuis Firestore
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            _nomController.text = userDoc['nom'] ?? '';
            _emailController.text = userDoc['email'] ?? '';
            _telephoneController.text = userDoc['telephone'] ?? '';
            _isLoading = false; // Données chargées
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aucune donnée trouvée pour cet utilisateur.')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la récupération des données: $e')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: utilisateur non connecté.')),
      );
    }
  }

  // Enregistrer les modifications dans Firestore
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Sauvegarder les valeurs des contrôleurs
      String nomPrenom = _nomController.text.trim();
      String email = _emailController.text.trim();
      String telephone = _telephoneController.text.trim();

      try {
        User? user = FirebaseAuth.instance.currentUser;
        String? userId = user?.uid;

        if (userId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'nom': nomPrenom,
            'email': email,
            'telephone': telephone,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Informations mises à jour avec succès!')),
          );

          // Retourner à la page ProfilePage et rafraîchir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Profile()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: utilisateur non connecté.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF3E0),
      appBar: AppBar(
        title: const Text(
          'Modifier Compte',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicateur de chargement
          : SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Champ Nom et Prénom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom et Prénom',
                  labelStyle: TextStyle(color: Colors.black), // Couleur du label en noir
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(color: Colors.black), // Couleur du texte saisi en noir
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Veuillez entrer votre nom et prénom' : null,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black), // Couleur du label en noir
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(color: Colors.black), // Couleur du texte saisi en noir
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer votre email';
                  }
                  // Validation simple de l'email
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  labelStyle: TextStyle(color: Colors.black), // Couleur du label en noir
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: TextStyle(color: Colors.black), // Couleur du texte saisi en noir
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Veuillez entrer votre numéro de téléphone' : null,
              ),


              SizedBox(height: 32),
              // Bouton Enregistrer
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF914B14), // Couleur du bouton
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
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
