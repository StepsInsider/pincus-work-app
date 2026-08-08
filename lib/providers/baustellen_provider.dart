import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/baustelle_model.dart';
import '../repositories/baustellen_repository.dart';

final baustellenRepositoryProvider =
    Provider<BaustellenRepository>((ref) {
  return BaustellenRepository(
    Supabase.instance.client,
  );
});

final baustellenNotifierProvider = NotifierProvider<
    BaustellenNotifier,
    AsyncValue<List<Baustelle>>>(
  BaustellenNotifier.new,
);

class BaustellenNotifier
    extends Notifier<AsyncValue<List<Baustelle>>> {
  late final BaustellenRepository _repository;

  @override
  AsyncValue<List<Baustelle>> build() {
    _repository = ref.watch(
      baustellenRepositoryProvider,
    );

    Future.microtask(loadBaustellen);

    return const AsyncValue.loading();
  }

  Future<void> loadBaustellen() async {
    state = const AsyncValue.loading();

    try {
      final data = await _repository.fetchBaustellen();

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addBaustelle(
    Baustelle baustelle,
  ) async {
    try {
      await _repository.createBaustelle(baustelle);
      await loadBaustellen();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBaustelle(
    Baustelle baustelle,
  ) async {
    try {
      await _repository.updateBaustelle(baustelle);
      await loadBaustellen();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteBaustelle(String id) async {
    try {
      await _repository.deleteBaustelle(id);
      await loadBaustellen();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
