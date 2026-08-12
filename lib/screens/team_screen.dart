import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _supabase.from('mitarbeiter').select().order('name');

      if (!mounted) return;

      setState(() {
        _members = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Mitarbeiter konnten nicht geladen werden: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team & Mitarbeiter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
            onPressed: _loadMembers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _loadMembers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            )
          : _members.isEmpty
          ? const Center(child: Text('Noch keine Mitarbeiter vorhanden.'))
          : RefreshIndicator(
              onRefresh: _loadMembers,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];

                  final name = member['name']?.toString() ?? 'Unbekannt';
                  final rolle = member['rolle']?.toString() ?? 'Mitarbeiter';
                  final telefon = member['telefon']?.toString() ?? '';
                  final status = member['status']?.toString() ?? 'Aktiv';

                  final aktiv = status.toLowerCase() == 'aktiv';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        telefon.isEmpty
                            ? '$rolle • $status'
                            : '$rolle • $telefon • $status',
                      ),
                      trailing: Icon(
                        aktiv ? Icons.check_circle : Icons.pause_circle,
                        color: aktiv ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
