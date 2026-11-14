import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rws_app/src/domain/earthquake.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';
import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'legend_dot.dart';
import 'panel_heading.dart';

class MapPanel extends StatelessWidget {
  const MapPanel({super.key, required this.events});

  final List<Earthquake> events;

  @override
  Widget build(BuildContext context) {
    final markers = events.take(250).map((event) {
      final size = (10 + event.magnitude * 3).clamp(12, 30).toDouble();

      final color = event.magnitude >= 5
          ? const Color(0xFFFF8B72)
          : event.magnitude >= 3
          ? const Color(0xFFFFC078)
          : dashboardMint;

      return Marker(
        point: LatLng(event.latitude, event.longitude),
        width: size,
        height: size,
        child: Tooltip(
          message: 'M${event.magnitude.toStringAsFixed(1)} · ${event.place}',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: .22),
              border: Border.all(color: color, width: 1.5),
            ),
            child: Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      );
    }).toList();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const PanelHeading(
            title: 'Global activity',
            subtitle: 'EVENT LOCATIONS · LAST SELECTED PERIOD',
            trailing: Icon(
              Icons.open_with_rounded,
              color: dashboardMuted,
              size: 17,
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final mapHeight = constraints.maxWidth < 400
                  ? 280.0
                  : constraints.maxWidth < 700
                  ? 320.0
                  : constraints.maxWidth < 1000
                  ? 350.0
                  : 390.0;

              return SizedBox(
                height: mapHeight,
                child: events.isEmpty
                    ? const EmptyState(
                        message: 'No earthquake locations to plot.',
                      )
                    : FlutterMap(
                        options: const MapOptions(
                          initialCenter: LatLng(18, 8),
                          initialZoom: 1.45,
                          minZoom: 1,
                          maxZoom: 8,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.quakewatch.app',
                          ),
                          MarkerLayer(markers: markers),
                          const RichAttributionWidget(
                            attributions: [
                              TextSourceAttribution(
                                '© OpenStreetMap contributors',
                              ),
                            ],
                          ),
                        ],
                      ),
              );
            },
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Wrap(
              spacing: 15,
              runSpacing: 8,
              children: [
                LegendDot(color: dashboardMint, label: 'Below M3'),
                LegendDot(color: Color(0xFFFFC078), label: 'M3 – M4.9'),
                LegendDot(color: Color(0xFFFF8B72), label: 'M5+'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
