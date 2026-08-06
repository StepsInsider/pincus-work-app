import 'package:flutter/material.dart';
import '../models/app_data.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({Key? key}) : super(key: key);

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  final List<TimeEntry> _entries = [];
  final _employeeController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedProject = 'Projekt 1: Baumpflege Kamen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeiterfassung'),
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
            DropdownButtonFormField<String>(
              value: _selectedProject,
              items: const [
                DropdownMenuItem(value: 'Projekt 1: Baumpflege Kamen', child: Text('Baumpflege Kamen')),
                DropdownMenuItem(value: 'Projekt 2: Pflasterung Unna', child: Text('Pflasterung Unna')),
                DropdownMenuItem(value: 'Projekt 3: Erdarbeiten Dortmund', child: Text('Erdarbeiten Dortmund')),
              ],
              onChanged: (val) => setState(() => _selectedProject = val!),
              decoration: const InputDecoration(labelText: 'Baustelle / Projekt'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Tätigkeit / Notiz'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
              onPressed: () {
                if (_employeeController.text.isNotEmpty) {
                  setState(() {
                    _entries.add(
                      TimeEntry(
                        id: DateTime.now().toString(),
                        employeeName: _employeeController.text,
                        projectId: _selectedProject,
                        startTime: DateTime.now().subtract(const Duration(hours: 8)),
                        endTime: DateTime.now(),
                        notes: _notesController.text,
                      ),
                    );
                    _notesController.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('8 Stunden buchen'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    child: ListTile(
                      title: Text('${entry.employeeName} - ${entry.projectId}'),
                      subtitle: Text('Notiz: ${entry.notes} (${entry.duration.inHours} Std.)'),
                      trailing: const Icon(Icons.check_circle, color: Colors.green),
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
