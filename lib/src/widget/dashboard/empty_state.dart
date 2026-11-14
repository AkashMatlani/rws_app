import 'package:flutter/material.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: dashboardMuted, fontSize: 12),
        ),
      ),
    );
  }
}
