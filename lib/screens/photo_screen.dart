import 'package:flutter/material.dart';
import '../models/app_data.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final List<SitePhoto> _photos = [];
  String _selectedCategory = 'Vorher';
  final _employeeController = TextEditingController();
  final _projectController = TextEditingController(text: 'Baumpflege Kamen');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baustellen-Fotos'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _employeeController,
              decoration: const InputDecoration(labelText: 'Mitarbeiter Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _projectController,
              decoration: const InputDecoration(labelText: 'Projekt / Baustelle'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: const [
                DropdownMenuItem(value: 'Vorher', child: Text('Vorher')),
                DropdownMenuItem(value: 'Währenddessen', child: Text('Währenddessen')),
                DropdownMenuItem(value: 'Nachher', child: Text('Nachher')),
              ],
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'Kategorie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              onPressed: () {
                if (_employeeController.text.isNotEmpty) {
                  setState(() {
                    _photos.add(
                      SitePhoto(
                        id: DateTime.now().toString(),
                        projectId: _projectController.text,
                        employeeName: _employeeController.text,
                        imageUrl: 'https://via.placeholder.com/150',
                        timestamp: DateTime.now(),
                        category: _selectedCategory,
                      ),
                    );
                  });
                }
              },
              icon: const Icon(Icons.camera),
              label: const Text('Foto aufnehmen / hochladen'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  final photo = _photos[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.image, size: 40, color: Colors.green),
                      title: Text('${photo.projectId} (${photo.category})'),
                      subtitle: Text('Von: ${photo.employeeName} am ${photo.timestamp.hour}:${photo.timestamp.minute} Uhr'),
                      trailing: const Icon(Icons.cloud_done, color: Colors.blue),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
