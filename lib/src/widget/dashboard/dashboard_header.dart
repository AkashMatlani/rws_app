import 'package:flutter/material.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.onRefresh,
    required this.isLoading,
  });

  final VoidCallback onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;

        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: dashboardMint.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.public_rounded, color: dashboardMint),
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'QUAKEWATCH',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!compact)
                    const Text(
                      'EARTHQUAKE INTELLIGENCE',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: dashboardMuted,
                        fontSize: 9,
                        letterSpacing: 1.6,
                      ),
                    ),
                ],
              ),
            ),

            if (!compact) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF19352F),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF285448)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: dashboardMint, size: 7),
                    SizedBox(width: 7),
                    Text(
                      'USGS LIVE FEED',
                      style: TextStyle(
                        color: dashboardMint,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],

            IconButton(
              tooltip: 'Refresh earthquake data',
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        );
      },
    );
  }
}
