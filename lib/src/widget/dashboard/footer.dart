import 'package:flutter/material.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;

        if (compact) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DATA: UNITED STATES GEOLOGICAL SURVEY',
                style: TextStyle(
                  color: dashboardMuted,
                  fontSize: 9,
                  letterSpacing: .8,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'MAP © OPENSTREETMAP',
                style: TextStyle(
                  color: dashboardMuted,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          );
        }

        return const Row(
          children: [
            Expanded(
              child: Text(
                'DATA: UNITED STATES GEOLOGICAL SURVEY',
                style: TextStyle(
                  color: dashboardMuted,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ),
            Text(
              'MAP © OPENSTREETMAP',
              style: TextStyle(
                color: dashboardMuted,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    );
  }
}
