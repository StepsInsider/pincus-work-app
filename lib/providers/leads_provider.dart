import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lead.dart';
import '../repositories/leads_repository.dart';

final leadsRepositoryProvider = Provider<LeadsRepository>((ref) {
  return LeadsRepository(Supabase.instance.client);
});

final leadsNotifierProvider =
    NotifierProvider<LeadsNotifier, AsyncValue<List<Lead>>>(LeadsNotifier.new);

class LeadsNotifier extends Notifier<AsyncValue<List<Lead>>> {
  late final LeadsRepository _repository;

  @override
  AsyncValue<List<Lead>> build() {
    _repository = ref.watch(leadsRepositoryProvider);
    Future.microtask(loadLeads);
    return const AsyncValue.loading();
  }

  Future<void> loadLeads() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _repository.fetchLeads());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _repository.updateStatus(id, status);
      await loadLeads();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
