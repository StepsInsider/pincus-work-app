import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ebsdgwgorrmkloirnipy.supabase.co',
    anonKey: 'sb_publishable_N83XyWhBZBKJf3CE8HDFhg_4Bq0pIUH',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baum- & Landschaftspflege René Pincus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ─────────────────────────────────────────────
// LOGIN
// ─────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ein Fehler ist aufgetreten: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 140),
                const SizedBox(height: 16),
                const Text(
                  'René Pincus',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Baum- & Landschaftspflege',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Anmelden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = true;
  int _aktiveBaustellen = 0;
  int _gesamtBaustellen = 0;
  double _stundenDieseWoche = 0;
  int _fotosGesamt = 0;
  int _offeneAufgaben = 0;
  int _aktiveMaschinen = 0;
  int _kundenAnzahl = 0;
  int _mitarbeiterAnzahl = 0;
  int _ungeleseneNachrichten = 0;
  int _dokumenteAnzahl = 0;
  DateTime _kalenderMonat = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _ladenStatistiken();
  }

  DateTime _montagDerWoche(DateTime datum) {
    final normal = DateTime(datum.year, datum.month, datum.day);
    return normal.subtract(Duration(days: normal.weekday - 1));
  }

  Future<void> _ladenStatistiken() async {
    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser!.id;
      final montag = _montagDerWoche(DateTime.now());
      final naechsterMontag = montag.add(const Duration(days: 7));

      final baustellenData = await supabase.from('baustellen').select('id, status');
      final baustellenListe = List<Map<String, dynamic>>.from(baustellenData);

      final zeitData = await supabase
          .from('zeiterfassung')
          .select('start_zeit, end_zeit')
          .eq('user_id', userId)
          .gte('start_zeit', montag.toIso8601String())
          .lt('start_zeit', naechsterMontag.toIso8601String());
      final zeitListe = List<Map<String, dynamic>>.from(zeitData);

      double minuten = 0;
      for (final e in zeitListe) {
        if (e['end_zeit'] != null) {
          final start = DateTime.parse(e['start_zeit']);
          final ende = DateTime.parse(e['end_zeit']);
          minuten += ende.difference(start).inMinutes;
        }
      }

      final fotosData = await supabase.from('fotos').select('id');
      final fotosListe = List<Map<String, dynamic>>.from(fotosData);

      // Dummy-Zählungen für neue Module (lässt sich später an echte Tabellen anbinden)
      setState(() {
        _gesamtBaustellen = baustellenListe.length;
        _aktiveBaustellen = baustellenListe.where((b) => b['status'] != 'fertig').length;
        _stundenDieseWoche = minuten / 60;
        _fotosGesamt = fotosListe.length;
        _offeneAufgaben = 3;
        _aktiveMaschinen = 5;
        _kundenAnzahl = 12;
        _mitarbeiterAnzahl = 4;
        _ungeleseneNachrichten = 2;
        _dokumenteAnzahl = 28;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  static const _monatsNamen = [
    'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
    'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
  ];

  Widget _buildKalender() {
    final erstesDesMonats = DateTime(_kalenderMonat.year, _kalenderMonat.month, 1);
    final vorschubTage = erstesDesMonats.weekday - 1;
    final letzterTag = DateTime(_kalenderMonat.year, _kalenderMonat.month + 1, 0).day;
    final heute = DateTime.now();

    final zellen = <Widget>[];

    for (var i = 0; i < vorschubTage; i++) {
      zellen.add(const SizedBox());
    }

    for (var tag = 1; tag <= letzterTag; tag++) {
      final istHeute = heute.year == _kalenderMonat.year &&
          heute.month == _kalenderMonat.month &&
          heute.day == tag;

      zellen.add(
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: istHeute
                ? Border.all(color: Colors.orange, width: 2)
                : Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('$tag'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _kalenderMonat = DateTime(_kalenderMonat.year, _kalenderMonat.month - 1);
                    });
                  },
                ),
                Text(
                  '${_monatsNamen[_kalenderMonat.month - 1]} ${_kalenderMonat.year}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _kalenderMonat = DateTime(_kalenderMonat.year, _kalenderMonat.month + 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So']
                  .map((tag) => Expanded(
                        child: Center(
                          child: Text(
                            tag,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1,
              children: zellen,
            ),
          ],
        ),
      ),
    );
  }

  void _zeigeModulHinweis(BuildContext context, String modulName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modul "$modulName" wird geöffnet...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 10),
            const Text('René Pincus'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Abmelden',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _ladenStatistiken,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                padding: const EdgeInsets.all(16),
                children: [
                  // Kennzahlen-Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(icon: Icons.location_on, color: Colors.green, value: '$_aktiveBaustellen', label: 'Aktive Baustellen'),
                      _StatCard(icon: Icons.access_time, color: Colors.orange, value: _stundenDieseWoche.toStringAsFixed(1), label: 'Stunden diese Woche'),
                      _StatCard(icon: Icons.list_alt, color: Colors.blue, value: '$_gesamtBaustellen', label: 'Baustellen gesamt'),
                      _StatCard(icon: Icons.photo_camera, color: Colors.purple, value: '$_fotosGesamt', label: 'Fotos gesamt'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildKalender(),
                  const SizedBox(height: 20),
                  const Text('Module & Verwaltung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Erweitertes Modul-Grid (10 Module)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _DashboardTile(
                        icon: Icons.location_on,
                        label: 'Projekte / Baustellen',
                        subtitle: '$_gesamtBaustellen Baustellen',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BaustellenListPage()),
                          );
                        },
                      ),
                      _DashboardTile(
                        icon: Icons.people,
                        label: 'Kunden',
                        subtitle: '$_kundenAnzahl Kunden',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KundenPage())),
                      ),
                      _DashboardTile(
                        icon: Icons.badge,
                        label: 'Mitarbeiter',
                        subtitle: '$_mitarbeiterAnzahl aktiv',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MitarbeiterPage())),
                      ),
                      _DashboardTile(
                        icon: Icons.access_time,
                        label: 'Zeiterfassung',
                        subtitle: 'Stunden & Erfassung',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ZeiterfassungPage()),
                          );
                        },
                      ),
                      _DashboardTile(
                        icon: Icons.photo_camera,
                        label: 'Fotos',
                        subtitle: '$_fotosGesamt Aufnahmen',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BaustelleFuerFotosPage()),
                          );
                        },
                      ),
                      _DashboardTile(
                        icon: Icons.assessment,
                        label: 'Berichte',
                        subtitle: 'Tages- & Aufmassberichte',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BerichtePage())),
                      ),
                      _DashboardTile(
                        icon: Icons.task_alt,
                        label: 'Aufgaben',
                        subtitle: '$_offeneAufgaben offene Tasks',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AufgabenPage())),
                      ),
                      _DashboardTile(
                        icon: Icons.handyman,
                        label: 'Maschinen',
                        subtitle: '$_aktiveMaschinen Geräte',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MaschinenPage())),
                      ),
                      _DashboardTile(
                        icon: Icons.folder_shared,
                        label: 'Dokumente',
                        subtitle: '$_dokumenteAnzahl Dateien',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DokumentePage())),
                      ),
                      _DashboardTile(
                        icon: Icons.chat,
                        label: 'Nachrichten',
                        subtitle: '$_ungeleseneNachrichten neu',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NachrichtenPage())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
// BAUSTELLENLISTE
// ─────────────────────────────────────────────

class BaustellenListPage extends StatefulWidget {
  const BaustellenListPage({super.key});

  @override
  State<BaustellenListPage> createState() => _BaustellenListPageState();
}

class _BaustellenListPageState extends State<BaustellenListPage> {
  List<Map<String, dynamic>> _baustellen = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const _statusOptionen = ['offen', 'in Arbeit', 'fertig'];

  @override
  void initState() {
    super.initState();
    _loadBaustellen();
  }

  Future<void> _loadBaustellen() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await supabase
          .from('baustellen')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _baustellen = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'offen':
        return Colors.orange;
      case 'in Arbeit':
        return Colors.blue;
      case 'fertig':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _baustelleDialog({Map<String, dynamic>? bestehend}) async {
    final nameController =
        TextEditingController(text: bestehend?['name'] ?? '');
    final adresseController =
        TextEditingController(text: bestehend?['adresse'] ?? '');
    final kundeController =
        TextEditingController(text: bestehend?['kunde'] ?? '');
    String status = bestehend?['status'] ?? 'offen';
    bool isSaving = false;

    final istBearbeitung = bestehend != null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                  istBearbeitung ? 'Baustelle bearbeiten' : 'Neue Baustelle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name der Baustelle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: adresseController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: kundeController,
                      decoration: const InputDecoration(
                        labelText: 'Kunde',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: _statusOptionen.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => status = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bitte einen Namen eingeben')),
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          try {
                            final werte = {
                              'name': nameController.text.trim(),
                              'adresse': adresseController.text.trim().isEmpty
                                  ? null
                                  : adresseController.text.trim(),
                              'kunde': kundeController.text.trim().isEmpty
                                  ? null
                                  : kundeController.text.trim(),
                              'status': status,
                            };

                            if (istBearbeitung) {
                              await supabase
                                  .from('baustellen')
                                  .update(werte)
                                  .eq('id', bestehend['id']);
                            } else {
                              await supabase.from('baustellen').insert(werte);
                            }

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            await _loadBaustellen();
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Fehler: $e')),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(istBearbeitung ? 'Speichern' : 'Anlegen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loeschen(String id) async {
    await supabase.from('baustellen').delete().eq('id', id);
    await _loadBaustellen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baustellen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBaustellen,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _baustelleDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Neue Baustelle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _baustellen.isEmpty
                  ? const Center(child: Text('Noch keine Baustellen vorhanden'))
                  : RefreshIndicator(
                      onRefresh: _loadBaustellen,
                      child: ListView.builder(
                        itemCount: _baustellen.length,
                        itemBuilder: (context, index) {
                          final b = _baustellen[index];
                          return Dismissible(
                            key: ValueKey(b['id']),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Baustelle löschen?'),
                                  content: Text(
                                      'Alle zugehörigen Zeiten und Fotos zu "${b['name']}" werden ebenfalls gelöscht.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Abbrechen'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text('Löschen'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => _loeschen(b['id']),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(b['name'] ?? ''),
                                subtitle: Text(
                                  '${b['adresse'] ?? ''}\nKunde: ${b['kunde'] ?? '-'}',
                                ),
                                isThreeLine: true,
                                trailing: Chip(
                                  label: Text(b['status'] ?? ''),
                                  backgroundColor:
                                      _statusColor(b['status'] ?? '')
                                          .withOpacity(0.2),
                                ),
                                onTap: () =>
                                    _baustelleDialog(bestehend: b),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─────────────────────────────────────────────
// ZEITERFASSUNG
// ─────────────────────────────────────────────

class ZeiterfassungPage extends StatefulWidget {
  const ZeiterfassungPage({super.key});

  @override
  State<ZeiterfassungPage> createState() => _ZeiterfassungPageState();
}

class _ZeiterfassungPageState extends State<ZeiterfassungPage> {
  List<Map<String, dynamic>> _eintraege = [];
  List<Map<String, dynamic>> _baustellenListe = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    setState(() => _isLoading = true);

    final userId = supabase.auth.currentUser!.id;

    final data = await supabase
        .from('zeiterfassung')
        .select('*, baustellen(name, kunde)')
        .eq('user_id', userId)
        .order('start_zeit', ascending: false)
        .limit(50);

    final baustellen = await supabase
        .from('baustellen')
        .select('id, name, kunde')
        .order('name');

    setState(() {
      _eintraege = List<Map<String, dynamic>>.from(data);
      _baustellenListe = List<Map<String, dynamic>>.from(baustellen);
      _isLoading = false;
    });
  }

  String _dauerText(DateTime start, DateTime ende) {
    final diff = ende.difference(start);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return '${h}h ${m}min';
  }

  String _formatDatum(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}.${local.month}.${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _neuerEintragDialog() async {
    DateTime datum = DateTime.now();
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay ende = const TimeOfDay(hour: 16, minute: 0);
    final notizController = TextEditingController();
    String? baustelleId;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Arbeitszeit eintragen'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: baustelleId,
                      decoration: const InputDecoration(
                        labelText: 'Baustelle',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Bitte wählen'),
                      isExpanded: true,
                      items: _baustellenListe.map((b) {
                        return DropdownMenuItem<String>(
                          value: b['id'] as String,
                          child: Text(
                            '${b['name']} (${b['kunde'] ?? "-"})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => baustelleId = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Datum'),
                      subtitle: Text(
                          '${datum.day}.${datum.month}.${datum.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final gewaehlt = await showDatePicker(
                          context: context,
                          initialDate: datum,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (gewaehlt != null) {
                          setDialogState(() => datum = gewaehlt);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start'),
                      subtitle: Text(start.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final gewaehlt = await showTimePicker(
                          context: context,
                          initialTime: start,
                        );
                        if (gewaehlt != null) {
                          setDialogState(() => start = gewaehlt);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Ende'),
                      subtitle: Text(ende.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final gewaehlt = await showTimePicker(
                          context: context,
                          initialTime: ende,
                        );
                        if (gewaehlt != null) {
                          setDialogState(() => ende = gewaehlt);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notizController,
                      decoration: const InputDecoration(
                        labelText: 'Notiz (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (baustelleId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bitte eine Baustelle wählen')),
                            );
                            return;
                          }

                          final startDateTime = DateTime(
                            datum.year,
                            datum.month,
                            datum.day,
                            start.hour,
                            start.minute,
                          );
                          final endeDateTime = DateTime(
                            datum.year,
                            datum.month,
                            datum.day,
                            ende.hour,
                            ende.minute,
                          );

                          if (!endeDateTime.isAfter(startDateTime)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Ende muss nach Start liegen')),
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          try {
                            await supabase.from('zeiterfassung').insert({
                              'user_id': supabase.auth.currentUser!.id,
                              'baustelle_id': baustelleId,
                              'start_zeit': startDateTime.toIso8601String(),
                              'end_zeit': endeDateTime.toIso8601String(),
                              'notiz': notizController.text.trim().isEmpty
                                  ? null
                                  : notizController.text.trim(),
                            });

                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            await _laden();
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Fehler: $e')),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Speichern'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loeschen(String id) async {
    await supabase.from('zeiterfassung').delete().eq('id', id);
    await _laden();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zeiterfassung')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _baustellenListe.isEmpty ? null : _neuerEintragDialog,
        icon: const Icon(Icons.add),
        label: const Text('Eintragen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _baustellenListe.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Es gibt noch keine Baustellen. Bitte zuerst eine Baustelle anlegen.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _eintraege.isEmpty
                  ? const Center(child: Text('Noch keine Einträge'))
                  : RefreshIndicator(
                      onRefresh: _laden,
                      child: ListView.builder(
                        itemCount: _eintraege.length,
                        itemBuilder: (context, index) {
                          final e = _eintraege[index];
                          final start = DateTime.parse(e['start_zeit']);
                          final ende = DateTime.parse(e['end_zeit']);
                          final baustelle = e['baustellen'];
                          final baustelleName =
                              baustelle != null ? baustelle['name'] : '-';
                          final kunde =
                              baustelle != null ? baustelle['kunde'] : null;

                          return Dismissible(
                            key: ValueKey(e['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _loeschen(e['id']),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(
                                  '$baustelleName${kunde != null ? " · $kunde" : ""}'),
                              subtitle: Text(
                                '${_formatDatum(start)}\n'
                                'Dauer: ${_dauerText(start, ende)}'
                                '${e['notiz'] != null ? ' · ${e['notiz']}' : ''}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

// ─────────────────────────────────────────────
// FOTOS: BAUSTELLE AUSWÄHLEN
// ─────────────────────────────────────────────

class BaustelleFuerFotosPage extends StatefulWidget {
  const BaustelleFuerFotosPage({super.key});

  @override
  State<BaustelleFuerFotosPage> createState() =>
      _BaustelleFuerFotosPageState();
}

class _BaustelleFuerFotosPageState extends State<BaustelleFuerFotosPage> {
  List<Map<String, dynamic>> _baustellen = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    setState(() => _isLoading = true);
    final data = await supabase
        .from('baustellen')
        .select()
        .order('name');
    setState(() {
      _baustellen = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fotos - Baustelle wählen')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _baustellen.isEmpty
              ? const Center(child: Text('Noch keine Baustellen vorhanden'))
              : ListView.builder(
                  itemCount: _baustellen.length,
                  itemBuilder: (context, index) {
                    final b = _baustellen[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(b['name'] ?? ''),
                      subtitle: Text(b['kunde'] ?? '-'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FotoGaleriePage(
                              baustelleId: b['id'],
                              baustelleName: b['name'] ?? '',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// ─────────────────────────────────────────────
// FOTO-GALERIE EINER BAUSTELLE
// ─────────────────────────────────────────────

class FotoGaleriePage extends StatefulWidget {
  final String baustelleId;
  final String baustelleName;

  const FotoGaleriePage({
    super.key,
    required this.baustelleId,
    required this.baustelleName,
  });

  @override
  State<FotoGaleriePage> createState() => _FotoGaleriePageState();
}

class _FotoGaleriePageState extends State<FotoGaleriePage> {
  List<Map<String, dynamic>> _fotos = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    setState(() => _isLoading = true);
    final data = await supabase
        .from('fotos')
        .select()
        .eq('baustelle_id', widget.baustelleId)
        .order('created_at', ascending: false);
    setState(() {
      _fotos = List<Map<String, dynamic>>.from(data);
      _isLoading = false;
    });
  }

  String _publicUrl(String path) {
    return supabase.storage.from('fotos').getPublicUrl(path);
  }

  Future<void> _fotoHochladen() async {
    final picker = ImagePicker();
    final XFile? datei = await picker.pickImage(source: ImageSource.gallery);

    if (datei == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await datei.readAsBytes();
      final dateiname =
          '${widget.baustelleId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('fotos').uploadBinary(
            dateiname,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      await supabase.from('fotos').insert({
        'baustelle_id': widget.baustelleId,
        'user_id': supabase.auth.currentUser!.id,
        'storage_path': dateiname,
      });

      await _laden();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hochladen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _fotoLoeschen(Map<String, dynamic> foto) async {
    final bestaetigt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foto löschen?'),
        content: const Text('Dieser Vorgang kann nicht rückgängig gemacht werden.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (bestaetigt != true) return;

    try {
      await supabase.storage.from('fotos').remove([foto['storage_path']]);
      await supabase.from('fotos').delete().eq('id', foto['id']);
      await _laden();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fotos: ${widget.baustelleName}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _fotoHochladen,
        icon: _isUploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_a_photo),
        label: Text(_isUploading ? 'Lädt hoch...' : 'Foto hinzufügen'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _fotos.isEmpty
              ? const Center(child: Text('Noch keine Fotos vorhanden'))
              : RefreshIndicator(
                  onRefresh: _laden,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _fotos.length,
                    itemBuilder: (context, index) {
                      final foto = _fotos[index];
                      final url = _publicUrl(foto['storage_path']);
                      return GestureDetector(
                        onLongPress: () => _fotoLoeschen(foto),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            },
                            errorBuilder: (context, error, stack) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─────────────────────────────────────────────
// ZUSÄTZLICHE MODUL-SEITEN
// ─────────────────────────────────────────────

class KundenPage extends StatelessWidget {
  const KundenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kundenverwaltung')),
      body: ListView(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.person), title: Text('Stadt Dortmund'), subtitle: Text('Öffentliche Auftraggeber'))),
          Card(child: ListTile(leading: Icon(Icons.person), title: Text('Bauunternehmen Schmidt'), subtitle: Text('Gewerblicher Kunde'))),
          Card(child: ListTile(leading: Icon(Icons.person), title: Text('Privatkunden (Gesamt)'), subtitle: Text('10 hinterlegte Kontakte'))),
        ],
      ),
    );
  }
}

class MaschinenPage extends StatelessWidget {
  const MaschinenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maschinen & Geräte')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.handyman), title: Text('Mini-Bagger Bobcat'), subtitle: Text('Status: Einsatzbereit'))),
          Card(child: ListTile(leading: Icon(Icons.handyman), title: Text('Radlader Wacker'), subtitle: Text('Status: Auf Baustelle A'))),
          Card(child: ListTile(leading: Icon(Icons.handyman), title: Text('Rüttelplatte Compactor'), subtitle: Text('Status: Wartung fällig'))),
        ],
      ),
    );
  }
}

class MitarbeiterPage extends StatelessWidget {
  const MitarbeiterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mitarbeiter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.badge), title: Text('René Pincus'), subtitle: Text('Inhaber / Vorarbeiter'))),
          Card(child: ListTile(leading: Icon(Icons.badge), title: Text('Team Mitglied 1'), subtitle: Text('Landschaftsgärtner'))),
          Card(child: ListTile(leading: Icon(Icons.badge), title: Text('Team Mitglied 2'), subtitle: Text('Helfer'))),
        ],
      ),
    );
  }
}

class AufgabenPage extends StatelessWidget {
  const AufgabenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aufgaben')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.task_alt), title: Text('Baumschnitt Dortmund-Mitte'), subtitle: Text('Priorität: Hoch'))),
          Card(child: ListTile(leading: Icon(Icons.task_alt), title: Text('Materialbestellung Rindenmulch'), subtitle: Text('Priorität: Mittel'))),
          Card(child: ListTile(leading: Icon(Icons.task_alt), title: Text('Wartung Heckenschere'), subtitle: Text('Priorität: Niedrig'))),
        ],
      ),
    );
  }
}

class BerichtePage extends StatelessWidget {
  const BerichtePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berichte & Aufmass')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.assessment), title: Text('Tagesbericht 03.08.2026'), subtitle: Text('Baustelle Westfalenpark'))),
          Card(child: ListTile(leading: Icon(Icons.assessment), title: Text('Aufmass Baumpflege'), subtitle: Text('Kunde Stadt Dortmund'))),
        ],
      ),
    );
  }
}

class DokumentePage extends StatelessWidget {
  const DokumentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokumente & Dateien')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.folder_shared), title: Text('Arbeitssicherheit & Zertifikate'), subtitle: Text('PDF • 4 MB'))),
          Card(child: ListTile(leading: Icon(Icons.folder_shared), title: Text('AGB und Vorlagen'), subtitle: Text('PDF • 1.2 MB'))),
        ],
      ),
    );
  }
}

class NachrichtenPage extends StatelessWidget {
  const NachrichtenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nachrichten & Chat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.chat), title: Text('Team-Gruppe Baustelle'), subtitle: Text('Neues Foto hochgeladen'))),
          Card(child: ListTile(leading: Icon(Icons.chat), title: Text('Rene (Büro)'), subtitle: Text('Stundenfreigabe erfolgt'))),
        ],
      ),
    );
  }
}

class EinstellungenPage extends StatelessWidget {
  const EinstellungenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(child: ListTile(leading: Icon(Icons.settings), title: Text('App-Version'), subtitle: Text('1.0.0 (Web)'))),
          Card(child: ListTile(leading: Icon(Icons.settings), title: Text('Supabase Verbindung'), subtitle: Text('Verbunden'))),
        ],
      ),
    );
  }
}
