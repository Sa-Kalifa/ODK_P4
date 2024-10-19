import 'package:dashboard/parametre/couleur.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'histoire.dart'; // Assurez-vous que le fichier contenant la classe Histoire est bien importé

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
        title: const Text('Gestion des publications', style: TextStyle(color: Colors.white)),
        backgroundColor: Couleur.pr,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getStories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune histoire trouvée.', style: TextStyle(fontSize: 18)));
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
              crossAxisCount: 3, // Afficher trois éléments par ligne
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.6, // Ajuste la taille des cards
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              var date = (stories[index]['createdAt'] as Timestamp).toDate();
              var formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              stories[index]['userPhoto'] ?? 'default_user_image_url',
                            ),
                            radius: 25,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stories[index]['userName'] ?? 'Nom Inconnu',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(formattedDate,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: const BoxDecoration(
                              color: Couleur.bg,
                            ),
                            child: Text(
                              stories[index]['categorie'],
                              style: const TextStyle(
                                color: Couleur.pr,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        stories[index]['titre'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Couleur.pr,
                        ),
                      ),
                    ),
                    // Modification ici pour rendre la description scrollable
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 100, // Hauteur de défilement ajustable
                        child: SingleChildScrollView(
                          child: Text(
                            stories[index]['description'],
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 250, // Ajusté pour un meilleur affichage
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: stories[index]['mediaUrls'].length,
                        itemBuilder: (context, mediaIndex) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                stories[index]['mediaUrls'][mediaIndex],
                                width: 300, // Largeur d'image ajustée
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Ajout des boutons de commentaire, modification et suppression
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.comment, color: Couleur.pr),
                            label: const Text("Commentaires", style: TextStyle(color: Couleur.noire)),
                            onPressed: () {
                              _showCommentsDialog(stories[index]['id']);
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Couleur.pr),
                                onPressed: () {
                                  _showEditDialog(stories[index]);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteStory(stories[index]['id']);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPublishDialog, // Afficher la popup Histoire au clic
        child: const Icon(Icons.add),
        backgroundColor: Couleur.pr,
      ),
    );
  }

  // Méthode pour afficher la popup de la classe Histoire
  void _showPublishDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4, // Ajuste la largeur du popup
            height: MediaQuery.of(context).size.height * 0.8, // Ajuste la hauteur du popup
            child: const Histoire(), // Contenu du popup : la classe Histoire
          ),
        );
      },
    );
  }

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

  // Méthode pour supprimer une histoire avec confirmation
  void _deleteStory(String storyId) {
    // Afficher un dialogue de confirmation avant la suppression
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text("Êtes-vous sûr de vouloir supprimer cette histoire ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () {
                // Si l'utilisateur confirme, procéder à la suppression
                FirebaseFirestore.instance.collection('histoires').doc(storyId).delete().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Histoire supprimée avec succès')));
                  Navigator.of(context).pop(); // Fermer le dialogue
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression : $error')));
                });
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher le dialogue de modification
  void _showEditDialog(Map<String, dynamic> story) {
    final titleController = TextEditingController(text: story['titre']);
    final descriptionController = TextEditingController(text: story['description']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modifier l'histoire"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Sauvegarder"),
              onPressed: () {
                _updateStory(story['id'], titleController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour mettre à jour l'histoire dans Firestore
  void _updateStory(String storyId, String title, String description) {
    // Récupérer l'histoire actuelle pour conserver l'image
    FirebaseFirestore.instance.collection('histoires').doc(storyId).get().then((doc) {
      if (doc.exists) {
        // Récupérer les données actuelles de l'histoire
        Map<String, dynamic> currentData = doc.data() as Map<String, dynamic>;

        // Mettre à jour uniquement le titre et la description
        FirebaseFirestore.instance.collection('histoires').doc(storyId).update({
          'titre': title,
          'description': description,
          // Conserver l'image actuelle
          'mediaUrls': currentData['mediaUrls'],
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Histoire mise à jour avec succès')));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la mise à jour : $error')));
        });
      }
    });
  }

  void _showCommentsDialog(String storyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Commentaires"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.40,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('histoires')
                  .doc(storyId)
                  .collection('commentaires')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final comments = snapshot.data!.docs;
                if (comments.isEmpty) {
                  return const Text('Aucun commentaire à afficher.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index].data() as Map<String, dynamic>;
                    final String commenterName = comment['userName'] ?? 'Utilisateur inconnu';
                    final String commentText = comment['comment'] ?? '';
                    final Timestamp? commentTimestamp = comment['createdAt'] as Timestamp?;
                    final DateTime? commentDate = commentTimestamp?.toDate();
                    final String commentDateTime = commentDate != null
                        ? DateFormat('dd/MM/yyyy à HH:mm').format(commentDate)
                        : 'Date inconnue';

                    // Récupérer l'image de l'utilisateur qui a commenté
                    final String commenterId = comment['userId'] ?? '';
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(commenterId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final userDoc = userSnapshot.data!;
                        if (!userDoc.exists) {
                          return _buildCommentCard(commenterName, commentText, commentDateTime);
                        }

                        final String userImageUrl = userDoc['image_url'] ?? 'assets/default_user.png';
                        return _buildCommentCard(commenterName, commentText, commentDateTime, userImageUrl);
                      },
                    );
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentCard(String name, String comment, String date, [String? imageUrl]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : const AssetImage('assets/default_user.png') as ImageProvider,
            radius: 20,
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      comment,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        date,
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
  }
}
