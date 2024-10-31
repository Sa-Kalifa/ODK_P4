import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../parametre/couleur.dart';

class Signale extends StatefulWidget {
  const Signale({super.key});

  @override
  State<Signale> createState() => _SignaleState();
}

class _SignaleState extends State<Signale> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des publications signalées',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Couleur.pr,
        leading: const SizedBox.shrink(), // Retire l'icône de retour
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('signales').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aucune publication signalée trouvée.', style: TextStyle(fontSize: 18)),
            );
          }

          var signales = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Affiche deux cartes par ligne
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.6,
            ),
            itemCount: signales.length,
            itemBuilder: (context, index) {
              var signalementData = signales[index].data() as Map<String, dynamic>;
              var postId = signalementData['postId'];
              var reason = signalementData['reason'];
              var description = signalementData['description'];
              var timestamp = (signalementData['timestamp'] as Timestamp).toDate();
              var formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('histoires').doc(postId).get(),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                    return const SizedBox.shrink(); // Masquer si le post n'existe pas
                  }

                  var postData = postSnapshot.data!.data() as Map<String, dynamic>;
                  var userName = postData['userName'] ?? 'Utilisateur inconnu';
                  var userPhoto = postData['userPhoto'] ?? 'assets/default_user.png';
                  var title = postData['titre'] ?? 'Titre inconnu';
                  var storyDescription = postData['description'] ?? '';
                  var mediaUrls = List<String>.from(postData['mediaUrls'] ?? []);

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
                                backgroundImage: NetworkImage(userPhoto),
                                radius: 25,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
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
                                  reason,
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
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Couleur.pr,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Description de la publication : $storyDescription',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Description du signalement : $description',
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(
                          height: 150, // Ajuster pour une meilleure présentation
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: mediaUrls.length,
                            itemBuilder: (context, mediaIndex) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    mediaUrls[mediaIndex],
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteStory(postId);
                                },
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
          );
        },
      ),
    );
  }

  // Fonction pour supprimer une publication signalée
  void _deleteStory(String storyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmer la suppression"),
          content: const Text("Êtes-vous sûr de vouloir supprimer cette publication signalée ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Supprimer"),
              onPressed: () {
                FirebaseFirestore.instance.collection('histoires').doc(storyId).delete().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Publication supprimée avec succès')));
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la suppression : $error')));
                });
              },
            ),
          ],
        );
      },
    );
  }
}
