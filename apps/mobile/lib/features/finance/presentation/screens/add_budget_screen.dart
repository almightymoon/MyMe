import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/budget_form_controller.dart';
import '../widgets/budget_form_body.dart';

class AddBudgetScreen extends ConsumerWidget {
  const AddBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addBudgetControllerProvider);
    final controller = ref.read(addBudgetControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Add budget',
              subtitle: 'Saved on this device',
              leading: IconButton(
                key: const Key('add_budget_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.financeBudgets,
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: BudgetFormBody(
                form: form,
                controller: controller,
                onSave: () async {
                  final id = await controller.submit();
                  if (!context.mounted || id == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget saved on this device'),
                    ),
                  );
                  context.go(RoutePaths.budgetDetailPath(id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
