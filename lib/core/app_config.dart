/// Build-time configuration for the public Supabase client.
///
/// Supply both values with `--dart-define` when building or running the app.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static void validate() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw StateError(
        'Missing Supabase configuration. Pass SUPABASE_URL and '
        'SUPABASE_PUBLISHABLE_KEY using --dart-define.',
      );
    }
  }
}
