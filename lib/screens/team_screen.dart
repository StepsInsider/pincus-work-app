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
      final data = await _supabase
          .from('mitarbeiter')
          .select('id,name,rolle,telefon,status')
          .order('name');
      if (!mounted) return;
      setState(() {
        _members = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Mitarbeiter konnten nicht geladen werden: $error';
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
            onPressed: _loadMembers,
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
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
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
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
                  final role = member['rolle']?.toString() ?? 'Mitarbeiter';
                  final phone = member['telefon']?.toString() ?? '';
                  final status = member['status']?.toString() ?? 'Aktiv';
                  final active = status.toLowerCase() == 'aktiv';
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
                        phone.isEmpty
                            ? '$role • $status'
                            : '$role • $phone • $status',
                      ),
                      trailing: Icon(
                        active ? Icons.check_circle : Icons.pause_circle,
                        color: active ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
