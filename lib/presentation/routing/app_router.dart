import 'package:go_router/go_router.dart';

import '../../screens/dashboard_screen.dart';
import '../../screens/leads_screen.dart';
import '../../features/jokes/presentation/joke_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/leads',
      builder: (context, state) => const LeadsScreen(),
    ),
    GoRoute(
      path: '/joke',
      builder: (context, state) => const JokePage(),
    ),
  ],
);
