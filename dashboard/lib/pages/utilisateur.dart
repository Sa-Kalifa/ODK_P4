import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dashboard/parametre/couleur.dart'; // Tes couleurs personnalisées

class Utilisateur extends StatefulWidget {
  const Utilisateur({super.key});

  @override
  State<Utilisateur> createState() => _UtilisateurState();
}

class _UtilisateurState extends State<Utilisateur> {
  @override
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Contrôleur pour le mot de passe
  final TextEditingController _phoneController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
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
      data['id'] = doc.id; // Ajoute l'ID pour pouvoir manipuler
      return data;
    }).toList();
  }

  // Fonction pour ajouter ou modifier un utilisateur
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
        // Mise à jour d'un utilisateur existant
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
        // Création de l'utilisateur dans Firebase Auth et Firestore
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Ajout à Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'nom': _nameController.text,
          'email': _emailController.text,
          'tel': _phoneController.text,
          'role': _role,
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur ajouté avec succès!')),
        );
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

  // Fonction pour supprimer un utilisateur de Firestore, Firebase Auth et les histoires associées
  Future<void> _deleteUser(String userId, String email, String password) async {
    try {
      await _deleteUserStories(userId);
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      print('Utilisateur supprimé de Firestore : $email');
      await _deleteUserAuth(email, password);
      print('Utilisateur supprimé de Firebase Auth : $email');

      // Supprimer l'utilisateur de la liste locale et rafraîchir
      setState(() {
        _users.removeWhere((user) => user['id'] == userId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur supprimé avec succès')),
      );
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }



  // Fonction pour supprimer les histoires de l'utilisateur
  Future<void> _deleteUserStories(String userId) async {
    QuerySnapshot storiesSnapshot = await FirebaseFirestore.instance
        .collection('histoires')
        .where('userId', isEqualTo: userId)
        .get();

    for (var storyDoc in storiesSnapshot.docs) {
      String storyId = storyDoc.id;

      // Supprimer les fichiers dans Firebase Storage associés à cette histoire
      List mediaUrls = storyDoc['mediaUrls'];
      for (String mediaUrl in mediaUrls) {
        await FirebaseStorage.instance.refFromURL(mediaUrl).delete();
      }

      // Supprimer l'histoire de Firestore
      await FirebaseFirestore.instance.collection('histoires').doc(storyId).delete();
    }
  }

  // Fonction pour supprimer l'utilisateur de Firebase Auth
  Future<void> _deleteUserAuth(String email, String password) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Re-authentifier l'utilisateur pour le supprimer
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await currentUser!.reauthenticateWithCredential(credential);

      // Supprimer l'utilisateur
      await currentUser.delete();
    } catch (e) {
      throw 'Erreur lors de la suppression de l\'utilisateur Auth : $e';
    }
  }

  void _showDeleteConfirmation(String? userId, String? role, String? email, String password) {
    if (userId == null || role == null || email == null) {
      print("Erreur : un des champs est null (id, role, email)");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Confirmer la suppression', style: TextStyle(color: Colors.red[800])),
          content: const Text('Êtes-vous sûr de vouloir supprimer cet utilisateur et toutes ses données associées ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.red[800],
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);

                if (role == 'Admin') {
                  _showAdminDeleteConfirmation(userId, email);
                } else {
                  _deleteUser(userId, email, password).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Utilisateur supprimé avec succès')),
                    );

                    setState(() {
                      // Actualise l'interface utilisateur
                    });
                  });
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

// Popup supplémentaire pour la suppression des Admins
  void _showAdminDeleteConfirmation(String userId, String email) {
    bool _confirmResponsibility = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                    foregroundColor: _confirmResponsibility ? Colors.white : Colors.red,
                    backgroundColor: _confirmResponsibility ? Colors.red[800] : Colors.transparent,
                  ),
                  onPressed: _confirmResponsibility
                      ? () {
                    Navigator.pop(context);
                    _deleteUser(userId, email, _passwordController.text).then((_) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Admin supprimé avec succès')),
                      );

                      // Recharger automatiquement la page
                      setState(() {
                        // Recharge des données ou rafraîchissement de l’interface
                      });
                    });
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


  // Fonction pour bloquer ou débloquer un utilisateur
  Future<void> _toggleBlockUser(String userId, bool isBlocked) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isBlocked': !isBlocked,
    });
    setState(() {});
  }

  // Popup de création ou modification d'utilisateur avec liste de rôle sélective
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
      _role = ''; // Par défaut, aucun rôle sélectionné
      _imageUrl = null;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(userData == null
              ? 'Ajouter un utilisateur'
              : 'Modifier un utilisateur'),
          content: SingleChildScrollView(
            child: Form(
              //key: _formKey, // Ajout d'une clé pour la validation du formulaire
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Veuillez entrer un nom'
                        : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                    value == null || !value.contains('@')
                        ? 'Veuillez entrer un email valide'
                        : null,
                  ),
                  if (userData ==
                      null) // Champ mot de passe uniquement pour l'ajout
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (value) =>
                      value == null || value.length < 6
                          ? 'Le mot de passe doit contenir au moins 6 caractères'
                          : null,
                    ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Téléphone'),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Veuillez entrer un numéro de téléphone'
                        : null,
                  ),
                  const SizedBox(height: 10),

                  // DropdownButtonFormField pour choisir un rôle avec validation
                  DropdownButtonFormField<String>(
                    value: _role.isEmpty ? null : _role,
                    // Valeur par défaut à null pour afficher le placeholder
                    decoration: InputDecoration(
                      labelText: 'Rôle',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    hint: const Text('Sélectionnez un rôle'),
                    // Placeholder si aucun rôle sélectionné
                    validator: (value) =>
                    value == null
                        ? 'Veuillez sélectionner un rôle'
                        : null,
                    // Validation
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
                  const SizedBox(height: 10),

                  // Affichage de l'image (si disponible)
                  if (_imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.network(_imageUrl!, height: 100),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _saveUser(userId: userId),
              child: _isLoading ? const CircularProgressIndicator() : Text(
                  userData == null ? 'Ajouter' : 'Modifier'),
            ),
          ],
        );
      },
    );
  }

  // AppBar personnalisée avec barre de recherche, notification et profil
  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Centre les widgets
      children: [
        SizedBox(
          width: 800,
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
        const SizedBox(width: 10), // Espace entre recherche et filtre
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Couleur.bg,
        leading: const SizedBox.shrink(), // Retire l'icône de retour
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
            scrollDirection: Axis.vertical, // Active le défilement vertical
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRoleCard(
                        'Partenaire', 'person', 'Partenaire', Couleur.pr),
                    const SizedBox(width: 40),
                    _buildRoleCard('Membre', 'person', 'Membre', Couleur.nav),
                    const SizedBox(width: 40),
                    _buildRoleCard(
                        'Admin', 'admin_panel_settings', 'Admin', Couleur.sec),
                  ],
                ),
                const SizedBox(height: 50),

                // Scrollable DataTable
                SizedBox(
                  height: 400, // Hauteur maximale pour le tableau
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    // Active le défilement vertical
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Image', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Nom', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Email', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Téléphone', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Rôle', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                        DataColumn(label: Text('Action', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18))),
                      ],
                      rows: users.map((user) {
                        bool isBlocked = user['isBlocked'] ?? false;
                        return DataRow(cells: [
                          DataCell(Text((users.indexOf(user) + 1).toString())),
                          // Colonne ID
                          DataCell(CircleAvatar(
                            backgroundImage: NetworkImage(
                                user['image_url'] ?? ''),
                          )),
                          DataCell(Text(user['nom'] ?? '')),
                          DataCell(Text(user['email'] ?? '')),
                          DataCell(Text(user['tel'] ?? '')),
                          DataCell(Text(user['role'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.edit, color: Couleur.pr),
                                onPressed: () => _showUserDialog(
                                    userId: user['id'], userData: user),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  // Récupération des informations de l'utilisateur
                                  final userId = user['id']; // Assurez-vous que 'user' est bien défini et contient 'id'
                                  final role = user['role'];
                                  final email = user['email'];

                                  // Appelle la fonction de popup de confirmation de suppression
                                  _showDeleteConfirmation(userId, role, email, _passwordController.text);

                                },
                              ),


                              IconButton(
                                icon: Icon(
                                  isBlocked ? Icons.lock : Icons.lock_open,
                                  color: isBlocked ? Colors.red : Colors.green,
                                ),
                                onPressed: () =>
                                    _toggleBlockUser(user['id'], isBlocked),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// Widget pour construire les cartes de rôle
  Widget _buildRoleCard(String role, String icon, String roleType,
      Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      color: color,
      child: SizedBox(
        width: 200,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 40, color: Couleur.blanc),
            Text(roleType, style: const TextStyle(color: Couleur.blanc)),
            FutureBuilder<int>(
              future: _countUsersByRole(role),
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? snapshot.data!.toString() : '0',
                  style: const TextStyle(
                    color: Couleur.blanc,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}