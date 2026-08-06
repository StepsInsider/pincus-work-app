import 'package:flutter/material.dart';
import 'time_tracking_screen.dart';
import 'photo_screen.dart';
import 'services_screen.dart';
import 'team_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pincus Work – Innenansicht'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              'Zeiterfassung',
              Icons.timer,
              Colors.orange,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeTrackingScreen())),
            ),
            _buildDashboardCard(
              context,
              'Baustellen-Fotos',
              Icons.camera_alt,
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PhotoScreen())),
            ),
            _buildDashboardCard(
              context,
              'Projekte & Leistungen',
              Icons.assignment,
              Colors.green,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesScreen())),
            ),
            _buildDashboardCard(
              context,
              'Mitarbeiter / Team',
              Icons.people,
              Colors.purple,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeamScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
