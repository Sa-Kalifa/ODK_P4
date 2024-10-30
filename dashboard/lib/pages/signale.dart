import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signale extends StatefulWidget {
  const Signale({super.key});

  @override
  State<Signale> createState() => _SignaleState();
}

class _SignaleState extends State<Signale> {
  // Liste pour stocker les signalements
  List<Map<String, dynamic>> signalements = [];

  @override
  void initState() {
    super.initState();
    fetchSignalements(); // Récupérer les signalements lors de l'initialisation
  }

  Future<void> fetchSignalements() async {
    // Récupérer les signalements de Firestore
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('signales').get();

    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String postId = data['postId'];
      String userId = data['userId']; // Assurez-vous que le champ userId existe

      // Récupérer les informations de l'utilisateur
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Récupérer les informations de l'histoire
      DocumentSnapshot postDoc = await FirebaseFirestore.instance.collection('histoires').doc(postId).get();
      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;

      // Ajouter les informations du signalement, utilisateur et histoire à la liste
      signalements.add({
        'reason': data['reason'],
        'description': data['description'],
        'timestamp': data['timestamp'],
        'userName': userData['name'], // Assurez-vous que le champ name existe
        'postTitle': postData['title'], // Assurez-vous que le champ title existe
      });
    }

    // Trier les signalements par timestamp (décroissant)
    signalements.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    // Mettre à jour l'état pour afficher les signalements
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des signalements'),
      ),
      body: signalements.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Affiche un indicateur de chargement si la liste est vide
          : ListView.builder(
        itemCount: signalements.length,
        itemBuilder: (context, index) {
          var signalement = signalements[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Signalé par: ${signalement['userName']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Post: ${signalement['postTitle']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Motif: ${signalement['reason']}'),
                  const SizedBox(height: 4),
                  Text('Description: ${signalement['description']}'),
                  const SizedBox(height: 4),
                  Text('Date: ${signalement['timestamp']?.toDate().toString() ?? ''}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
