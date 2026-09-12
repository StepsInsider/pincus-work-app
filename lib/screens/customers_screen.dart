import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/core_customer.dart';
import '../models/core_location.dart';
import '../providers/core_providers.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(coreCustomersProvider);
    ref.invalidate(coreLocationsProvider);
    await Future.wait([
      ref.read(coreCustomersProvider.future),
      ref.read(coreLocationsProvider.future),
    ]);
  }

  Future<void> _showCustomerDialog({CoreCustomer? customer}) async {
    final name = TextEditingController(text: customer?.name ?? '');
    final contact = TextEditingController(text: customer?.contactPerson ?? '');
    final phone = TextEditingController(text: customer?.phone ?? '');
    final email = TextEditingController(text: customer?.email ?? '');
    final address = TextEditingController(text: customer?.address ?? '');
    final notes = TextEditingController(text: customer?.notes ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(customer == null ? 'Kunde anlegen' : 'Kunde bearbeiten'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Kundenname *')),
                TextField(controller: contact, decoration: const InputDecoration(labelText: 'Ansprechpartner')),
                TextField(controller: phone, decoration: const InputDecoration(labelText: 'Telefon')),
                TextField(controller: email, decoration: const InputDecoration(labelText: 'E-Mail')),
                TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse')),
                TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notizen')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              try {
                final repo = ref.read(coreCustomerRepositoryProvider);
                final companyId = customer?.companyId ?? await repo.currentCompanyId();
                if (companyId == null) throw Exception('Dem Benutzer ist noch kein Unternehmen zugeordnet.');

                if (customer == null) {
                  await repo.create(CoreCustomer(
                    id: '',
                    companyId: companyId,
                    name: name.text.trim(),
                    contactPerson: contact.text.trim().isEmpty ? null : contact.text.trim(),
                    phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
                    email: email.text.trim().isEmpty ? null : email.text.trim(),
                    address: address.text.trim().isEmpty ? null : address.text.trim(),
                    notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                  ));
                } else {
                  await repo.update(customer.id, {
                    'name': name.text.trim(),
                    'contact_person': contact.text.trim(),
                    'phone': phone.text.trim(),
                    'email': email.text.trim(),
                    'address': address.text.trim(),
                    'notes': notes.text.trim(),
                  });
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Speichern fehlgeschlagen: $error')));
                }
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    for (final controller in [name, contact, phone, email, address, notes]) {
      controller.dispose();
    }
    if (saved == true) await _refresh();
  }

  Future<void> _showLocationDialog(CoreCustomer customer, {CoreLocation? location}) async {
    final name = TextEditingController(text: location?.name ?? '');
    final street = TextEditingController(text: location?.street ?? '');
    final postcode = TextEditingController(text: location?.postcode ?? '');
    final city = TextEditingController(text: location?.city ?? '');
    final notes = TextEditingController(text: location?.notes ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(location == null ? 'Standort anlegen' : 'Standort bearbeiten'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputDecorator(decoration: const InputDecoration(labelText: 'Kunde'), child: Text(customer.name)),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Standortname *')),
                TextField(controller: street, decoration: const InputDecoration(labelText: 'Straße / Hausnummer')),
                TextField(controller: postcode, decoration: const InputDecoration(labelText: 'PLZ')),
                TextField(controller: city, decoration: const InputDecoration(labelText: 'Ort')),
                TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Notizen')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () async {
              if (name.text.trim().isEmpty) return;
              try {
                final repo = ref.read(coreLocationRepositoryProvider);
                final value = CoreLocation(
                  id: location?.id ?? '',
                  companyId: customer.companyId,
                  customerId: customer.id,
                  name: name.text.trim(),
                  street: street.text.trim().isEmpty ? null : street.text.trim(),
                  postcode: postcode.text.trim().isEmpty ? null : postcode.text.trim(),
                  city: city.text.trim().isEmpty ? null : city.text.trim(),
                  notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                  active: true,
                );
                if (location == null) {
                  await repo.create(value);
                } else {
                  await repo.update(location.id, value.toMap());
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext, true);
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Speichern fehlgeschlagen: $error')));
                }
              }
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    for (final controller in [name, street, postcode, city, notes]) {
      controller.dispose();
    }
    if (saved == true) await _refresh();
  }

  Future<void> _deleteCustomer(CoreCustomer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Kunde löschen?'),
        content: Text('„${customer.name}“ und die zugehörigen Standorte werden gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(coreCustomerRepositoryProvider).delete(customer.id);
      await _refresh();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Löschen fehlgeschlagen: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(coreCustomersProvider);
    final locationsAsync = ref.watch(coreLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kunden & Standorte'),
        actions: [
          IconButton(onPressed: _refresh, tooltip: 'Aktualisieren', icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () => _showCustomerDialog(), tooltip: 'Kunde anlegen', icon: const Icon(Icons.person_add_alt_1)),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(message: 'Kunden konnten nicht geladen werden: $error', onRetry: _refresh),
        data: (customers) => locationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(message: 'Standorte konnten nicht geladen werden: $error', onRetry: _refresh),
          data: (locations) {
            final byCustomer = <String, List<CoreLocation>>{};
            for (final location in locations) {
              byCustomer.putIfAbsent(location.customerId, () => []).add(location);
            }
            final filtered = customers.where((customer) {
              if (_search.isEmpty) return true;
              final customerLocations = byCustomer[customer.id] ?? const <CoreLocation>[];
              final haystack = [
                customer.name,
                customer.contactPerson ?? '',
                customer.phone ?? '',
                customer.email ?? '',
                ...customerLocations.map((l) => '${l.name} ${l.addressLine}'),
              ].join(' ').toLowerCase();
              return haystack.contains(_search);
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Kunde oder Standort suchen',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.isEmpty ? null : IconButton(onPressed: _searchController.clear, icon: const Icon(Icons.clear)),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('Keine Kunden gefunden.'))
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final customer = filtered[index];
                              final customerLocations = byCustomer[customer.id] ?? const <CoreLocation>[];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                child: ExpansionTile(
                                  leading: CircleAvatar(child: Text(customer.name.isEmpty ? '?' : customer.name.substring(0, 1).toUpperCase())),
                                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${customerLocations.length} Standort${customerLocations.length == 1 ? '' : 'e'}'),
                                  children: [
                                    ...customerLocations.map((location) => ListTile(
                                      contentPadding: const EdgeInsets.only(left: 72, right: 16),
                                      leading: const Icon(Icons.location_on_outlined),
                                      title: Text(location.name),
                                      subtitle: Text(location.addressLine.isEmpty ? 'Adresse noch nicht hinterlegt' : location.addressLine),
                                      trailing: IconButton(onPressed: () => _showLocationDialog(customer, location: location), icon: const Icon(Icons.edit_outlined)),
                                    )),
                                    ListTile(
                                      contentPadding: const EdgeInsets.only(left: 72, right: 16),
                                      leading: const Icon(Icons.add_location_alt_outlined),
                                      title: const Text('Standort hinzufügen'),
                                      onTap: () => _showLocationDialog(customer),
                                    ),
                                    const Divider(height: 1),
                                    OverflowBar(children: [
                                      TextButton.icon(onPressed: () => _showCustomerDialog(customer: customer), icon: const Icon(Icons.edit_outlined), label: const Text('Bearbeiten')),
                                      TextButton.icon(onPressed: () => _deleteCustomer(customer), icon: const Icon(Icons.delete_outline), label: const Text('Löschen')),
                                    ]),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Erneut versuchen')),
            ],
          ),
        ),
      );
}
