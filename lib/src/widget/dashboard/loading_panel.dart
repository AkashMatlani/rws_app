import 'package:flutter/material.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: dashboardMint),
              SizedBox(height: 15),
              Text(
                'Connecting to the USGS feed…',
                style: TextStyle(color: dashboardMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
