import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> teamMembers = [
      {'name': 'René Pincus', 'role': 'Inhaber & Meister', 'phone': '+49 176 / 20529820'},
      {'name': 'Mitarbeiter 1', 'role': 'Baumpflege / Vorarbeiter', 'phone': 'Aktiv'},
      {'name': 'Mitarbeiter 2', 'role': 'Garten- & Landschaftsbau', 'phone': 'Aktiv'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team & Mitarbeiter'),
        backgroundColor: Colors.green[800],
      ),
      body: ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(member['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${member['role']} • ${member['phone']}'),
              trailing: const Icon(Icons.phone, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
