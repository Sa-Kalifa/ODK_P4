import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Publication extends StatefulWidget {
  const Publication({super.key});

  @override
  State<Publication> createState() => _PublicationState();
}

class _PublicationState extends State<Publication> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des publications'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une histoire...',
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
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune histoire trouvée.'));
          }

          List<Map<String, dynamic>> stories = snapshot.data!;

          // Filtrer les histoires avec la recherche
          if (_searchController.text.isNotEmpty) {
            stories = stories.where((story) {
              return story['titre']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
            }).toList();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Ajuste la taille des cards
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              var date = (stories[index]['createdAt'] as Timestamp).toDate();
              var formattedDate =
              DateFormat('dd/MM/yyyy HH:mm').format(date); // Format de la date

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations sur l'utilisateur et la catégorie
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              stories[index]['userPhoto'] ??
                                  'default_user_image_url',
                            ),
                            radius: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stories[index]['userName'] ?? 'Nom Inconnu',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(formattedDate), // Date de publication
                              ],
                            ),
                          ),
                          // Catégorie à droite
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF914b14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stories[index]['categorie'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Titre de l'histoire
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        stories[index]['titre'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Description de l'histoire
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(stories[index]['description']),
                    ),
                    // Image défilable horizontalement
                    SizedBox(
                      height: 300, // Hauteur des images
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: stories[index]['mediaUrls'].length,
                        itemBuilder: (context, mediaIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              stories[index]['mediaUrls'][mediaIndex],
                              width: 300,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),
                    ),

                    // Section pour les icônes Modifier et Supprimer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditStoryDialog(stories[index]);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteStory(stories[index]['id']);
                          },
                        ),
                      ],
                    ),

                    // Section des commentaires
                    const Divider(), // Ligne séparatrice
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Commentaires:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _getComments(stories[index]['id']),
                      builder: (context, commentSnapshot) {
                        if (commentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!commentSnapshot.hasData ||
                            commentSnapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Aucun commentaire.'),
                          );
                        }

                        List<Map<String, dynamic>> comments =
                        commentSnapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, commentIndex) {
                            return ListTile(
                              title: Text(comments[commentIndex]['content']),
                              subtitle: Text(comments[commentIndex]
                              ['userName'] ??
                                  'Utilisateur Anonyme'),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fonction pour récupérer les histoires depuis Firestore
  Stream<List<Map<String, dynamic>>> _getStories() {
    return FirebaseFirestore.instance.collection('histoires').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Ajoute l'ID pour pouvoir le manipuler
          return data;
        }).toList();
      },
    );
  }

  // Fonction pour récupérer les commentaires d'une histoire
  Stream<List<Map<String, dynamic>>> _getComments(String storyId) {
    return FirebaseFirestore.instance
        .collection('commentaires')
        .where('storyId', isEqualTo: storyId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Ajoute l'ID pour pouvoir le manipuler
        return data;
      }).toList();
    });
  }

  // Pop-up pour modifier une histoire
  void _showEditStoryDialog(Map<String, dynamic> story) {
    // ... logique pour modifier l'histoire
  }

  // Fonction pour supprimer une histoire
  Future<void> _deleteStory(String storyId) async {
    try {
      await FirebaseFirestore.instance.collection('histoires').doc(storyId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histoire supprimée avec succès.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression de l\'histoire : $e')),
      );
    }
  }
}
