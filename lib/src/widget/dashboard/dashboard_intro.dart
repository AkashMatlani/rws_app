import 'package:flutter/material.dart';
import 'package:rws_app/src/data/earthquake_repository.dart';
import 'package:rws_app/src/widget/dashboard/dashboard_theme.dart';

class DashboardIntro extends StatelessWidget {
  const DashboardIntro({
    super.key,
    required this.window,
    required this.onWindowChanged,
  });

  final FeedWindow window;
  final ValueChanged<FeedWindow> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The ground is always moving.',
              style: TextStyle(
                fontSize: compact ? 25 : 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.1,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'A live look at seismic activity around the world.',
              style: TextStyle(color: dashboardMuted, fontSize: 14),
            ),
            const SizedBox(height: 19),

            Material(
              color: Colors.transparent,
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: FeedWindow.values.map((item) {
                  final selected = item == window;

                  return ChoiceChip(
                    label: Text(item.label),
                    selected: selected,
                    onSelected: (_) => onWindowChanged(item),
                    selectedColor: dashboardMint.withValues(alpha: .17),
                    backgroundColor: const Color(0xFF121B27),
                    side: BorderSide(
                      color: selected
                          ? dashboardMint.withValues(alpha: .6)
                          : const Color(0xFF263342),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? dashboardMint : dashboardMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    showCheckmark: false,
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
