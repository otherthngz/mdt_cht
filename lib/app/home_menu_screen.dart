import 'package:flutter/material.dart';

import 'routes.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MDT Menu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NavTile(
            title: 'P2H',
            subtitle: 'Pre-start checks and issues',
            route: AppRoutes.p2h,
          ),
          _NavTile(
            title: 'Activity Timer',
            subtitle: 'Production/Non-Production state tracking',
            route: AppRoutes.activity,
          ),
          _NavTile(
            title: 'Dispatch Inbox',
            subtitle: 'System + radio assignments',
            route: AppRoutes.dispatch,
          ),
          _NavTile(
            title: 'End Shift + HM End',
            subtitle: 'Close shift and log final HM',
            route: AppRoutes.endShift,
          ),
          _NavTile(
            title: 'Sync Status',
            subtitle: 'Queue status and manual sync',
            route: AppRoutes.syncStatus,
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed(route),
      ),
    );
  }
}
