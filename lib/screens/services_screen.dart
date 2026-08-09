import 'package:flutter/material.dart';
import '../data/services.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leistungsübersicht'),
        backgroundColor: Colors.green[800],
      ),
      body: ListView.builder(
        itemCount: pincusServices.length,
        itemBuilder: (context, index) {
          final service = pincusServices[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ausgewählt: $service')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
