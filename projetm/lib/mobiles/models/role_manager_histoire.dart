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
                // Logique pour signaler le post
              },
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
