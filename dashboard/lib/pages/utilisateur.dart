import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/parametre/couleur.dart'; // Tes couleurs personnalisées

class Utilisateur extends StatefulWidget {
  const Utilisateur({super.key});

  @override
  State<Utilisateur> createState() => _UtilisateurState();
}

class _UtilisateurState extends State<Utilisateur> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Contrôleur pour le mot de passe
  final TextEditingController _phoneController = TextEditingController();
  String _role = 'Membre'; // Rôle par défaut
  String _filterRole = 'Tous'; // Pour filtrer par rôle
  bool _isLoading = false;
  String? _imageUrl; // Pour afficher l'image

  // Fonction pour compter les utilisateurs par rôle
  Future<int> _countUsersByRole(String role) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.length;
  }

  // Fonction pour récupérer les utilisateurs depuis Firestore
  Future<List<Map<String, dynamic>>> _getUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Ajoute l'ID pour pouvoir le manipuler
      return data;
    }).toList();
  }

  // Fonction pour enregistrer l'utilisateur dans Firebase Authentication
  Future<void> _registerUserInAuth(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Firebase Auth: $e')),
      );
    }
  }

  // Fonction pour ajouter ou modifier un utilisateur dans Firestore
  Future<void> _saveUser({String? userId}) async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (userId != null) {
        // Mise à jour de l'utilisateur existant dans Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'nom': _nameController.text,
          'email': _emailController.text,
          'tel': _phoneController.text,
          'role': _role,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur modifié avec succès!')),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance.collection('users').add({
          'nom': _nameController.text,
          'email': _emailController.text,
          'tel': _phoneController.text,
          'role': _role,
          'isBlocked': false,
        });
      }

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      setState(() {
        _role = 'Membre';
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }
  // Fonction pour supprimer un utilisateur
  Future<void> _deleteUser(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utilisateur supprimé avec succès!')),
    );
    setState(() {});
  }

  // Popup de confirmation de suppression
  void _showDeleteConfirmation(String userId, String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Confirmer la suppression', style: TextStyle(color: Colors.red[800])),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
              ),
              onPressed: () {
                Navigator.pop(context);
                if (role == 'Admin') {
                  _showAdminDeleteConfirmation(userId);
                } else {
                  _deleteUser(userId);
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  // Popup de confirmation supplémentaire pour les Admins
  void _showAdminDeleteConfirmation(String userId) {
    bool _confirmResponsibility = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Attention : Suppression d\'un Admin', style: TextStyle(color: Colors.orange[800])),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Supprimer un administrateur peut avoir des conséquences importantes. '
                        'Cochez la case ci-dessous pour confirmer que vous assumez cette responsabilité.',
                  ),
                  CheckboxListTile(
                    title: const Text('Je comprends et assume la responsabilité.'),
                    value: _confirmResponsibility,
                    onChanged: (value) {
                      setState(() {
                        _confirmResponsibility = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _confirmResponsibility ? Colors.red[800] : Colors.grey,
                  ),
                  onPressed: _confirmResponsibility
                      ? () {
                    Navigator.pop(context);
                    _deleteUser(userId);
                  }
                      : null,
                  child: const Text('Supprimer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Pop-up pour ajouter ou modifier un utilisateur
  void _showUserDialog({String? userId, Map<String, dynamic>? userData}) {
    if (userData != null) {
      _nameController.text = userData['nom'];
      _emailController.text = userData['email'];
      _phoneController.text = userData['tel'];
      _role = userData['role'];
      _imageUrl = userData['image_url']; // Image pour affichage
    } else {
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _role = 'Membre';
      _imageUrl = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(userData == null ? 'Ajouter un utilisateur' : 'Modifier un utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                if (userData == null) // Champ mot de passe uniquement pour l'ajout
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                  ),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Téléphone'),
                ),
                DropdownButton<String>(
                  value: _role,
                  items: ['Admin', 'Partenaire', 'Membre'].map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _role = value!;
                    });
                  },
                ),
                if (_imageUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Image.network(_imageUrl!, height: 100),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _saveUser(userId: userId),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(userData == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour bloquer ou débloquer un utilisateur
  Future<void> _toggleBlockUser(String userId, bool isBlocked) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isBlocked': !isBlocked,
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Couleur.bg,
        actions: [
          // Barre de recherche
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtre par rôle
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Filtrer par rôle'),
                    content: DropdownButton<String>(
                      value: _filterRole,
                      items: ['Tous', 'Admin', 'Partenaire', 'Membre'].map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _filterRole = value!;
                          Navigator.pop(context); // Ferme le popup après sélection
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: Couleur.pr,
        child: const Icon(Icons.add, color: Couleur.blanc,),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé.'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          // Application des filtres et recherche
          if (_filterRole != 'Tous') {
            users = users.where((user) => user['role'] == _filterRole).toList();
          }
          if (_searchController.text.isNotEmpty) {
            users = users.where((user) {
              return user['nom']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase());
            }).toList();
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      color: Couleur.pr,
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, size: 40, color: Couleur.blanc,),
                            const Text('Partenaires',style: TextStyle(
                                color: Couleur.blanc
                            ),),
                            FutureBuilder<int>(
                              future: _countUsersByRole('Partenaire'),
                              builder: (context, snapshot) {
                                return Text(snapshot.hasData ? snapshot.data!.toString() : '0', style: const TextStyle(
                                    color: Couleur.blanc,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Couleur.nav,
                      elevation: 5,
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, size: 40, color: Couleur.blanc,),
                            const Text('Membres',style: TextStyle(
                                color: Couleur.blanc
                            ),),
                            FutureBuilder<int>(
                              future: _countUsersByRole('Membre'),
                              builder: (context, snapshot) {
                                return Text(snapshot.hasData ? snapshot.data!.toString() : '0',style: const TextStyle(
                                    color: Couleur.blanc,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Couleur.sec,
                      elevation: 5,
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 40, color: Couleur.blanc),
                            const Text('Admins', style: TextStyle(
                              color: Couleur.blanc
                            ),),
                            FutureBuilder<int>(
                              future: _countUsersByRole('Admin'),
                              builder: (context, snapshot) {
                                return Text(snapshot.hasData ? snapshot.data!.toString() : '0',style: const TextStyle(
                                    color: Couleur.blanc,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold
                                ),);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Téléphone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      ],
                      rows: users.map((user) {
                        bool isBlocked = user['isBlocked'] ?? false;
                        return DataRow(cells: [
                          DataCell(Text((users.indexOf(user) + 1).toString())), // Colonne ID
                          DataCell(CircleAvatar(
                            backgroundImage: NetworkImage(user['image_url'] ?? ''),
                          )),
                          DataCell(Text(user['nom'] ?? '')),
                          DataCell(Text(user['email'] ?? '')),
                          DataCell(Text(user['tel'] ?? '')),
                          DataCell(Text(user['role'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showUserDialog(userId: user['id'], userData: user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await FirebaseFirestore.instance.collection('users').doc(user['id']).delete();
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  isBlocked ? Icons.lock : Icons.lock_open,
                                  color: isBlocked ? Colors.red : Colors.green,
                                ),
                                onPressed: () => _toggleBlockUser(user['id'], isBlocked),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ],
                ),

              ],
            ),
          );
        },
      ),

    );
  }
}
