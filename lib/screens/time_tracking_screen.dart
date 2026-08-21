import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  final _supabase = Supabase.instance.client;
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _entries = [];

  String? _employeeId;
  String? _customerId;
  String? _locationId;
  String? _activeEntryId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final employees = await _supabase
          .from('mitarbeiter')
          .select('id,name,rolle,status')
          .eq('status', 'Aktiv')
          .order('name');
      final customers = await _supabase
          .from('kunden')
          .select('id,name,firmenname,company_id')
          .order('name');
      final locations = await _supabase
          .from('standorte')
          .select('id,kunden_id,name,strasse,plz,ort')
          .eq('aktiv', true)
          .order('name');
      final entries = await _supabase
          .from('zeiterfassung')
          .select(
            'id,mitarbeiter_id,standort_id,start_zeit,end_zeit,pause_minuten,notiz',
          )
          .order('start_zeit', ascending: false)
          .limit(30);

      if (!mounted) return;
      setState(() {
        _employees = List<Map<String, dynamic>>.from(employees);
        _customers = List<Map<String, dynamic>>.from(customers);
        _locations = List<Map<String, dynamic>>.from(locations);
        _entries = List<Map<String, dynamic>>.from(entries);
        _employeeId ??= _employees.isNotEmpty
            ? _employees.first['id'].toString()
            : null;
        _activeEntryId = _entries
            .cast<Map<String, dynamic>?>()
            .firstWhere(
              (entry) => entry?['end_zeit'] == null,
              orElse: () => null,
            )?['id']
            ?.toString();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Zeiterfassung konnte nicht geladen werden: $error';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredLocations => _locations
      .where((location) => location['kunden_id']?.toString() == _customerId)
      .toList();

  String _customerName(String? id) {
    final row = _customers.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id']?.toString() == id,
      orElse: () => null,
    );
    return (row?['name'] ?? row?['firmenname'] ?? 'Kunde').toString();
  }

  String _employeeName(String? id) {
    final row = _employees.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id']?.toString() == id,
      orElse: () => null,
    );
    return (row?['name'] ?? 'Mitarbeiter').toString();
  }

  String _locationName(String? id) {
    final row = _locations.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id']?.toString() == id,
      orElse: () => null,
    );
    return (row?['name'] ?? 'Standort').toString();
  }

  Future<void> _startWork() async {
    if (_employeeId == null || _locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Mitarbeiter, Kunde und Standort auswählen.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final row = await _supabase
          .from('zeiterfassung')
          .insert({
            'mitarbeiter_id': _employeeId,
            'standort_id': _locationId,
            'start_zeit': DateTime.now().toUtc().toIso8601String(),
            'pause_minuten': 0,
            'notiz': _notesController.text.trim(),
          })
          .select('id')
          .single();
      if (!mounted) return;
      setState(() {
        _activeEntryId = row['id'].toString();
        _saving = false;
      });
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Start fehlgeschlagen: $error')));
    }
  }

  Future<void> _stopWork() async {
    final id = _activeEntryId;
    if (id == null) return;
    setState(() => _saving = true);
    try {
      await _supabase
          .from('zeiterfassung')
          .update({'end_zeit': DateTime.now().toUtc().toIso8601String()})
          .eq('id', id);
      if (!mounted) return;
      setState(() {
        _activeEntryId = null;
        _saving = false;
      });
      await _loadData();
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Stoppen fehlgeschlagen: $error')));
    }
  }

  Duration _duration(Map<String, dynamic> entry) {
    final start = DateTime.tryParse(entry['start_zeit']?.toString() ?? '');
    final end = DateTime.tryParse(entry['end_zeit']?.toString() ?? '');
    if (start == null) return Duration.zero;
    final effectiveEnd = end ?? DateTime.now().toUtc();
    final pause = (entry['pause_minuten'] as num?)?.toInt() ?? 0;
    return effectiveEnd.difference(start) - Duration(minutes: pause);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).abs();
    return '$hours Std. ${minutes.toString().padLeft(2, '0')} Min.';
  }

  @override
  Widget build(BuildContext context) {
    final locations = _filteredLocations;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeiterfassung'),
        actions: [
          IconButton(
            onPressed: _loadData,
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
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Arbeitszeit erfassen',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _employeeId,
                            decoration: const InputDecoration(
                              labelText: 'Mitarbeiter',
                              border: OutlineInputBorder(),
                            ),
                            items: _employees
                                .map(
                                  (employee) => DropdownMenuItem<String>(
                                    value: employee['id'].toString(),
                                    child: Text(
                                      '${employee['name']} – ${employee['rolle'] ?? 'Mitarbeiter'}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _activeEntryId == null
                                ? (value) => setState(() => _employeeId = value)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: _customerId,
                            decoration: const InputDecoration(
                              labelText: 'Kunde',
                              border: OutlineInputBorder(),
                            ),
                            items: _customers
                                .map(
                                  (customer) => DropdownMenuItem<String>(
                                    value: customer['id'].toString(),
                                    child: Text(
                                      (customer['name'] ??
                                              customer['firmenname'] ??
                                              'Kunde')
                                          .toString(),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _activeEntryId == null
                                ? (value) => setState(() {
                                    _customerId = value;
                                    _locationId = null;
                                  })
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue:
                                locations.any(
                                  (item) =>
                                      item['id'].toString() == _locationId,
                                )
                                ? _locationId
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Standort',
                              border: OutlineInputBorder(),
                            ),
                            items: locations
                                .map(
                                  (location) => DropdownMenuItem<String>(
                                    value: location['id'].toString(),
                                    child: Text(location['name'].toString()),
                                  ),
                                )
                                .toList(),
                            onChanged: _activeEntryId == null
                                ? (value) => setState(() => _locationId = value)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _notesController,
                            enabled: _activeEntryId == null,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Tätigkeit / Notiz',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_activeEntryId == null)
                            FilledButton.icon(
                              onPressed: _saving ? null : _startWork,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Arbeitszeit starten'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: _saving ? null : _stopWork,
                              icon: const Icon(Icons.stop),
                              label: const Text('Arbeitszeit beenden'),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Letzte Zeiteinträge',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_entries.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text('Noch keine Zeiteinträge.')),
                      ),
                    )
                  else
                    ..._entries.map(
                      (entry) => Card(
                        child: ListTile(
                          leading: Icon(
                            entry['end_zeit'] == null
                                ? Icons.timer
                                : Icons.check_circle,
                            color: entry['end_zeit'] == null
                                ? Colors.orange
                                : Colors.green,
                          ),
                          title: Text(
                            '${_employeeName(entry['mitarbeiter_id']?.toString())} – ${_locationName(entry['standort_id']?.toString())}',
                          ),
                          subtitle: Text(
                            '${_customerName(_locations.cast<Map<String, dynamic>?>().firstWhere((l) => l?['id']?.toString() == entry['standort_id']?.toString(), orElse: () => null)?['kunden_id']?.toString())} • ${_formatDuration(_duration(entry))}\n${entry['notiz'] ?? ''}',
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
