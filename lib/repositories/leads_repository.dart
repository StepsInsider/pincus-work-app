import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lead.dart';

class LeadsRepository {
  LeadsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Lead>> fetchLeads({String? status}) async {
    var query = _client.from('leads').select().order('created_at', ascending: false);
    if (status != null && status.isNotEmpty) {
      query = query.eq('status', status);
    }

    final rows = await query;
    return rows.map(Lead.fromMap).toList(growable: false);
  }

  Future<void> updateStatus(String id, String status) async {
    await _client.from('leads').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}
