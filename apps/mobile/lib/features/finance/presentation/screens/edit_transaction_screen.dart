import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/transaction_form_controller.dart';
import '../../application/providers/finance_providers.dart';
import '../widgets/transaction_form_body.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  var _hydrated = false;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(
      financeTransactionByIdProvider(widget.transactionId),
    );
    final form = ref.watch(
      editTransactionControllerProvider(widget.transactionId),
    );
    final controller = ref.read(
      editTransactionControllerProvider(widget.transactionId).notifier,
    );
    final categories =
        ref.watch(financeCategoriesProvider).valueOrNull ?? const [];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Edit Transaction',
              subtitle: 'Update this entry',
              leading: IconButton(
                key: const Key('edit_transaction_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.transactionDetailPath(
                          widget.transactionId,
                        ),
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: txAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingCardSkeleton(height: 160, lines: 4),
                ),
                error: (error, _) => InlineErrorCard(
                  message: userFacingErrorMessage(error),
                  onRetry: () => ref.invalidate(financeTransactionsProvider),
                ),
                data: (tx) {
                  if (tx == null) {
                    return InlineErrorCard(
                      key: const Key('edit_transaction_missing'),
                      message: 'This transaction is no longer available.',
                      onRetry: () => context.go(RoutePaths.transactionHistory),
                    );
                  }
                  if (!_hydrated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || _hydrated) return;
                      controller.hydrate(tx);
                      setState(() => _hydrated = true);
                    });
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: LoadingCardSkeleton(height: 160, lines: 4),
                    );
                  }
                  return TransactionFormBody(
                    key: ValueKey('edit_form_${tx.id}'),
                    form: form,
                    controller: controller,
                    saveLabel: 'Save changes',
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
                        const SnackBar(content: Text('Transaction updated')),
                      );
                      context.go(RoutePaths.transactionDetailPath(id));
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
