import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projetm/mobiles/acceuil/app_bar.dart';
import 'package:projetm/mobiles/acceuil/detail_page.dart';
import '../models/role_manager_histoire.dart';

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _searchController = TextEditingController();

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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {}); // Actualise la liste filtrée
                        },
                      ),
                    ),
                  ),
              ),
              const SizedBox(height: 10),
              _buildPartenaireCards(),
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
                  final postId = posts[index].id;  // Récupération de l'ID de l'histoire
                  return _buildPostCard(post, postId);  // Passez l'ID de l'histoire au widget
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

  Future<bool> _hasUserLiked(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final likeDoc = await FirebaseFirestore.instance
        .collection('histoires')
        .doc(postId)
        .collection('likes')
        .doc(user.uid)
        .get();

    return likeDoc.exists;
  }

  Widget _buildPostCard(Map<String, dynamic> post, String postId) {
    final bool isAnonymous = post['isAnonymous'] ?? false;
    final String userId = post['userId'] ?? 'Utilisateur inconnu';
    final String category = post['categorie'] ?? 'Sans catégorie';
    final String description = post['description'] ?? 'Description indisponible';
    final String titre = post['titre'] ?? 'Titre non disponible';
    final DateTime? createdAt = (post['createdAt'] as Timestamp?)?.toDate();
    final List<dynamic> mediaUrls = post['mediaUrls'] ?? [];
    int likes = post['likes'] ?? 0;
    final int shares = post['shares'] ?? 0;
    final user = _auth.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userDoc = snapshot.data!;
        final String userName = isAnonymous ? 'Anonyme' : (userDoc['nom'] ?? 'Nom non disponible');
        final String userImageUrl = userDoc['image_url'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostDetailPage(postId: postId),
              ),
            ),
            child: Padding(
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
                                : const AssetImage('assets/default_user.png') as ImageProvider,
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
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onPressed: () {
                              RoleManager().showOptions(context, postId, post, userId);
                            },
                          ),
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
                      FutureBuilder<bool>(
                        future: _hasUserLiked(postId),
                        builder: (context, snapshot) {
                          bool isLiked = snapshot.data ?? false;

                          return TextButton.icon(
                            onPressed: () async {
                              if (user != null) {
                                final likeRef = FirebaseFirestore.instance
                                    .collection('histoires')
                                    .doc(postId)
                                    .collection('likes')
                                    .doc(user.uid);

                                setState(() {
                                  isLiked = !isLiked;
                                  likes = isLiked ? likes + 1 : likes - 1;
                                });

                                if (isLiked) {
                                  await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
                                } else {
                                  await likeRef.delete();
                                }

                                FirebaseFirestore.instance
                                    .collection('histoires')
                                    .doc(postId)
                                    .update({'likes': likes});
                              }
                            },
                            icon: Icon(
                              Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.black,
                            ),
                            label: Text(
                              '$likes',
                              style: TextStyle(color: isLiked ? Colors.red : Colors.black),
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(postId: postId),
                            ),
                          );
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

  Widget _buildPartenaireCards() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('histoires').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final histoires = snapshot.data!.docs;
        final random = Random();

        // Mélange les histoires pour afficher les images aléatoirement
        histoires.shuffle(random);

        return CarouselSlider.builder(
          itemCount: histoires.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final histoire = histoires[index].data() as Map<String, dynamic>;
            final String imageUrl = histoire['mediaUrls'].isNotEmpty ? histoire['mediaUrls'][0] : '';
            final String titre = histoire['titre'] ?? 'Titre non disponible';

            return _buildSingleHistoireCard(imageUrl, titre);
          },
          options: CarouselOptions(
            height: 180, // Hauteur du carousel
            enlargeCenterPage: true, // Met en valeur la carte centrale
            autoPlay: true, // Lecture automatique
            autoPlayInterval: const Duration(seconds: 3), // Intervalle de lecture automatique
            autoPlayAnimationDuration: const Duration(milliseconds: 800), // Durée de l'animation
            aspectRatio: 16/9, // Ratio d'aspect
            viewportFraction: 0.8, // Proportion d'affichage
          ),
        );
      },
    );
  }

  Widget _buildSingleHistoireCard(String imageUrl, String titre) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                titre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

