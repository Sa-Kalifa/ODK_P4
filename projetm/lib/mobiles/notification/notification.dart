import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../acceuil/app_bar.dart';

class NotificationPage extends StatefulWidget {
  final String otherUserId; // ID de l'utilisateur avec qui discuter
  const NotificationPage({super.key, required this.otherUserId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _messages = []; // Liste des messages pour la discussion
  List<Map<String, dynamic>> _users = []; // Liste des utilisateurs disponibles

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Charger les messages lorsque la page est initialisée
  }

  Future<void> _loadMessages() async {
    // Charger les messages de l'utilisateur courant avec l'autre utilisateur
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('senderId', isEqualTo: currentUser?.uid)
        .where('receiverId', isEqualTo: widget.otherUserId)
        .orderBy('timestamp')
        .get();

    setState(() {
      _messages = messagesSnapshot.docs.map((doc) {
        return {
          'senderId': doc['senderId'],
          'content': doc['content'],
          'timestamp': doc['timestamp'],
          'type': doc['type'],
        };
      }).toList();
    });
  }

  void _sendMessage(String content, String type) async {
    if (content.isNotEmpty) {
      await FirebaseFirestore.instance.collection('chats').add({
        'senderId': currentUser?.uid,
        'receiverId': widget.otherUserId,
        'content': content,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  Future<void> _sendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String fileName = result.files.single.name;
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('chat_files/$fileName')
          .putFile(File(result.files.single.path!));

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(downloadUrl, 'file');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _showUserInfoDialog() async {
    // Afficher les informations de l'utilisateur
    final userInfo = await FirebaseFirestore.instance.collection('users').doc(widget.otherUserId).get();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(userInfo['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(userInfo['photoUrl']),
            Text("Email: ${userInfo['email']}"),
            Text("Role: ${userInfo['role']}"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Fermer')),
        ],
      ),
    );
  }

  void _openUserList() async {
    // Ouvrir la liste des utilisateurs pour démarrer une conversation
    final userList = await FirebaseFirestore.instance.collection('users').get();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: userList.docs.map((userDoc) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(userDoc['photoUrl'] ?? 'https://via.placeholder.com/150'), // Image de profil
              ),
              title: Text(userDoc['name']),
              subtitle: Text(userDoc['role']),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationPage(otherUserId: userDoc.id),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: _showUserInfoDialog,
              child: CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Remplacer par l'URL réelle de la photo de profil de l'utilisateur
              ),
            ),
            SizedBox(width: 10),
            Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _messages.isNotEmpty
                ? ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == currentUser?.uid;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[300] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: TextStyle(
                            color: isMe ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(child: Text('Aucune discussion en cours.')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text, 'text'),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: _sendFile,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _openUserList,
            child: Text('Discuter avec d\'autres utilisateurs'),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 2),
    );
  }
}
