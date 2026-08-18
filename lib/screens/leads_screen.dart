import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/lead.dart';
import '../providers/leads_provider.dart';

class LeadsScreen extends ConsumerWidget {
  const LeadsScreen({super.key});

  static const statuses = [
    'neu',
    'kontakt',
    'besichtigung',
    'angebot',
    'auftrag',
    'abgeschlossen',
    'verloren',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leadsNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Leads')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Fehler: $error')),
        data: (leads) => leads.isEmpty
            ? const Center(child: Text('Noch keine Leads vorhanden.'))
            : RefreshIndicator(
                onRefresh: () => ref.read(leadsNotifierProvider.notifier).loadLeads(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _LeadCard(lead: leads[index]),
                ),
              ),
      ),
    );
  }
}

class _LeadCard extends ConsumerWidget {
  const _LeadCard({required this.lead});

  final Lead lead;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(lead.contactName, style: Theme.of(context).textTheme.titleMedium)),
                DropdownButton<String>(
                  value: LeadsScreen.statuses.contains(lead.status) ? lead.status : 'neu',
                  items: LeadsScreen.statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(leadsNotifierProvider.notifier).updateStatus(lead.id, value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(lead.service),
            if (lead.city != null) Text(lead.city!),
            if (lead.phone != null) Text(lead.phone!),
            if (lead.email != null) Text(lead.email!),
            if (lead.description != null && lead.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(lead.description!),
            ],
            const SizedBox(height: 8),
            Text('Quelle: ${lead.source ?? 'unbekannt'} · Score: ${lead.leadScore}'),
          ],
        ),
      ),
    );
  }
}
