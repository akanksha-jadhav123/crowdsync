import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/app_data_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () => context.read<AppDataProvider>().markAllRead(),
            child: Text('Mark all read', style: GoogleFonts.inter(color: AppTheme.accentCyan, fontSize: 13)),
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (_, data, __) {
          if (data.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔔', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('No notifications', style: GoogleFonts.inter(fontSize: 18, color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.accentCyan,
            onRefresh: () => data.fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: data.notifications.length,
              itemBuilder: (context, index) {
                final n = data.notifications[index];
                final typeColors = {
                  'emergency': AppTheme.accentRed,
                  'warning': AppTheme.accentAmber,
                  'alert': AppTheme.accentOrange,
                  'order': AppTheme.accentBlue,
                  'promo': AppTheme.accentPurple,
                  'info': AppTheme.accentCyan,
                };
                final color = typeColors[n.type] ?? AppTheme.accentCyan;

                return GestureDetector(
                  onTap: () {
                    if (!n.isRead) data.markNotificationRead(n.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: n.isRead ? AppTheme.cardDark : AppTheme.cardDark.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: n.isRead ? AppTheme.cardBorder : color.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(child: Text(n.typeIcon, style: const TextStyle(fontSize: 20))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(n.title, style: GoogleFonts.inter(
                                      fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                                      fontSize: 14,
                                    )),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(n.message, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary), maxLines: 3),
                              const SizedBox(height: 6),
                              Text(
                                _formatTime(n.createdAt),
                                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d, h:mm a').format(dt);
  }
}
