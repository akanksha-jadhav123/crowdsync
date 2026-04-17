import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../providers/app_data_provider.dart';
import '../models/zone_model.dart';

class StadiumMapScreen extends StatefulWidget {
  const StadiumMapScreen({super.key});

  @override
  State<StadiumMapScreen> createState() => _StadiumMapScreenState();
}

class _StadiumMapScreenState extends State<StadiumMapScreen> {
  ZoneModel? _selectedZone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stadium Map', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AppDataProvider>().fetchZones(),
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (_, data, __) {
          if (data.zones.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentCyan));
          }
          return Column(
            children: [
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem('Low', AppTheme.densityLow),
                    const SizedBox(width: 20),
                    _legendItem('Medium', AppTheme.densityMedium),
                    const SizedBox(width: 20),
                    _legendItem('High', AppTheme.densityHigh),
                  ],
                ),
              ),
              // Stadium Map
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: CustomPaint(
                          painter: StadiumPainter(data.zones, _selectedZone),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final scaleX = constraints.maxWidth / 850;
                              final scaleY = constraints.maxHeight / 650;
                              return Stack(
                                children: data.zones.map((zone) {
                                  return Positioned(
                                    left: zone.x * scaleX,
                                    top: zone.y * scaleY,
                                    width: zone.width * scaleX,
                                    height: zone.height * scaleY,
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        _selectedZone = _selectedZone?.id == zone.id ? null : zone;
                                      }),
                                      child: Container(color: Colors.transparent),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Selected Zone Details
              if (_selectedZone != null) _zoneDetails(_selectedZone!),
            ],
          );
        },
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _zoneDetails(ZoneModel zone) {
    final color = AppTheme.getDensityColor(zone.densityLevel);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getZoneIcon(zone.type), color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(zone.name, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(zone.type.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${zone.density}%', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: color, fontSize: 18)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: zone.density / 100,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${zone.currentOccupancy} / ${zone.capacity} people',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
              Text('Floor ${zone.floor}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getZoneIcon(String type) {
    switch (type) {
      case 'gate': return Icons.door_front_door_rounded;
      case 'stand': return Icons.event_seat_rounded;
      case 'concourse': return Icons.directions_walk_rounded;
      case 'food_court': return Icons.restaurant_rounded;
      case 'restroom': return Icons.wc_rounded;
      case 'medical': return Icons.local_hospital_rounded;
      case 'parking': return Icons.local_parking_rounded;
      case 'vip': return Icons.star_rounded;
      case 'field': return Icons.sports_soccer_rounded;
      default: return Icons.place_rounded;
    }
  }
}

class StadiumPainter extends CustomPainter {
  final List<ZoneModel> zones;
  final ZoneModel? selected;

  StadiumPainter(this.zones, this.selected);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 850;
    final scaleY = size.height / 650;

    // Draw stadium outline
    final outlinePaint = Paint()
      ..color = AppTheme.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final stadiumRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(140 * scaleX, 60 * scaleY, 580 * scaleX, 530 * scaleY),
      Radius.circular(80 * scaleX),
    );
    canvas.drawRRect(stadiumRect, outlinePaint);

    // Draw field
    final fieldPaint = Paint()
      ..color = const Color(0xFF1A3A1A)
      ..style = PaintingStyle.fill;
    final fieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(300 * scaleX, 200 * scaleY, 260 * scaleX, 250 * scaleY),
      Radius.circular(8 * scaleX),
    );
    canvas.drawRRect(fieldRect, fieldPaint);

    // Draw field lines
    final linesPaint = Paint()
      ..color = const Color(0xFF2E6B2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(fieldRect, linesPaint);
    // Center circle
    canvas.drawCircle(
      Offset(430 * scaleX, 325 * scaleY),
      40 * scaleX,
      linesPaint,
    );
    // Center line
    canvas.drawLine(
      Offset(430 * scaleX, 200 * scaleY),
      Offset(430 * scaleX, 450 * scaleY),
      linesPaint,
    );

    // Draw zones
    for (final zone in zones) {
      if (zone.type == 'field') continue;

      final color = AppTheme.getDensityColor(zone.densityLevel);
      final isSelected = selected?.id == zone.id;

      final zonePaint = Paint()
        ..color = color.withOpacity(isSelected ? 0.5 : 0.25)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = isSelected ? color : color.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3 : 1.5;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          zone.x * scaleX, zone.y * scaleY,
          zone.width * scaleX, zone.height * scaleY,
        ),
        Radius.circular(6 * scaleX),
      );

      canvas.drawRRect(rect, zonePaint);
      canvas.drawRRect(rect, borderPaint);

      // Zone label
      final textPainter = TextPainter(
        text: TextSpan(
          text: zone.name.length > 12 ? '${zone.name.substring(0, 10)}..' : zone.name,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 9 * scaleX,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: zone.width * scaleX);
      textPainter.paint(
        canvas,
        Offset(
          zone.x * scaleX + (zone.width * scaleX - textPainter.width) / 2,
          zone.y * scaleY + (zone.height * scaleY - textPainter.height) / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant StadiumPainter oldDelegate) => true;
}
