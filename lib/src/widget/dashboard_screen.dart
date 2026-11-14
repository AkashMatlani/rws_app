import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rws_app/src/widget/dashboard/error_panel.dart';
import 'package:rws_app/src/widget/dashboard/footer.dart';

import '../data/earthquake_repository.dart';
import 'dashboard/dashboard_content.dart';
import 'dashboard/dashboard_header.dart';
import 'dashboard/dashboard_intro.dart';
import 'dashboard/loading_panel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final window = ref.watch(feedWindowProvider);
    final feed = ref.watch(earthquakeFeedProvider);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontalPadding = width < 400
                ? 12.0
                : width < 700
                ? 18.0
                : width < 1200
                ? 28.0
                : 36.0;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        width < 400 ? 16 : 24,
                        horizontalPadding,
                        32,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          DashboardHeader(
                            onRefresh: () =>
                                ref.invalidate(earthquakeFeedProvider),
                            isLoading: feed.isLoading,
                          ),
                          const SizedBox(height: 28),
                          DashboardIntro(
                            window: window,
                            onWindowChanged: (value) {
                              ref
                                  .read(feedWindowProvider.notifier)
                                  .select(value);
                            },
                          ),
                          const SizedBox(height: 18),
                          feed.when(
                            loading: () => const LoadingPanel(),
                            error: (error, _) => ErrorPanel(
                              message: _friendlyError(error),
                              onRetry: () =>
                                  ref.invalidate(earthquakeFeedProvider),
                            ),
                            data: (snapshot) =>
                                DashboardContent(snapshot: snapshot),
                          ),
                          const SizedBox(height: 22),
                          const Footer(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error.toString().contains('SocketException')) {
      return 'We could not reach the USGS feed. Check your connection and try again.';
    }
    return 'The earthquake feed is temporarily unavailable. Please try again.';
  }
}
