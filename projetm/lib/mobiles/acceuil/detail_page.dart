import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/role_manager_histoire.dart';

class PostDetailPage extends StatelessWidget {
  final String postId; // Utilisation de l'ID du post au lieu de DocumentSnapshot
  final TextEditingController _commentController = TextEditingController();

  PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('histoires').doc(postId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final post = snapshot.data!;
        final bool isAnonymous = post['isAnonymous'] ?? false;
        final String userId = post['userId'] ?? 'Utilisateur inconnu';
        final String category = post['categorie'] ?? 'Sans catégorie';
        final String description = post['description'] ?? 'Description indisponible';
        final String titre = post['titre'] ?? 'Titre non disponible';
        final DateTime? createdAt = (post['createdAt'] as Timestamp?)?.toDate();
        final List<dynamic> mediaUrls = post['mediaUrls'] ?? [];

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final userDoc = snapshot.data!;
            final String userName = isAnonymous ? 'Anonyme' : (userDoc['nom'] ?? 'Nom non disponible');
            final String userImageUrl = userDoc['image_url'] ?? '';

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Détails du post',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF914b14),
                iconTheme: const IconThemeData(color: Colors.white), // Change la couleur du back button en blanc
              ),

              body: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: userImageUrl.isNotEmpty
                                          ? NetworkImage(userImageUrl)
                                          : const AssetImage('assets/default_user.png') as ImageProvider,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(userName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(
                                          createdAt != null
                                              ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                                              : 'Date non disponible',
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(category,
                                        style: const TextStyle(
                                            color: Color(0xFF914b14),
                                            fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                                      onPressed: () {
                                        RoleManager().showOptions(context, postId, post as Map<String, dynamic>, userId);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (mediaUrls.isNotEmpty) ...[
                              _buildImages(mediaUrls),
                            ],
                            const SizedBox(height: 10),
                            Text(titre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(description, style: const TextStyle(fontSize: 18)),
                            const SizedBox(height: 20),
                            const Text('Commentaires:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('histoires')
                                  .doc(postId)
                                  .collection('commentaires')
                                  .orderBy('createdAt', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                final comments = snapshot.data!.docs;
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = comments[index].data() as Map<String, dynamic>;
                                    final String commenterName =
                                        comment['userName'] ?? 'Utilisateur inconnu';
                                    final String commentText = comment['comment'] ?? '';
                                    final Timestamp? commentTimestamp = comment['createdAt'] as Timestamp?;
                                    final DateTime? commentDate = commentTimestamp?.toDate();
                                    final String commentDateTime = commentDate != null
                                        ? '${commentDate.day}/${commentDate.month}/${commentDate.year} à ${commentDate.hour}:${commentDate.minute}'
                                        : 'Date inconnue';

                                    final String commenterId = comment['userId'] ?? '';

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance.collection('users').doc(commenterId).get(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Center(child: CircularProgressIndicator());
                                        }

                                        final userDoc = snapshot.data!;
                                        final String userImageUrl = userDoc['image_url'] ?? '';

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start, // Alignement vertical en haut
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: userImageUrl.isNotEmpty
                                                    ? NetworkImage(userImageUrl)
                                                    : const AssetImage('assets/default_user.png') as ImageProvider,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  color: const Color(0xFF914b14), // Couleur de la carte
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              commenterName,
                                                              style: const TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                                fontSize: 17,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5),
                                                        Text(
                                                          commentText,
                                                          style: const TextStyle(color: Colors.white),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Align(
                                                          alignment: Alignment.bottomRight,
                                                          child: Text(
                                                            commentDateTime,
                                                            style: const TextStyle(
                                                              color: Colors.white70,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Champ pour ajouter un commentaire
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Ajouter un commentaire...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Color(0xFF914b14)),
                          onPressed: () async {
                            final String commentText = _commentController.text;
                            if (commentText.isNotEmpty) {
                              final String currentUserId =
                                  FirebaseAuth.instance.currentUser?.uid ?? 'inconnu';
                              final DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUserId)
                                  .get();
                              final String userName = userDoc['nom'] ?? 'Nom non disponible';

                              await FirebaseFirestore.instance
                                  .collection('histoires')
                                  .doc(postId)
                                  .collection('commentaires')
                                  .add({
                                'userId': currentUserId,
                                'userName': userName,
                                'comment': commentText,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              _commentController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  // Alignement de la date et de l'heure en bas à droite
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        createdAt != null
                            ? '${createdAt.day}/${createdAt.month}/${createdAt.year} à ${createdAt.hour}:${createdAt.minute}'
                            : 'Date non disponible',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildImages(List<dynamic> mediaUrls) {
    if (mediaUrls.isNotEmpty) {
      return Column(
        children: mediaUrls.map<Widget>((url) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              height: 320,
              width: double.infinity,
            ),
          );
        }).toList(),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
