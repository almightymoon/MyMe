import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/transaction_form_controller.dart';
import '../../application/providers/finance_providers.dart';
import '../widgets/transaction_form_body.dart';

class AddTransactionScreen extends ConsumerWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addTransactionControllerProvider);
    final controller = ref.read(addTransactionControllerProvider.notifier);
    final categories =
        ref.watch(financeCategoriesProvider).valueOrNull ?? const [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: AppStrings.addTransaction,
              subtitle: 'Saved on this device',
              leading: IconButton(
                key: const Key('add_transaction_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(context, fallback: RoutePaths.finance),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: TransactionFormBody(
                form: form,
                controller: controller,
                onSave: () async {
                  final validIds = categories
                      .where((c) => c.type == form.type)
                      .map((c) => c.id)
                      .toSet();
                  final id = await controller.submit(
                    validCategoryIds: validIds,
                  );
                  if (!context.mounted || id == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction saved on this device'),
                    ),
                  );
                  context.go(RoutePaths.transactionDetailPath(id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
