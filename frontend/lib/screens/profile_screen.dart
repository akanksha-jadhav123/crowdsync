import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_data_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar & Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentCyan.withOpacity(0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(user?.name ?? 'Guest', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Seat Info
          _sectionTitle('Seat Assignment'),
          _infoCard(Icons.event_seat_rounded, 'Seat', user?.seatDisplay ?? 'Not assigned', AppTheme.accentCyan),
          const SizedBox(height: 20),

          // Stats
          _sectionTitle('Activity'),
          Row(
            children: [
              _statBox('Orders', '${data.orders.length}', AppTheme.accentAmber),
              const SizedBox(width: 12),
              _statBox('Alerts', '${data.emergencies.length}', AppTheme.accentRed),
              const SizedBox(width: 12),
              _statBox('Notifs', '${data.notifications.length}', AppTheme.accentPurple),
            ],
          ),
          const SizedBox(height: 20),

          // Info Items
          _sectionTitle('Account'),
          _infoCard(Icons.phone_outlined, 'Phone', user?.phone.isNotEmpty == true ? user!.phone : 'Not set', AppTheme.accentGreen),
          const SizedBox(height: 8),
          _infoCard(Icons.badge_outlined, 'Role', user?.role.toUpperCase() ?? 'USER', AppTheme.accentBlue),
          const SizedBox(height: 28),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.logout, color: AppTheme.accentRed),
              label: Text('Sign Out', style: GoogleFonts.inter(color: AppTheme.accentRed, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('CrowdSync v1.0.0', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
              Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
