import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/app_data_provider.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _descController = TextEditingController();
  String? _selectedType;

  final _emergencyTypes = [
    {'type': 'medical', 'icon': '🏥', 'label': 'Medical', 'color': AppTheme.accentRed},
    {'type': 'fire', 'icon': '🔥', 'label': 'Fire', 'color': AppTheme.accentOrange},
    {'type': 'security', 'icon': '🔒', 'label': 'Security', 'color': AppTheme.accentAmber},
    {'type': 'lost_child', 'icon': '👶', 'label': 'Lost Child', 'color': AppTheme.accentPurple},
    {'type': 'evacuation', 'icon': '🚨', 'label': 'Evacuation', 'color': AppTheme.accentRed},
    {'type': 'other', 'icon': '⚠️', 'label': 'Other', 'color': AppTheme.textSecondary},
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AppDataProvider>(
        builder: (_, data, __) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // SOS Button
              GestureDetector(
                onTap: () => _showSOSDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1744), Color(0xFFD50000)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentRed.withOpacity(0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.emergency, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      Text('SOS EMERGENCY', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('Tap to report an emergency', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Quick Type Buttons
              Text('Quick Report', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _emergencyTypes.map((t) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedType = t['type'] as String);
                      _showSOSDialog(presetType: t['type'] as String);
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: (t['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: (t['color'] as Color).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(t['icon'] as String, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(t['label'] as String, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: t['color'] as Color)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Active Emergencies
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your Reports', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                  GestureDetector(
                    onTap: () => data.fetchEmergencies(),
                    child: const Icon(Icons.refresh, color: AppTheme.accentCyan, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (data.emergencies.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text('No active emergencies', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ),

              ...data.emergencies.map((e) => _emergencyCard(e)),
            ],
          );
        },
      ),
    );
  }

  Widget _emergencyCard(e) {
    final statusColors = {
      'reported': AppTheme.accentAmber,
      'acknowledged': AppTheme.accentBlue,
      'responding': AppTheme.accentOrange,
      'resolved': AppTheme.accentGreen,
    };
    final color = statusColors[e.status] ?? AppTheme.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(e.typeIcon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.typeDisplay, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                    Text(e.description, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(e.status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
              ),
            ],
          ),
          if (e.assignedTo != null && e.assignedTo!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: AppTheme.accentCyan),
                const SizedBox(width: 6),
                Text('Assigned: ${e.assignedTo}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.accentCyan)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showSOSDialog({String? presetType}) {
    _selectedType = presetType;
    _descController.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              decoration: const BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.cardBorder, borderRadius: BorderRadius.circular(2))),
                  ),
                  const SizedBox(height: 20),
                  Text('Report Emergency', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Text('Type', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _emergencyTypes.map((t) {
                      final isActive = _selectedType == t['type'];
                      return GestureDetector(
                        onTap: () => setModalState(() => _selectedType = t['type'] as String),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? (t['color'] as Color).withOpacity(0.2) : AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isActive ? (t['color'] as Color) : AppTheme.cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(t['icon'] as String),
                              const SizedBox(width: 6),
                              Text(t['label'] as String, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Describe the emergency...',
                      labelText: 'Description',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
                      onPressed: () async {
                        if (_selectedType == null || _descController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Please fill in all fields'), backgroundColor: AppTheme.accentAmber, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        final data = context.read<AppDataProvider>();
                        final result = await data.reportEmergency(_selectedType!, _descController.text, null);
                        if (result != null && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('🚨 Emergency reported! Help is on the way.'), backgroundColor: AppTheme.accentRed, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          );
                        }
                      },
                      child: Text('SEND EMERGENCY ALERT', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
