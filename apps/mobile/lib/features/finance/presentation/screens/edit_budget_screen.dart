import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/budget_form_controller.dart';
import '../../application/providers/finance_providers.dart';
import '../widgets/budget_form_body.dart';

class EditBudgetScreen extends ConsumerWidget {
  const EditBudgetScreen({super.key, required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(financeBudgetByIdProvider(budgetId));
    final form = ref.watch(editBudgetControllerProvider(budgetId));
    final controller = ref.read(
      editBudgetControllerProvider(budgetId).notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Edit budget',
              leading: IconButton(
                key: const Key('edit_budget_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.budgetDetailPath(budgetId),
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: budgetAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingCardSkeleton(height: 160, lines: 4),
                ),
                error: (error, _) => InlineErrorCard(
                  message: userFacingErrorMessage(error),
                  onRetry: () => ref.invalidate(financeBudgetsProvider),
                ),
                data: (budget) {
                  if (budget == null) {
                    return InlineErrorCard(
                      title: 'Budget not found',
                      message: 'This budget is no longer on this device.',
                      onRetry: () => context.go(RoutePaths.financeBudgets),
                    );
                  }
                  controller.hydrate(budget);
                  return BudgetFormBody(
                    form: form,
                    controller: controller,
                    saveLabel: 'Save changes',
                    onSave: () async {
                      final id = await controller.submit();
                      if (!context.mounted || id == null) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Budget updated on this device'),
                        ),
                      );
                      context.go(RoutePaths.budgetDetailPath(id));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
