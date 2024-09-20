import 'package:flutter/material.dart';

import '../util/responsive.dart';
import 'add_user.dart';

class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E212D), // Background color: #1E212D
      appBar: AppBar(
        backgroundColor: Color(0xFF914b14), // Button color: #914b14
        title: const Text("Liste des Utilisateurs"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Afficher le formulaire d'ajout d'utilisateur
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddUserDialog();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              onChanged: (value) {
                // Logique pour filtrer les utilisateurs
              },
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (Responsive.isMobile(context)) {
                  return buildUserList(context, 1); // Afficher 1 colonne sur mobile
                } else if (Responsive.isTablet(context)) {
                  return buildUserList(context, 2); // Afficher 2 colonnes sur tablette
                } else {
                  return buildUserList(context, 3); // Afficher 3 colonnes sur desktop
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour générer la liste des utilisateurs de manière responsive
  Widget buildUserList(BuildContext context, int columnCount) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3, // Ajuster l'aspect des éléments dans la grille
      ),
      itemCount: 10, // Nombre d'utilisateurs, à remplacer par les données réelles
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF914b14), // Couleur de l'avatar
              child: Icon(Icons.person),
            ),
            title: Text('Utilisateur ${index + 1}'),
            subtitle: Text('Email: user${index + 1}@example.com'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Logique pour modifier un utilisateur
              },
            ),
          ),
        );
      },
    );
  }
}


