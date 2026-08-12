import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _supabase = Supabase.instance.client;
  final _searchController = TextEditingController();

  List<Customer> _customers = [];
  Map<String, List<CustomerLocation>> _locations = {};
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(() {
      setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customerRows = await _supabase
          .from('kunden')
          .select(
            'id,name,firmenname,ansprechpartner,contact_person,phone,telefon,email,address,strasse,notes,company_id',
          )
          .order('name', ascending: true);
      final locationRows = await _supabase
          .from('standorte')
          .select('id,kunden_id,name,strasse,plz,ort,notizen,aktiv')
          .eq('aktiv', true)
          .order('name', ascending: true);

      final customers = (customerRows as List)
          .map((row) => Customer.fromMap(Map<String, dynamic>.from(row)))
          .toList();
      final locations = (locationRows as List)
          .map(
            (row) => CustomerLocation.fromMap(Map<String, dynamic>.from(row)),
          )
          .fold<Map<String, List<CustomerLocation>>>({}, (map, location) {
            map.putIfAbsent(location.customerId, () => []).add(location);
            return map;
          });

      if (!mounted) return;
      setState(() {
        _customers = customers;
        _locations = locations;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = 'Kunden und Standorte konnten nicht geladen werden: $error';
        _loading = false;
      });
    }
  }

  List<Customer> get _filteredCustomers {
    if (_search.isEmpty) return _customers;
    return _customers.where((customer) {
      final locations = _locations[customer.id] ?? const <CustomerLocation>[];
      final haystack = [
        customer.name,
        customer.contactPerson ?? '',
        customer.phone ?? '',
        customer.email ?? '',
        ...locations.map(
          (location) => '${location.name} ${location.addressLine}',
        ),
      ].join(' ').toLowerCase();
      return haystack.contains(_search);
    }).toList();
  }

  Future<void> _showCustomerDialog({Customer? customer}) async {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final contactController = TextEditingController(
      text: customer?.contactPerson ?? '',
    );
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final addressController = TextEditingController(
      text: customer?.address ?? '',
    );
    final notesController = TextEditingController(text: customer?.notes ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Kunde anlegen' : 'Kunde bearbeiten'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Kundenname *'),
                ),
                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Ansprechpartner',
                  ),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Adresse'),
                ),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notizen'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final userId = _supabase.auth.currentUser?.id;
                if (userId == null) throw Exception('Bitte zuerst anmelden.');
                final profile = await _supabase
                    .from('profiles')
                    .select('company_id')
                    .eq('id', userId)
                    .maybeSingle();
                final companyId =
                    profile?['company_id']?.toString() ?? customer?.companyId;
                if (customer == null && companyId == null) {
                  throw Exception(
                    'Dem Benutzer ist noch kein Unternehmen zugeordnet.',
                  );
                }
                final payload = <String, dynamic>{
                  'name': name,
                  'contact_person': contactController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'email': emailController.text.trim(),
                  'address': addressController.text.trim(),
                  'notes': notesController.text.trim(),
                };
                if (companyId != null) payload['company_id'] = companyId;
                if (customer == null) {
                  await _supabase.from('kunden').insert(payload);
                } else {
                  await _supabase
                      .from('kunden')
                      .update(payload)
                      .eq('id', customer.id);
                }
                if (context.mounted) Navigator.pop(context, true);
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Speichern fehlgeschlagen: $error')),
                  );
                }
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    nameController.dispose();
    contactController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    notesController.dispose();
    if (saved == true) await _loadCustomers();
  }

  Future<void> _showLocationDialog(
    Customer customer, {
    CustomerLocation? location,
  }) async {
    final nameController = TextEditingController(text: location?.name ?? '');
    final streetController = TextEditingController(
      text: location?.street ?? '',
    );
    final postcodeController = TextEditingController(
      text: location?.postcode ?? '',
    );
    final cityController = TextEditingController(text: location?.city ?? '');
    final notesController = TextEditingController(text: location?.notes ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          location == null ? 'Standort anlegen' : 'Standort bearbeiten',
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Kunde'),
                  child: Text(customer.name),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Standortname *',
                  ),
                ),
                TextField(
                  controller: streetController,
                  decoration: const InputDecoration(
                    labelText: 'Straße / Hausnummer',
                  ),
                ),
                TextField(
                  controller: postcodeController,
                  decoration: const InputDecoration(labelText: 'PLZ'),
                ),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'Ort'),
                ),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notizen'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final userId = _supabase.auth.currentUser?.id;
                if (userId == null) throw Exception('Bitte zuerst anmelden.');
                final profile = await _supabase
                    .from('profiles')
                    .select('company_id')
                    .eq('id', userId)
                    .maybeSingle();
                final companyId =
                    profile?['company_id']?.toString() ?? customer.companyId;
                if (companyId == null)
                  throw Exception(
                    'Dem Benutzer ist noch kein Unternehmen zugeordnet.',
                  );
                final payload = {
                  'company_id': companyId,
                  'kunden_id': customer.id,
                  'name': name,
                  'strasse': streetController.text.trim(),
                  'plz': postcodeController.text.trim(),
                  'ort': cityController.text.trim(),
                  'notizen': notesController.text.trim(),
                  'aktiv': true,
                };
                if (location == null) {
                  await _supabase.from('standorte').insert(payload);
                } else {
                  await _supabase
                      .from('standorte')
                      .update(payload)
                      .eq('id', location.id);
                }
                if (context.mounted) Navigator.pop(context, true);
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Speichern fehlgeschlagen: $error')),
                  );
                }
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    nameController.dispose();
    streetController.dispose();
    postcodeController.dispose();
    cityController.dispose();
    notesController.dispose();
    if (saved == true) await _loadCustomers();
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kunde löschen?'),
        content: Text(
          '„${customer.name}“ und die zugehörigen Standorte werden gelöscht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _supabase.from('kunden').delete().eq('id', customer.id);
      await _loadCustomers();
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Löschen fehlgeschlagen: $error')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filteredCustomers;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunden & Standorte'),
        actions: [
          IconButton(
            onPressed: _loadCustomers,
            tooltip: 'Aktualisieren',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _showCustomerDialog(),
            tooltip: 'Kunde anlegen',
            icon: const Icon(Icons.person_add_alt_1),
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
                      onPressed: _loadCustomers,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Erneut versuchen'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Kunde oder Standort suchen',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              onPressed: _searchController.clear,
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: customers.isEmpty
                      ? const Center(child: Text('Keine Kunden gefunden.'))
                      : RefreshIndicator(
                          onRefresh: _loadCustomers,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: customers.length,
                            itemBuilder: (context, index) {
                              final customer = customers[index];
                              final locations =
                                  _locations[customer.id] ??
                                  const <CustomerLocation>[];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      customer.name.isEmpty
                                          ? '?'
                                          : customer.name
                                                .substring(0, 1)
                                                .toUpperCase(),
                                    ),
                                  ),
                                  title: Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${locations.length} Standort${locations.length == 1 ? '' : 'e'}',
                                  ),
                                  children: [
                                    ...locations.map(
                                      (location) => ListTile(
                                        contentPadding: const EdgeInsets.only(
                                          left: 72,
                                          right: 16,
                                        ),
                                        leading: const Icon(
                                          Icons.location_on_outlined,
                                        ),
                                        title: Text(location.name),
                                        subtitle: Text(
                                          location.addressLine.isEmpty
                                              ? 'Adresse noch nicht hinterlegt'
                                              : location.addressLine,
                                        ),
                                        trailing: IconButton(
                                          onPressed: () => _showLocationDialog(
                                            customer,
                                            location: location,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(
                                        left: 72,
                                        right: 16,
                                      ),
                                      leading: const Icon(
                                        Icons.add_location_alt_outlined,
                                      ),
                                      title: const Text('Standort hinzufügen'),
                                      onTap: () =>
                                          _showLocationDialog(customer),
                                    ),
                                    const Divider(height: 1),
                                    ButtonBar(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _showCustomerDialog(
                                            customer: customer,
                                          ),
                                          icon: const Icon(Icons.edit_outlined),
                                          label: const Text('Kunde bearbeiten'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () =>
                                              _deleteCustomer(customer),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          label: const Text('Löschen'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Kunde'),
      ),
    );
  }
}
