import 'package:flutter/material.dart';

class MenuModel {
  final IconData icon;
  final String title;

  const MenuModel({required this.icon, required this.title});
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
              _navigateToPage(context, item.title);
            },
          );
        },
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title) {
    // Utilisation de Navigator.pushNamed pour les routes nommées
    switch (title) {
      case 'Dashboard':
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 'Utilisateur':
        Navigator.pushNamed(context, '/utilisateur');
        break;
      case 'Publication':
        Navigator.pushNamed(context, '/publication');
        break;
      case 'Signale':
        Navigator.pushNamed(context, '/signale');
        break;
      case 'Profile':
        Navigator.pushNamed(context, '/profile');
        break;
      case 'Messager':
        Navigator.pushNamed(context, '/messager');
        break;
      case 'Se Deconnecter':
      // Logique de déconnexion
        Navigator.popUntil(context, (route) => route.isFirst); // Retour à la page principale ou connexion
        break;
      default:
        Navigator.pop(context); // Retourner si aucune route n'est trouvée
    }
  }
}

// Les liens de navigation
class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.home, title: 'Dashboard'),
    MenuModel(icon: Icons.people_alt, title: 'Utilisateur'),
    MenuModel(icon: Icons.bookmarks_outlined, title: 'Publication'),
    MenuModel(icon: Icons.notifications_active_outlined, title: 'Signale'),
    MenuModel(icon: Icons.person, title: 'Profile'),
    MenuModel(icon: Icons.message_outlined, title: 'Messager'),
    MenuModel(icon: Icons.logout, title: 'Se Deconnecter'),
  ];
}
