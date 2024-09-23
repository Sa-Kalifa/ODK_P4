import'package:flutter/material.dart';
import '../acceuil/app_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'Admin',
      'message': 'Bonjour, comment puis-je vous aider aujourd\'hui ?',
      'timestamp': DateTime.now().subtract(Duration(minutes: 5))
    },
    {
      'role': 'Partenaire',
      'message': 'J\'ai une question sur le dernier exercice.',
      'timestamp': DateTime.now().subtract(Duration(minutes: 3))
    },
    {
      'role': 'Membre',
      'message': 'Bien sûr, quel est votre problème ?',
      'timestamp': DateTime.now().subtract(Duration(minutes: 1))
    }
  ];

  void _sendMessage() {
    final message = _messageController.text;
    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          'role': 'Membre',
          'message': message,
          'timestamp': DateTime.now()
        });
        _messageController.clear();
      });
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    // Formate la date et l'heure en "dd/MM/yyyy HH:mm"
    String day = timestamp.day.toString().padLeft(2, '0');
    String month = timestamp.month.toString().padLeft(2, '0');
    String year = timestamp.year.toString();
    String hour = timestamp.hour.toString().padLeft(2, '0');
    String minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        centerTitle: true, // Centre le titre
        leading: SizedBox.shrink(), // Retire l'icône de retour
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0), // Espace plus grand entre l'en-tête et le contenu
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isFormateur = message['role'] == 'Partenaire';
                  final timestamp = message['timestamp'] as DateTime;
                  final formattedTime = _formatTimestamp(timestamp);

                  return Align(
                    alignment: isFormateur ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 8), // Espace entre les messages
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isFormateur ? Colors.grey[200] : Colors.blue[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['message']!,
                            style: TextStyle(color: isFormateur ? Colors.black : Colors.white),
                          ),
                          SizedBox(height: 8), // Espace entre le message et la date
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: isFormateur ? Colors.black54 : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomAppBar(currentIndex: 2),
    );
  }
}
