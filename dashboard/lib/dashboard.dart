import 'package:dashboard/pages/dashboard_page.dart';
import 'package:dashboard/pages/login.dart';
import 'package:dashboard/pages/messager.dart';
import 'package:dashboard/pages/profile.dart';
import 'package:dashboard/pages/publication.dart';
import 'package:dashboard/pages/signale.dart';
import 'package:dashboard/pages/utilisateur.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  // List of pages to show in IndexedStack
  final List<Widget> _pages = [
    DashboardPage(),
    Utilisateur(),
    Publication(),
    Signale(),
    Profile(),
    Messager(),
    Login(),
  ];

  // Menu items data
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
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: ,
      ),
      body: Row(
        children: [
          // Sidebar Menu
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    height: 100,
                    child: Center(
                      child: FlutterLogo(size: 60),
                    ),
                  ),
                  // Dynamically create menu items
                  ..._menuItems.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, dynamic> menuItem = entry.value;
                    return buildMenuItem(context, menuItem['icon'], menuItem['title'], idx);
                  }).toList(),
                ],
              ),
            ),
          ),
          // Content area with IndexedStack
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

  // Build each Menu Item
  Widget buildMenuItem(BuildContext context, IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        _onMenuItemTap(index);
      },
    );
  }
}
