import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/parametre/couleur.dart';
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
      backgroundColor: Couleur.bg,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de recherche + notification + profil
              _buildAppBar(context),
              const SizedBox(height: 30),
              // Section des 4 cartes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCard('Utilisateurs', 'users', Couleur.pr, const Icon(Icons.people_sharp, color: Colors.white, size: 40),),
                  _buildCard('Membres', 'users', Couleur.nav, roleFilter: 'Membre', const Icon(Icons.person_outline_outlined, color: Colors.white, size: 40),),
                  _buildCard('Histoires', 'histoires', Couleur.sec, const Icon(Icons.notifications, color: Colors.white, size: 40),),
                  _buildCard('Signalements', 'signalements', Couleur.rouge, const Icon(Icons.error, color: Colors.white, size: 40),),
                ],
              ),
              const SizedBox(height: 40),

              // Diagramme d'évolution des interactions
              const Text(
                'Évolution des interactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              _buildChartContainer(), // Le graphique défilable

              const SizedBox(height: 30),

              // Liste des admins
              const Text(
                'Liste des administrateurs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
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
          width: 600,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
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
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Couleur.pr)),
                          Text(userEmail, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // Fonction pour créer les cartes avec un design moderne
  Widget _buildCard(String title, String collection, Color color, Icon icon, {String? roleFilter}) {
    return FutureBuilder<int>(
      future: roleFilter == null
          ? _getCount(collection)
          : _getCountByRole(collection, roleFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Container(
            width: 170,
            height: 150,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: icon, // Affiche l'icône choisie par l'utilisateur
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.data?.toString() ?? '0',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

  // Fonction pour récupérer les statistiques mensuelles
  Future<Map<int, int>> _getMonthlyStatistics(String collection) async {
    Map<int, int> monthlyCounts = {};

    for (int month = 1; month <= 12; month++) {
      DateTime startDate = DateTime(DateTime.now().year, month, 1);
      DateTime endDate = DateTime(DateTime.now().year, month + 1, 1).subtract(Duration(seconds: 1));

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .get();

      monthlyCounts[month - 1] = querySnapshot.docs.length;
    }

    return monthlyCounts;
  }

  // Container pour le graphique avec un design plus moderne
  Widget _buildChartContainer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: 1000,
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
    return FutureBuilder<Map<int, int>>(
      future: Future.wait([
        _getMonthlyStatistics('users'), // Récupère les inscriptions
        _getMonthlyStatistics('stories'), // Récupère les publications d'histoires
      ]).then((results) {
        Map<int, int> monthlyCounts = {};
        for (int month = 0; month < 12; month++) {
          monthlyCounts[month] = results[0][month]! + results[1][month]!;
        }
        return monthlyCounts;
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Aucune donnée trouvée.'));
        }

        return BarChart(
          BarChartData(
            barGroups: List.generate(12, (index) {
              return _buildBarGroup(index, snapshot.data![index]!.toDouble());
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
                      case 0: return Text('Jan', style: style);
                      case 1: return Text('Fév', style: style);
                      case 2: return Text('Mar', style: style);
                      case 3: return Text('Avr', style: style);
                      case 4: return Text('Mai', style: style);
                      case 5: return Text('Juin', style: style);
                      case 6: return Text('Juil', style: style);
                      case 7: return Text('Août', style: style);
                      case 8: return Text('Sept', style: style);
                      case 9: return Text('Oct', style: style);
                      case 10: return Text('Nov', style: style);
                      case 11: return Text('Déc', style: style);
                    }
                    return Container();
                  },
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: false),
          ),
        );
      },
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
          color: Couleur.pr,
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
          return const CircularProgressIndicator();
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
              title: Text(data['nom'] ?? 'Nom Inconnu', style: const TextStyle(fontWeight: FontWeight.bold, color: Couleur.pr)),
              subtitle: Text(data['email'] ?? 'Email non disponible'),
            );
          }).toList(),
        );
      },
    );
  }
}
