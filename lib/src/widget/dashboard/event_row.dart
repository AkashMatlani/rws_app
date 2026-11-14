import 'package:flutter/material.dart';
import 'package:rws_app/src/domain/earthquake.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

class EventRow extends StatelessWidget {
  const EventRow({super.key, required this.event});

  final Earthquake event;

  @override
  Widget build(BuildContext context) {
    final magnitudeColor = event.magnitude >= 5
        ? const Color(0xFFFF8B72)
        : event.magnitude >= 3
        ? const Color(0xFFFFC078)
        : dashboardMint;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 39,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: magnitudeColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                event.magnitude.toStringAsFixed(1),
                style: TextStyle(
                  color: magnitudeColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.place,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_relativeTime(event.occurredAt)} · ${event.depthKm.toStringAsFixed(1)} km deep',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: dashboardMuted, fontSize: 10),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right_rounded, color: dashboardMuted, size: 18),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final difference = DateTime.now().toUtc().difference(time.toUtc());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}
