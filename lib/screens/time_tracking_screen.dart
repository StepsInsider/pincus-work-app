import 'package:flutter/material.dart';

import '../models/app_data.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});
  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  final _entries = <TimeEntry>[];
  final _employeeController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedProject = 'Baumpflege Kamen';

  @override
  void dispose() {
    _employeeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (_employeeController.text.trim().isEmpty) return;
    final now = DateTime.now();
    setState(() {
      _entries.add(TimeEntry(
        id: now.microsecondsSinceEpoch.toString(),
        employeeName: _employeeController.text.trim(),
        projectId: _selectedProject,
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now,
        notes: _notesController.text.trim(),
      ));
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Zeiterfassung')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _employeeController, decoration: const InputDecoration(labelText: 'Mitarbeitername')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedProject,
              decoration: const InputDecoration(labelText: 'Baustelle / Projekt'),
              items: const ['Baumpflege Kamen', 'Pflasterung Unna', 'Erdarbeiten Dortmund']
                  .map((project) => DropdownMenuItem(value: project, child: Text(project)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedProject = value!),
            ),
            const SizedBox(height: 10),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Tätigkeit / Notiz')),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: _addEntry, icon: const Icon(Icons.add), label: const Text('8 Stunden buchen')),
            const SizedBox(height: 16),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('Noch keine Zeiteinträge.'))
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text('${entry.employeeName} – ${entry.projectId}'),
                          subtitle: Text('${entry.notes.isEmpty ? 'Ohne Notiz' : entry.notes} (${entry.duration.inHours} Std.)'),
                        );
                      },
                    ),
            ),
          ]),
        ),
      );
}
