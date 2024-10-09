import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostDetailPage extends StatelessWidget {
  final Map<String, dynamic> post;
  final TextEditingController _commentController = TextEditingController();

  PostDetailPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String description = post['description'] ?? 'Description indisponible';
    final List<dynamic> mediaUrls = post['mediaUrls'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: const Color(0xFF914b14),
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
                    if (mediaUrls.isNotEmpty) ...[
                      Image.network(mediaUrls[0]), // Affiche la première image du post
                      const SizedBox(height: 10),
                    ],
                    Text(description, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    // Section des commentaires
                    const Text('Commentaires:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('histoires')
                          .doc(post['id'])
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
                            final String commenterName = comment['userName'] ?? 'Utilisateur inconnu';
                            final String commentText = comment['comment'] ?? '';

                            return ListTile(
                              title: Text(commenterName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(commentText),
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
                      final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'inconnu';
                      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                      final String userName = userDoc['nom'] ?? 'Nom non disponible';

                      await FirebaseFirestore.instance.collection('histoires').doc(post['id']).collection('commentaires').add({
                        'userId': userId,
                        'userName': userName,
                        'comment': commentText,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      _commentController.clear(); // Efface le champ de texte après l'envoi
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
