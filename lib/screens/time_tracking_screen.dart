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
  // Werte bewusst wie im Hauptprojekt belassen (nicht die verkürzte
  // Variante aus dem Zweitprojekt) – andere Stellen (Repository/Provider)
  // könnten sich auf genau diese projectId-Strings verlassen.
  String _selectedProject = 'Projekt 1: Baumpflege Kamen';

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
      _entries.add(
        TimeEntry(
          id: now.microsecondsSinceEpoch.toString(),
          employeeName: _employeeController.text.trim(),
          projectId: _selectedProject,
          startTime: now.subtract(const Duration(hours: 8)),
          endTime: now,
          notes: _notesController.text.trim(),
        ),
      );
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Zeiterfassung')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _employeeController,
                decoration: const InputDecoration(labelText: 'Mitarbeitername'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedProject,
                decoration: const InputDecoration(labelText: 'Baustelle / Projekt'),
                items: const [
                  DropdownMenuItem(value: 'Projekt 1: Baumpflege Kamen', child: Text('Baumpflege Kamen')),
                  DropdownMenuItem(value: 'Projekt 2: Pflasterung Unna', child: Text('Pflasterung Unna')),
                  DropdownMenuItem(value: 'Projekt 3: Erdarbeiten Dortmund', child: Text('Erdarbeiten Dortmund')),
                ],
                onChanged: (value) => setState(() => _selectedProject = value!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Tätigkeit / Notiz'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _addEntry,
                icon: const Icon(Icons.add),
                label: const Text('8 Stunden buchen'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _entries.isEmpty
                    ? const Center(child: Text('Noch keine Zeiteinträge.'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text('${entry.employeeName} – ${entry.projectId}'),
                              subtitle: Text(
                                '${entry.notes.isEmpty ? 'Ohne Notiz' : entry.notes} '
                                '(${entry.duration.inHours} Std.)',
                              ),
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
