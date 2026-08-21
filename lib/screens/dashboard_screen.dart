import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/ai/presentation/ai_chat_page.dart';
import 'customers_screen.dart';
import 'leads_screen.dart';
import 'photo_screen.dart';
import 'services_screen.dart';
import 'team_screen.dart';
import 'time_tracking_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: 72,
          titleSpacing: 16,
          title: Row(
            children: [
              Image.asset('assets/images/logo.png', height: 48),
              const SizedBox(width: 16),
              const Expanded(child: Text('Pincus Work – Innenansicht')),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Abmelden',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1400
                ? 4
                : constraints.maxWidth >= 1000
                    ? 3
                    : constraints.maxWidth >= 600
                        ? 2
                        : 1;
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 2.8 : 1.25,
              children: [
                _card(context, 'Kunden & Standorte', Icons.business_outlined,
                    Colors.indigo, const CustomersScreen()),
                _card(context, 'Zeiterfassung', Icons.timer_outlined,
                    Colors.orange, const TimeTrackingScreen()),
                _card(context, 'Baustellen-Fotos', Icons.camera_alt_outlined,
                    Colors.blue, const PhotoScreen()),
                _card(context, 'Projekte & Leistungen', Icons.assignment_outlined,
                    Colors.green, const ServicesScreen()),
                _card(context, 'Mitarbeiter / Team', Icons.people_outline,
                    Colors.purple, const TeamScreen()),
                _card(context, 'Leads', Icons.trending_up_outlined,
                    Colors.deepOrange, const LeadsScreen()),
                _card(context, 'Pincus KI', Icons.auto_awesome_outlined,
                    Colors.teal, const AiChatPage()),
              ],
            );
          },
        ),
      );

  Widget _card(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    Widget destination,
  ) => Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => destination),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 44, color: color),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
}
