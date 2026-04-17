import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/app_data_provider.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Queue Tracker', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppDataProvider>().fetchQueues();
              context.read<AppDataProvider>().fetchQueueStats();
            },
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (_, data, __) {
          final filtered = _filter == 'all'
              ? data.queues
              : data.queues.where((q) => q.facilityType == _filter).toList();
          final stats = data.queueStats;

          return RefreshIndicator(
            color: AppTheme.accentCyan,
            onRefresh: () async {
              await data.fetchQueues();
              await data.fetchQueueStats();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Stats Row
                if (stats != null) ...[
                  Row(
                    children: [
                      _miniStat('Avg Wait', '${stats['avgWaitMinutes']}m', AppTheme.accentAmber),
                      const SizedBox(width: 10),
                      _miniStat('Busy', '${stats['busyQueues']}', AppTheme.accentRed),
                      const SizedBox(width: 10),
                      _miniStat('Longest', '${stats['longestWaitMinutes']}m', AppTheme.accentOrange),
                      const SizedBox(width: 10),
                      _miniStat('Shortest', '${stats['shortestWaitMinutes']}m', AppTheme.accentGreen),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _chip('All', 'all'),
                      _chip('🍔 Food', 'food_stall'),
                      _chip('🚻 Restroom', 'restroom'),
                      _chip('🚪 Entry', 'entry_gate'),
                      _chip('🚶 Exit', 'exit_gate'),
                      _chip('🛍️ Merch', 'merchandise'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Queue List
                ...filtered.map((q) => _queueCard(q)),

                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text('No queues found', style: GoogleFonts.inter(color: AppTheme.textMuted)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) {
    final active = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: active ? AppTheme.primaryGradient : null,
            color: active ? null : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? Colors.transparent : AppTheme.cardBorder),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _queueCard(q) {
    final isBusy = q.status == 'busy';
    final waitColor = q.currentWaitMinutes > 10
        ? AppTheme.accentRed
        : q.currentWaitMinutes > 5
            ? AppTheme.accentAmber
            : AppTheme.accentGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isBusy ? AppTheme.accentRed.withOpacity(0.3) : AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(q.typeIcon, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(q.facilityName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (q.zoneName != null)
                          Text('📍 ${q.zoneName}  •  ', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMuted)),
                        Text('${q.queueLength} in line', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${q.currentWaitMinutes}', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: waitColor)),
                  Text('min', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: q.occupancyRatio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation(waitColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    q.trend == 'increasing' ? Icons.trending_up : q.trend == 'decreasing' ? Icons.trending_down : Icons.trending_flat,
                    size: 16,
                    color: q.trend == 'increasing' ? AppTheme.accentRed : q.trend == 'decreasing' ? AppTheme.accentGreen : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(q.trend.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBusy ? AppTheme.accentRed.withOpacity(0.15) : AppTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isBusy ? AppTheme.accentRed : AppTheme.accentGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
