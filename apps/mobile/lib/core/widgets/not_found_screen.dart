import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import 'memy_empty_state.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.uri});

  final Uri? uri;

  @override
  Widget build(BuildContext context) {
    final path = uri?.path;
    final message = path != null && path.isNotEmpty && path != '/'
        ? '“$path” is not in MeMy. Head home and continue from there.'
        : 'That screen is not in MeMy. Head home and continue from there.';
    return Scaffold(
      key: const Key('page_not_found'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: MemyEmptyState(
          icon: Icons.search_off_rounded,
          title: 'Page not found',
          message: message,
          actionLabel: 'Go home',
          onAction: () => context.go(RoutePaths.today),
        ),
      ),
    );
  }
}
