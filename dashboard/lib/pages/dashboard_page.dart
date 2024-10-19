import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _searchController = TextEditingController();

  // Méthode pour récupérer les données pour les cartes
  Future<int> _getCount(String collection) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(collection).get();
    return snapshot.size;
  }

  // Récupérer les informations de l'utilisateur actuel
  Future<Map<String, dynamic>?> getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc.data();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F7FC),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de recherche + notification + profil
              _buildAppBar(context),
              const SizedBox(height: 30),

              // Section des 4 cartes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCard('Utilisateurs', 'users', Colors.blue),
                  _buildCard('Histoires', 'histoires', Colors.green),
                  _buildCard('Membres', 'users', Colors.orange, roleFilter: 'Membre'),
                  _buildCard('Signalements', 'signalements', Colors.red),
                ],
              ),
              const SizedBox(height: 40),

              // Diagramme d'évolution des interactions
              Text(
                'Évolution des interactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              _buildChartContainer(), // Le graphique défilable

              const SizedBox(height: 30),

              // Liste des admins
              Text(
                'Liste des administrateurs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 10),
              _buildAdminList(),
            ],
          ),
        ),
      ),
    );
  }

  // AppBar personnalisée avec barre de recherche, notification et profil
  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.grey[600], size: 28),
              onPressed: () {},
            ),
            const SizedBox(width: 10),
            FutureBuilder<Map<String, dynamic>?>(
              future: getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userData = snapshot.data!;
                  final userPhoto = userData['image_url'] ?? '';
                  final userEmail = userData['email'] ?? 'Email non disponible';
                  final userName = userData['nom'] ?? 'Nom non disponible';
                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userPhoto),
                        radius: 25,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(userEmail, style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // Fonction pour créer les cartes avec un design moderne
  Widget _buildCard(String title, String collection, Color color, {String? roleFilter}) {
    return FutureBuilder<int>(
      future: roleFilter == null
          ? _getCount(collection)
          : _getCountByRole(collection, roleFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Container(
            width: 170,
            height: 140,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  snapshot.data.toString(),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fonction pour récupérer les utilisateurs en fonction de leur rôle
  Future<int> _getCountByRole(String collection, String role) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('role', isEqualTo: role)
        .get();
    return snapshot.size;
  }

  // Container pour le graphique avec un design plus moderne
  Widget _buildChartContainer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 1000, // Taille ajustée pour le scroll horizontal
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SizedBox(
          height: 250,
          child: _buildScrollableChart(),
        ),
      ),
    );
  }

  // Utilisation de fl_chart pour afficher un graphique à barres
  Widget _buildScrollableChart() {
    return BarChart(
      BarChartData(
        barGroups: List.generate(12, (index) {
          // Générer un groupe de barres pour chaque mois
          return _buildBarGroup(index, (index + 1) * 10.0); // Données fictives, à ajuster avec vos données réelles
        }),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const style = TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                switch (value.toInt()) {
                  case 0:
                    return Text('Jan', style: style);
                  case 1:
                    return Text('Fév', style: style);
                  case 2:
                    return Text('Mar', style: style);
                  case 3:
                    return Text('Avr', style: style);
                  case 4:
                    return Text('Mai', style: style);
                  case 5:
                    return Text('Juin', style: style);
                  case 6:
                    return Text('Juil', style: style);
                  case 7:
                    return Text('Août', style: style);
                  case 8:
                    return Text('Sept', style: style);
                  case 9:
                    return Text('Oct', style: style);
                  case 10:
                    return Text('Nov', style: style);
                  case 11:
                    return Text('Déc', style: style);
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
      ),
    );
  }

  // Fonction pour construire chaque groupe de barres
  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 15,
          borderRadius: BorderRadius.circular(5),
          color: Colors.blueAccent,
        ),
      ],
    );
  }

  // Liste des administrateurs avec des avatars
  Widget _buildAdminList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'Admin').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final docs = snapshot.data!.docs;
        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(data['image_url'] ?? 'default_user_image_url'),
                radius: 25,
              ),
              title: Text(data['nom'] ?? 'Nom Inconnu', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(data['email'] ?? 'Email non disponible'),
            );
          }).toList(),
        );
      },
    );
  }
}
