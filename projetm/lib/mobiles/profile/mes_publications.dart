import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MesPublications extends StatefulWidget {
  @override
  _MesPublicationsState createState() => _MesPublicationsState();
}

class _MesPublicationsState extends State<MesPublications> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String selectedCategory = 'Tous'; // Par défaut, afficher toutes les publications

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String userId = user?.uid ?? 'Utilisateur inconnu';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mes Publications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF914b14),
        iconTheme: const IconThemeData(color: Colors.white), // Change la couleur du back button en blanc
      ),

      body: Column(
        children: [
          // Conteneur défilable horizontalement pour les catégories
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                buildCategoryButton('Tous'),
                buildCategoryButton('Immigration'),
                buildCategoryButton('Violence'),
                buildCategoryButton('Racisme'),
                buildCategoryButton('Injustice'),
                buildCategoryButton('Deplace'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: (selectedCategory == 'Tous')
                  ? FirebaseFirestore.instance.collection('histoires')
                  .where('userId', isEqualTo: userId)
                  .snapshots()
                  : FirebaseFirestore.instance.collection('histoires')
                  .where('userId', isEqualTo: userId)
                  .where('categorie', isEqualTo: selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Center(child: Text('Aucune publication trouvée.'));
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final postId = posts[index].id;
                    return _buildPostCard(post, postId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour créer un TextButton pour chaque catégorie
  TextButton buildCategoryButton(String category) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Text(
        category,
        style: TextStyle(
          color: selectedCategory == category ? Color(0xFF914b14) : Colors.black,
          fontWeight: selectedCategory == category ? FontWeight.bold : FontWeight.normal, fontSize: 15,
        ),
      ),
    );
  }

  // Méthode pour construire la carte des publications
  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    final bool isAnonymous = post['isAnonymous'] ?? false;
    final String userId = post['userId'] ?? 'Utilisateur inconnu';
    final String category = post['categorie'] ?? 'Sans catégorie';
    final String description = post['description'] ?? 'Description indisponible';
    final String titre = post['titre'] ?? 'Titre non disponible';
    final DateTime? createdAt = (post['createdAt'] as Timestamp?)?.toDate();
    final List<dynamic> mediaUrls = post['mediaUrls'] ?? [];
    final int likes = post['likes'] ?? 0;
    final int shares = post['shares'] ?? 0;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userDoc = snapshot.data!;
        final String userName = isAnonymous ? 'Anonyme' : (userDoc['nom'] ?? 'Nom non disponible');
        final String userImageUrl = userDoc['image_url'] ?? ''; // Récupération de l'URL de l'image de profil utilisateur

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Affichage des informations de l'utilisateur, de la catégorie, etc.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: userImageUrl.isNotEmpty
                              ? NetworkImage(userImageUrl)
                              : const AssetImage('assets/default_user.png') as ImageProvider, // Affichage de l'image utilisateur ou image par défaut
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        Text(category, style: const TextStyle(color: Color(0xFF914b14), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(titre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildDescription(description),
                const SizedBox(height: 15),
                if (mediaUrls.isNotEmpty) _buildImage(mediaUrls),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Color(0xFF914b14), size: 30),
                          onPressed: () {
                            setState(() {
                              post['likes'] = likes + 1;
                              FirebaseFirestore.instance.collection('histoires').doc(postId).update({'likes': likes + 1});
                            });
                          },
                        ),
                        Text('$likes'),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Action pour les commentaires
                      },
                      icon: const Icon(Icons.comment, color: Color(0xFF914b14)),
                      label: const Text('Commentaire'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          post['shares'] = shares + 1;
                          FirebaseFirestore.instance.collection('histoires').doc(postId).update({'shares': shares + 1});
                        });
                      },
                      icon: const Icon(Icons.share, color: Color(0xFF914b14)),
                      label: Text('$shares'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(List<dynamic> mediaUrls) {
    if (mediaUrls.isNotEmpty) {
      return Stack(
        children: [
          Image.network(
            mediaUrls[0], // Affiche la première image de mediaUrls
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
          ),
          if (mediaUrls.length > 1)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                color: Colors.black.withOpacity(0.6),
                child: Text(
                  '+${mediaUrls.length - 1} images',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDescription(String description) {
    const int maxChars = 100;
    if (description.length <= maxChars) {
      return Text(description);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${description.substring(0, maxChars)}....'),
        ],
      );
    }
  }
}
