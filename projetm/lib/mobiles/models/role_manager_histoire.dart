import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class RoleManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> _isAdminOrPartnerOrOwner(String postUserId) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      if (currentUser.uid == postUserId) {
        return true;
      }

      final snapshot = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (snapshot.exists) {
        final role = snapshot['role'];
        return role == 'Admin' || role == 'Partenaire';
      }
    }

    return false;
  }

  void _showPostOptions(BuildContext context, String postId, Map<String, dynamic> histoires, String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final bool isOwnerOrPartner = currentUser?.uid == userId || await _isAdminOrPartnerOrOwner(userId);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            if (isOwnerOrPartner)
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFF914b14)),
                title: const Text('Supprimer le post'),
                onTap: () async {
                  bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer le post'),
                      content: const Text('Êtes-vous sûr de vouloir supprimer ce post ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Supprimer', style: TextStyle(color: Color(0xFF914b14))),
                        ),
                      ],
                    ),
                  );

                  if (confirm) {
                    try {
                      // Suppression de l'image si nécessaire (Firebase Storage)
                      if (histoires.containsKey('image_url')) {
                        String imagePath = 'user_images/${histoires['image_url']}';
                        await FirebaseStorage.instance.ref(imagePath).delete();
                      }

                      // Suppression du post dans Firestore avec l'ID du post
                      await FirebaseFirestore.instance.collection('histoires').doc(postId).delete();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post et image supprimés avec succès.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de la suppression : $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.flag, color: Color(0xFF914b14)),
              title: const Text('Signaler le post'),
              onTap: () {
                Navigator.pop(context); // Fermer le menu des options
                showReportDialog(context, postId); // Ouvrir le popup de signalement
              },
            ),
          ],
        );
      },
    );
  }

  void showReportDialog(BuildContext context, String postId) {
    final TextEditingController descriptionController = TextEditingController();
    String? selectedReason; // Variable pour stocker le motif sélectionné

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFAF3E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Center(
            child: Text(
              'Signaler le post',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color(0xFF914b14),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajouté pour éviter les débordements
              crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
              children: [
                const Text(
                  'Pourquoi signalez-vous ce post ?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  value: selectedReason,
                  isExpanded: true, // Permet au Dropdown d'occuper toute la largeur
                  decoration: InputDecoration(
                    labelText: 'Motif',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Color(0xFFF3F0CE), // Couleur de fond
                  ),
                  items: [
                    'Autre',
                    'Publicité non sollicitée',
                    'Désinformation',
                    'Violation des droits d\'auteur',
                    'Usurpation d\'identité',
                    'Escroquerie ou fraude',
                    'Incitation à la haine ou à la violence',
                    'Propos diffamatoires',
                    'Terrorisme ou extrémisme',
                    'Non-respect des règles de la communauté',
                  ].map((String reason) {
                    return DropdownMenuItem<String>(
                      value: reason,
                      child: Text(reason, overflow: TextOverflow.ellipsis), // Gérer le dépassement
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedReason = newValue; // Mise à jour de la variable de motif
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  'Donnez vos raisons !',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF3F0D5), // Couleur de fond
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le popup
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () async {
                // Logique pour enregistrer le signalement dans Firestore
                if (selectedReason != null && descriptionController.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('signales').add({
                    'postId': postId,
                    'reason': selectedReason, // Utilisation du motif sélectionné
                    'description': descriptionController.text,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  // Fermer le popup après enregistrement
                  Navigator.of(context).pop();

                  // Optionnel : Afficher un message de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signalement enregistré avec succès !')),
                  );
                } else {
                  // Afficher un message d'erreur si les champs sont vides
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs.')),
                  );
                }
              },
              child: const Text(
                'Envoyer',
                style: TextStyle(
                  color: Color(0xFF914b14),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showOptions(BuildContext context, String postId, Map<String, dynamic> histoires, String postUserId) {
    _showPostOptions(context, postId, histoires, postUserId);
  }
}
