import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../screens/dashboard_screen.dart';
import '../../screens/leads_screen.dart';
import '../../screens/login_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    final onLogin = state.matchedLocation == '/login';

    if (!loggedIn && !onLogin) return '/login';
    if (loggedIn && onLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/leads', builder: (context, state) => const LeadsScreen()),
  ],
);
