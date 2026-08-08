import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/baustelle_model.dart';

class BaustellenRepository {
  final SupabaseClient _supabase;

  BaustellenRepository(this._supabase);

  Future<List<Baustelle>> fetchBaustellen() async {
    final response = await _supabase
        .from('baustellen')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (data) => Baustelle.fromJson(
            Map<String, dynamic>.from(data),
          ),
        )
        .toList();
  }

  Future<Baustelle> createBaustelle(
    Baustelle baustelle,
  ) async {
    final response = await _supabase
        .from('baustellen')
        .insert(baustelle.toJson())
        .select()
        .single();

    return Baustelle.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<Baustelle> updateBaustelle(
    Baustelle baustelle,
  ) async {
    final response = await _supabase
        .from('baustellen')
        .update(baustelle.toJson())
        .eq('id', baustelle.id)
        .select()
        .single();

    return Baustelle.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  Future<void> deleteBaustelle(String id) async {
    await _supabase
        .from('baustellen')
        .delete()
        .eq('id', id);
  }
}
