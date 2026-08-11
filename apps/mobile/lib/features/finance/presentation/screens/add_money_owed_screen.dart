import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../application/controllers/money_owed_form_controller.dart';
import '../widgets/money_owed_form_body.dart';

class AddMoneyOwedScreen extends ConsumerWidget {
  const AddMoneyOwedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addMoneyOwedControllerProvider);
    final controller = ref.read(addMoneyOwedControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: 'Add money owed',
              subtitle: 'Saved on this device',
              leading: IconButton(
                key: const Key('add_money_owed_back'),
                tooltip: 'Back',
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(
                        context,
                        fallback: RoutePaths.financeMoneyOwed,
                      ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: MoneyOwedFormBody(
                form: form,
                controller: controller,
                saveLabel: 'Save',
                onSave: () async {
                  final id = await controller.submit();
                  if (!context.mounted || id == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved on this device')),
                  );
                  context.go(RoutePaths.moneyOwedDetailPath(id));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
