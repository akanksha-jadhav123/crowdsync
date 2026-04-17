import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/app_data_provider.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accentCyan,
          onRefresh: () => context.read<AppDataProvider>().refreshAll(),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.stadium, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CrowdSync',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            Consumer<AuthProvider>(
                              builder: (_, auth, __) => Text(
                                'Welcome, ${auth.user?.name.split(' ').first ?? 'Fan'}!',
                                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _iconBtn(Icons.notifications_outlined, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                      }, badge: context.watch<AppDataProvider>().unreadNotifications),
                      const SizedBox(width: 8),
                      _iconBtn(Icons.person_outline, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                      }),
                    ],
                  ),
                ),
              ),

              // Live Stats
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text('Live Overview', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              SliverToBoxAdapter(
                child: Consumer<AppDataProvider>(
                  builder: (_, data, __) {
                    final stats = data.crowdStats;
                    final qStats = data.queueStats;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: Row(
                        children: [
                          _statCard('Crowd', '${stats?['avgDensity'] ?? 0}%', Icons.people_rounded,
                              AppTheme.getDensityColor(stats?['overallLevel'] ?? 'low')),
                          const SizedBox(width: 12),
                          _statCard('Avg Wait', '${qStats?['avgWaitMinutes'] ?? 0}m', Icons.timer_rounded, AppTheme.accentAmber),
                          const SizedBox(width: 12),
                          _statCard('Zones', '${stats?['totalZones'] ?? 0}', Icons.location_on_rounded, AppTheme.accentPurple),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Zone Density
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Text('Zone Density', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              Consumer<AppDataProvider>(
                builder: (_, data, __) {
                  final stands = data.zones.where((z) => z.type == 'stand' || z.type == 'gate' || z.type == 'concourse').toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final zone = stands[index];
                        return _zoneDensityTile(zone.name, zone.density, zone.densityLevel, zone.currentOccupancy, zone.capacity);
                      },
                      childCount: stands.length,
                    ),
                  );
                },
              ),

              // Active Queues
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text('Busiest Queues', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              Consumer<AppDataProvider>(
                builder: (_, data, __) {
                  final sorted = List.of(data.queues)..sort((a, b) => b.currentWaitMinutes.compareTo(a.currentWaitMinutes));
                  final top = sorted.take(4).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final q = top[index];
                        return _queueTile(q.facilityName, q.currentWaitMinutes, q.queueLength, q.status, q.typeIcon);
                      },
                      childCount: top.length,
                    ),
                  );
                },
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Text('Quick Actions', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Row(
                    children: [
                      _actionCard('View Map', Icons.map_rounded, AppTheme.accentCyan, () {}),
                      const SizedBox(width: 12),
                      _actionCard('Order Food', Icons.restaurant_rounded, AppTheme.accentAmber, () {}),
                      const SizedBox(width: 12),
                      _actionCard('SOS', Icons.emergency_rounded, AppTheme.accentRed, () {}),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 22),
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.accentRed,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _zoneDensityTile(String name, int density, String level, int occupancy, int capacity) {
    final color = AppTheme.getDensityColor(level);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('$occupancy / $capacity', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$density%',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: color, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _queueTile(String name, int waitMin, int length, String status, String emoji) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text('$length in queue', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${waitMin}min', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: status == 'busy' ? AppTheme.accentRed : AppTheme.accentGreen)),
                Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
