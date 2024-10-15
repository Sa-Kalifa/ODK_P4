import 'package:flutter/material.dart';
import 'package:dashboard/pages/dashboard_page.dart';
import 'package:dashboard/pages/login.dart';
import 'package:dashboard/pages/messager.dart';
import 'package:dashboard/pages/profile.dart';
import 'package:dashboard/pages/publication.dart';
import 'package:dashboard/pages/signale.dart';
import 'package:dashboard/pages/utilisateur.dart';
import 'package:dashboard/parametre/couleur.dart'; // Assure-toi que cette classe est définie correctement

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  // Liste des pages à afficher dans l'IndexedStack
  final List<Widget> _pages = [
    DashboardPage(),
    Utilisateur(),
    Publication(),
    Signale(),
    Profile(),
    Messager(),
    Login(),
  ];

  // Données des items du menu
  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard, 'title': 'Dashboard'},
    {'icon': Icons.people, 'title': 'Utilisateur'},
    {'icon': Icons.article, 'title': 'Publication'},
    {'icon': Icons.warning, 'title': 'Signale'},
    {'icon': Icons.account_circle, 'title': 'Profile'},
    {'icon': Icons.message, 'title': 'Messager'},
    {'icon': Icons.logout, 'title': 'Se Deconnecter'},
  ];

  void _onMenuItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Menu latéral
          Expanded(
            flex: 1,
            child: Container(
              color: Couleur.nav, // Couleur de fond du menu
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: Image.asset('lib/assets/images/Logo01.png', height: 60),
                    ),
                  ),
                  // Création dynamique des items du menu
                  ..._menuItems.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> menuItem = entry.value;
                    return buildMenuItem(context, menuItem['icon'], menuItem['title'], idx);
                  }).toList(),
                ],
              ),
            ),
          ),
          // Zone de contenu avec IndexedStack
          Expanded(
            flex: 4,
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
    );
  }

  // Construire chaque item du menu
  Widget buildMenuItem(BuildContext context, IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index; // Vérifie si l'item est sélectionné

    return Container(
      //color: isSelected ? const Color(0xFF914b14).withOpacity(0.2) : Colors.transparent, // Couleur de fond si sélectionné
    child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Couleur.pr : Couleur.sec, // Couleur de l'icône
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Couleur.pr : Couleur.blanc, // Couleur du texte
          ),
        ),
        onTap: () {
          _onMenuItemTap(index);
        },
      ),
    );
  }
}
