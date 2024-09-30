import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomAppBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomAppBar({required this.currentIndex});

  @override
  _CustomBottomAppBarState createState() => _CustomBottomAppBarState();
}

class _CustomBottomAppBarState extends State<CustomBottomAppBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: _selectedIndex, // Définir l'index sélectionné au départ
      color: Color(0xFF1E212D), // Couleur de la barre
      backgroundColor: Colors.transparent, // Arrière-plan transparent
      buttonBackgroundColor: Color(0xFF914b14), // Couleur du bouton sélectionné
      animationDuration: Duration(milliseconds: 300), // Animation plus fluide
      items: <Widget>[
        Icon(Icons.home, size: 30, color: _selectedIndex == 0 ? Color(0xFFFAF3E0) : Colors.white),
        Icon(Icons.add_circle_sharp, size: 30, color: _selectedIndex == 1 ? Color(0xFFFAF3E0) : Colors.white),
        Icon(Icons.notifications, size: 30, color: _selectedIndex == 2 ? Color(0xFFFAF3E0) : Colors.white),
        Icon(Icons.person, size: 30, color: _selectedIndex == 3 ? Color(0xFFFAF3E0) : Colors.white),
      ],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });

        // Naviguer vers la page appropriée selon l'index
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/accueil');
            break;
          case 1:
            Navigator.pushNamed(context, '/histoire');
            break;
          case 2:
            Navigator.pushNamed(context, '/notification');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}
