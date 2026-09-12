import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/core_baustelle.dart';
import '../models/core_customer.dart';
import '../models/core_location.dart';
import '../providers/core_providers.dart';

class BaustellenScreen extends ConsumerStatefulWidget {
  const BaustellenScreen({super.key});

  @override
  ConsumerState<BaustellenScreen> createState() => _BaustellenScreenState();
}

class _BaustellenScreenState extends ConsumerState<BaustellenScreen> {
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
    ref.invalidate(coreBaustellenProvider);
    ref.invalidate(coreCustomersProvider);
    ref.invalidate(coreLocationsProvider);
    await Future.wait([
      ref.read(coreBaustellenProvider.future),
      ref.read(coreCustomersProvider.future),
      ref.read(coreLocationsProvider.future),
    ]);
  }

  Future<void> _showBaustelleDialog({CoreBaustelle? baustelle}) async {
    final title = TextEditingController(text: baustelle?.title ?? '');
    final clientName = TextEditingController(text: baustelle?.clientName ?? '');
    final address = TextEditingController(text: baustelle?.address ?? '');
    final budget = TextEditingController(text: baustelle?.budget?.toStringAsFixed(2) ?? '');
    DateTime? startDate = baustelle?.startDate;
    DateTime? endDate = baustelle?.endDate;
    String status = baustelle?.status ?? 'active';
    String? standortId = baustelle?.standortId;

    final customers = await ref.read(coreCustomersProvider.future);
    final locations = await ref.read(coreLocationsProvider.future);

    if (!mounted) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selectedLocation = locations.where((l) => l.id == standortId).firstOrNull;
          final selectedCustomer = selectedLocation == null
              ? null
              : customers.where((c) => c.id == selectedLocation.customerId).firstOrNull;

          return AlertDialog(
            title: Text(baustelle == null ? 'Baustelle anlegen' : 'Baustelle bearbeiten'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: title, decoration: const InputDecoration(labelText: 'Bezeichnung *')),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Aktiv')),
                        DropdownMenuItem(value: 'planned', child: Text('Geplant')),
                        DropdownMenuItem(value: 'completed', child: Text('Abgeschlossen')),
                        DropdownMenuItem(value: 'cancelled', child: Text('Abgebrochen')),
                      ],
                      onChanged: (value) => setDialogState(() => status = value ?? 'active'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      value: standortId,
                      decoration: const InputDecoration(labelText: 'Kunde / Standort'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('Kein Standort zugeordnet')),
                        ...locations.map((location) {
                          final customer = customers.where((c) => c.id == location.customerId).firstOrNull;
                          return DropdownMenuItem<String?>(
                            value: location.id,
                            child: Text(customer == null ? location.name : '${customer.name} – ${location.name}'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          standortId = value;
                          final location = locations.where((l) => l.id == value).firstOrNull;
                          final customer = location == null ? null : customers.where((c) => c.id == location.customerId).firstOrNull;
                          if (customer != null) clientName.text = customer.name;
                          if (location != null && location.addressLine.isNotEmpty) address.text = location.addressLine;
                        });
                      },
                    ),
                    if (selectedCustomer != null) ...[
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerLeft, child: Text('Kunde: ${selectedCustomer.name}')),
                    ],
                    const SizedBox(height: 8),
                    TextField(controller: clientName, decoration: const InputDecoration(labelText: 'Kunde (optional)')),
                    TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse (optional)')),
                    TextField(controller: budget, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Budget (€)')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _DateButton(label: 'Start', value: startDate, onPick: (value) => setDialogState(() => startDate = value))),
                        const SizedBox(width: 8),
                        Expanded(child: _DateButton(label: 'Ende', value: endDate, onPick: (value) => setDialogState(() => endDate = value))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Abbrechen')),
              FilledButton(
                onPressed: () async {
                  if (title.text.trim().isEmpty) return;
                  try {
                    final repo = ref.read(coreBaustelleRepositoryProvider);
                    final companyId = baustelle?.companyId ?? await repo.currentCompanyId();
                    if (companyId == null) throw Exception('Dem Benutzer ist noch kein Unternehmen zugeordnet.');
                    final parsedBudget = double.tryParse(budget.text.trim().replaceAll(',', '.'));
                    final location = locations.where((l) => l.id == standortId).firstOrNull;
                    final value = CoreBaustelle(
                      id: baustelle?.id ?? '',
                      companyId: companyId,
                      title: title.text.trim(),
                      clientName: clientName.text.trim().isEmpty ? null : clientName.text.trim(),
                      address: address.text.trim().isEmpty ? null : address.text.trim(),
                      status: status,
                      budget: parsedBudget,
                      startDate: startDate,
                      endDate: endDate,
                      standortId: location?.id,
                    );
                    if (baustelle == null) {
                      await repo.create(value);
                    } else {
                      await repo.update(baustelle.id, value.toMap());
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
          );
        },
      ),
    );

    for (final controller in [title, clientName, address, budget]) {
      controller.dispose();
    }
    if (saved == true) await _refresh();
  }

  Future<void> _delete(CoreBaustelle baustelle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Baustelle löschen?'),
        content: Text('„${baustelle.title}“ wird gelöscht.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(coreBaustelleRepositoryProvider).delete(baustelle.id);
      await _refresh();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Löschen fehlgeschlagen: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final baustellenAsync = ref.watch(coreBaustellenProvider);
    final customersAsync = ref.watch(coreCustomersProvider);
    final locationsAsync = ref.watch(coreLocationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baustellen'),
        actions: [
          IconButton(onPressed: _refresh, tooltip: 'Aktualisieren', icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () => _showBaustelleDialog(), tooltip: 'Baustelle anlegen', icon: const Icon(Icons.add_business_outlined)),
        ],
      ),
      body: baustellenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(message: 'Baustellen konnten nicht geladen werden: $error', onRetry: _refresh),
        data: (baustellen) => customersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(message: 'Kunden konnten nicht geladen werden: $error', onRetry: _refresh),
          data: (customers) => locationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorView(message: 'Standorte konnten nicht geladen werden: $error', onRetry: _refresh),
            data: (locations) {
              final customerById = {for (final c in customers) c.id: c};
              final locationById = {for (final l in locations) l.id: l};
              final filtered = baustellen.where((site) {
                if (_search.isEmpty) return true;
                final location = site.standortId == null ? null : locationById[site.standortId!];
                final customer = location == null ? null : customerById[location.customerId];
                final haystack = [site.title, site.clientName ?? '', site.address ?? '', site.status, customer?.name ?? '', location?.name ?? ''].join(' ').toLowerCase();
                return haystack.contains(_search);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Baustelle, Kunde oder Standort suchen',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isEmpty ? null : IconButton(onPressed: _searchController.clear, icon: const Icon(Icons.clear)),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('Keine Baustellen gefunden.'))
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final site = filtered[index];
                                final location = site.standortId == null ? null : locationById[site.standortId!];
                                final customer = location == null ? null : customerById[location.customerId];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(child: const Icon(Icons.construction_outlined)),
                                    title: Text(site.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text([
                                      if (customer != null) customer.name,
                                      if (location != null) location.name,
                                      if ((site.address ?? '').isNotEmpty) site.address!,
                                      _statusLabel(site.status),
                                    ].join(' · ')),
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') _showBaustelleDialog(baustelle: site);
                                        if (value == 'delete') _delete(site);
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                                        PopupMenuItem(value: 'delete', child: Text('Löschen')),
                                      ],
                                    ),
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
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'planned' => 'Geplant',
        'completed' => 'Abgeschlossen',
        'cancelled' => 'Abgebrochen',
        _ => 'Aktiv',
      };
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.label, required this.value, required this.onPick});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) onPick(picked);
        },
        icon: const Icon(Icons.calendar_today_outlined),
        label: Text(value == null ? label : '$label: ${value!.day.toString().padLeft(2, '0')}.${value!.month.toString().padLeft(2, '0')}.${value!.year}'),
      );
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
