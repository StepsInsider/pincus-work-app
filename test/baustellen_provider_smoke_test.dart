import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincus_work/providers/baustellen_provider.dart';
import 'package:pincus_work/repositories/baustellen_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('baustellen repository provider supports dependency injection', () {
    final repository = BaustellenRepository(
      SupabaseClient('http://localhost:54321', 'test-publishable-key'),
    );
    final container = ProviderContainer(
      overrides: [
        baustellenRepositoryProvider.overrideWith((ref) => repository),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(baustellenRepositoryProvider), same(repository));
  });
}
