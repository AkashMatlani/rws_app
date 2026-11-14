import 'package:flutter/material.dart';
import 'package:rws_app/src/widget/dashboard/metric_card.dart';

import '../../data/earthquake_repository.dart';
import 'event_panel.dart';
import 'map_panel.dart';
import 'stale_notice.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key, required this.snapshot});

  final EarthquakeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final events = snapshot.events;
    final strongest = events.isEmpty
        ? null
        : events.reduce((a, b) => a.magnitude >= b.magnitude ? a : b);
    final average = events.isEmpty
        ? 0.0
        : events.map((e) => e.magnitude).reduce((a, b) => a + b) /
              events.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (snapshot.isStale) ...[
          const StaleNotice(),
          const SizedBox(height: 14),
        ],

        // RESPONSIVE METRIC CARDS
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = width < 600
                ? 1
                : width < 1000
                ? 2
                : 3;

            final aspectRatio = columns == 1
                ? 3.2
                : columns == 2
                ? 2.5
                : 2.15;

            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              children: [
                MetricCard(
                  label: 'REPORTED EVENTS',
                  value: events.length.toString(),
                  detail: 'In selected time window',
                  icon: Icons.radar_rounded,
                ),
                MetricCard(
                  label: 'STRONGEST EVENT',
                  value: strongest == null
                      ? '—'
                      : strongest.magnitude.toStringAsFixed(1),
                  detail: strongest?.place ?? 'No events in this window',
                  icon: Icons.bolt_rounded,
                  accent: const Color(0xFFFFB86B),
                ),
                MetricCard(
                  label: 'AVERAGE MAGNITUDE',
                  value: events.isEmpty ? '—' : average.toStringAsFixed(1),
                  detail: 'Across reported events',
                  icon: Icons.show_chart_rounded,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // RESPONSIVE MAP AND EVENT PANELS
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 950) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MapPanel(events: events),
                  const SizedBox(height: 16),
                  EventPanel(events: events),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 6, child: MapPanel(events: events)),
                const SizedBox(width: 16),
                Expanded(flex: 5, child: EventPanel(events: events)),
              ],
            );
          },
        ),
      ],
    );
  }
}
