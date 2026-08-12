import 'package:flutter/material.dart';

import '../features/ai/presentation/ai_chat_page.dart';
import 'customers_screen.dart';
import 'photo_screen.dart';
import 'services_screen.dart';
import 'team_screen.dart';
import 'time_tracking_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pincus Work – Innenansicht')),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1200
                ? 4
                : constraints.maxWidth >= 900
                    ? 3
                    : 2;
            return GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
  ) =>
      Card(
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
                Icon(icon, size: 48, color: color),
                const SizedBox(height: 12),
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
