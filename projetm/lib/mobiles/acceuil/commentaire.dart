import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetm/mobiles/acceuil/app_bar.dart';
import 'package:projetm/mobiles/acceuil/detail_page.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: Image.asset('lib/assets/images/Logo01.png', height: 50),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFF914b14)),
            onPressed: () {
              // Actions pour les notifications
            },
          ),
        ],
        leading: const SizedBox.shrink(), // Retire l'icône de retour
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPartenaireCards(),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Color(0xFF914b14)),
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('histoires')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;
                      return _buildPostCard(post);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 0),
    );
  }

  Widget _buildPartenaireCards() {
    return Container(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSinglePartenaireCard('Partenaire 1'),
          _buildSinglePartenaireCard('Partenaire 2'),
          _buildSinglePartenaireCard('Partenaire 3'),
        ],
      ),
    );
  }

  Widget _buildSinglePartenaireCard(String title) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF914b14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
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
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(post: post),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    // Affichage de la première image et du nombre restant
                    _buildImage(mediaUrls),

                    // Icone de like positionné au-dessus de l'image
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite, color: likes > 0 ? Colors.red : Colors.white, size: 30),
                            onPressed: () {
                              setState(() {
                                post['likes'] = likes + 1;
                                FirebaseFirestore.instance.collection('histoires').doc(post['id']).update({'likes': likes + 1});
                              });
                            },
                          ),
                          Text('$likes', style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onPressed: () => _showPostOptions(post, userId),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(titre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      _buildDescription(description),
                    ],
                  ),
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

  void _showPostOptions(Map<String, dynamic> post, String userId) {
    final currentUser = _auth.currentUser;
    final bool isOwnerOrPartner = currentUser?.uid == userId || _isPartner();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            if (isOwnerOrPartner)
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF914b14)),
                title: const Text('Modifier le post'),
                onTap: () {
                  // Logique pour modifier le post
                },
              ),
            if (isOwnerOrPartner)
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFF914b14)),
                title: const Text('Supprimer le post'),
                onTap: () {
                  FirebaseFirestore.instance.collection('histoires').doc(post['id']).delete();
                  Navigator.pop(context);
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

  bool _isPartner() {
    // Logique pour vérifier si l'utilisateur actuel est un partenaire
    return false; // Mettre à jour en fonction de la logique de votre application
  }

  Widget _buildDescription(String description) {
    const int maxChars = 100;
    if (description.length <= maxChars) {
      return Text(description);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${description.substring(0, maxChars)}...'),
          TextButton(
            onPressed: () {
              // Logique pour afficher la description complète
            },
            child: const Text(
              'Voir plus',
              style: TextStyle(color: Color(0xFF914b14), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }
  }
}
