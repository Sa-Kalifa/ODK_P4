import '../const/constant.dart';
import 'package:flutter/material.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF171821),
      child: ListView.builder(
        itemCount: data.menu.length,
        itemBuilder: (context, index) => buildMenuEntry(data, index),
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(6.0),
        ),
        color: isSelected ? selectionColor : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
          // Navigation vers la route appropriée
          Navigator.pushReplacementNamed(context, data.menu[index].title);
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              child: Icon(
                data.menu[index].icon,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
            Text(
              data.menu[index].title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }

}


// les menus de la bare de navigation

class MenuModel {
  final IconData icon;
  final String route;
  final String title;

  const MenuModel({required this.icon, required this.route, required this.title});
}

// Menu latéral avec navigation
class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final sideMenuData = SideMenuData().menu;

    return Drawer(
      child: ListView.builder(
        itemCount: sideMenuData.length,
        itemBuilder: (context, index) {
          final item = sideMenuData[index];
          return ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            onTap: () {
              _navigateToPage(context, item.route);
            },
          );
        },
      ),
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    switch (route) {
      case 'dashboard':
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 'utilisateur':
        Navigator.pushReplacementNamed(context, '/utilisateur');
        break;
      case 'publication':
        Navigator.pushReplacementNamed(context, '/publication');
        break;
      case 'signale':
        Navigator.pushReplacementNamed(context, '/signale');
        break;
      case 'profile':
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      case 'messager':
        Navigator.pushReplacementNamed(context, '/messager');
        break;
      case 'Se Deconnecter':
      // Implémentez votre logique de déconnexion ici
        Navigator.pushReplacementNamed(context, '/login');
        break;

      default:
        Navigator.pop(context);
    }
  }
}

// Les liens de navigation
class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.home, route: '/dashboard',title: 'Dashboard'),
    MenuModel(icon: Icons.people_alt, route: '/utilisateur',title: 'Utilisateur'),
    MenuModel(icon: Icons.bookmarks_outlined, route: '/publication',title: 'Publication'),
    MenuModel(icon: Icons.notifications_active_outlined, route: '/signale',title: 'Signale'),
    MenuModel(icon: Icons.person, route: '/profile_admin',title: 'Profile'), // Assurez-vous que cela correspond
    MenuModel(icon: Icons.message_outlined, route: '/messager',title: 'Messager'),
    MenuModel(icon: Icons.logout, route: 'Se Deconnecter',title: 'Se Deconnecter'),
  ];
}


