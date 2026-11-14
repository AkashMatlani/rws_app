import 'package:flutter/material.dart';
import 'package:rws_app/src/domain/earthquake.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

import 'empty_state.dart';
import 'event_row.dart';
import 'panel_heading.dart';

class EventPanel extends StatelessWidget {
  const EventPanel({super.key, required this.events});

  final List<Earthquake> events;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PanelHeading(
            title: 'Latest earthquakes',
            subtitle: '${events.length} REPORTED EVENTS',
            trailing: const Icon(Icons.more_horiz, color: dashboardMuted),
          ),

          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(22),
              child: EmptyState(
                message: 'Nothing reported in this time window.',
              ),
            )
          else
            ...events.take(12).map((event) => EventRow(event: event)),

          if (events.length > 12)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 15),
              child: Text(
                '+ ${events.length - 12} more events shown on the map',
                style: const TextStyle(color: dashboardMuted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}
