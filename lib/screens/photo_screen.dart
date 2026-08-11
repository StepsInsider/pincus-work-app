import 'package:flutter/material.dart';

import '../models/app_data.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final _photos = <SitePhoto>[];
  final _employeeController = TextEditingController();
  final _projectController = TextEditingController(text: 'Baumpflege Kamen');
  String _category = 'Vorher';

  @override
  void dispose() {
    _employeeController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  void _addPhoto() {
    if (_employeeController.text.trim().isEmpty || _projectController.text.trim().isEmpty) return;
    final now = DateTime.now();
    setState(() => _photos.add(SitePhoto(
          id: now.microsecondsSinceEpoch.toString(), projectId: _projectController.text.trim(),
          employeeName: _employeeController.text.trim(), timestamp: now, category: _category,
        )));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Baustellen-Fotos')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _employeeController, decoration: const InputDecoration(labelText: 'Mitarbeitername')),
            const SizedBox(height: 10),
            TextField(controller: _projectController, decoration: const InputDecoration(labelText: 'Projekt / Baustelle')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items: const ['Vorher', 'Währenddessen', 'Nachher']
                  .map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _addPhoto, icon: const Icon(Icons.camera_alt), label: const Text('Foto erfassen')),
            const SizedBox(height: 16),
            Expanded(child: _photos.isEmpty
                ? const Center(child: Text('Noch keine Fotos erfasst.'))
                : ListView.builder(itemCount: _photos.length, itemBuilder: (context, index) {
                    final photo = _photos[index];
                    return ListTile(
                      leading: const Icon(Icons.image, size: 40),
                      title: Text('${photo.projectId} (${photo.category})'),
                      subtitle: Text('Von ${photo.employeeName} um ${TimeOfDay.fromDateTime(photo.timestamp).format(context)} Uhr'),
                      trailing: const Icon(Icons.cloud_done),
                    );
                  })),
          ]),
        ),
      );
}
