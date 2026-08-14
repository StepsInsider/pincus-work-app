import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/joke_service.dart';

final jokeServiceProvider = Provider<JokeService>((ref) => const JokeService());
final randomJokeProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) => ref.read(jokeServiceProvider).fetchRandomJoke(),
);

class JokePage extends ConsumerWidget {
  const JokePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jokeAsync = ref.watch(randomJokeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Zufälliger Witz')),
      body: Center(
        child: jokeAsync.when(
          data: (j) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(j['setup'] ?? '—', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Text(j['punchline'] ?? '—', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => ref.refresh(randomJokeProvider),
                  child: const Text('Neuer Witz'),
                ),
              ],
            ),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (err, st) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fehler beim Laden: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(randomJokeProvider),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
