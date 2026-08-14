import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/money_owed_form_controller.dart';
import '../../application/providers/finance_providers.dart';
import '../widgets/money_owed_form_body.dart';

class EditMoneyOwedScreen extends ConsumerWidget {
  const EditMoneyOwedScreen({super.key, required this.positionId});

  final String positionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final positionAsync = ref.watch(
      financeMoneyPositionByIdProvider(positionId),
    );
    final form = ref.watch(editMoneyOwedControllerProvider(positionId));
    final controller = ref.read(
      editMoneyOwedControllerProvider(positionId).notifier,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Edit money owed',
              leading: IconButton(
                key: const Key('edit_money_owed_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.moneyOwedDetailPath(positionId),
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: positionAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingCardSkeleton(height: 160, lines: 4),
                ),
                error: (error, _) => InlineErrorCard(
                  message: userFacingErrorMessage(error),
                  onRetry: () => ref.invalidate(financeMoneyPositionsProvider),
                ),
                data: (position) {
                  if (position == null) {
                    return InlineErrorCard(
                      title: 'Not found',
                      message:
                          'This money-owed entry is no longer on this device.',
                      onRetry: () => context.go(RoutePaths.financeMoneyOwed),
                    );
                  }
                  controller.hydrate(position);
                  return MoneyOwedFormBody(
                    form: form,
                    controller: controller,
                    saveLabel: 'Save changes',
                    onSave: () async {
                      final id = await controller.submit();
                      if (!context.mounted || id == null) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Updated on this device')),
                      );
                      context.go(RoutePaths.moneyOwedDetailPath(id));
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
