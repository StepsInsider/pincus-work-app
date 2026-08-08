import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_config.dart';

abstract final class SupabaseConfig {
  static Future<void> initialize() async {
    AppConfig.validate();

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }
}
