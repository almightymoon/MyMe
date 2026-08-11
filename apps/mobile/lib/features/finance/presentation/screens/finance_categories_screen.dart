import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_module_scaffold.dart';
import '../../application/providers/finance_providers.dart';
import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';

class FinanceCategoriesScreen extends ConsumerWidget {
  const FinanceCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(financeCategoriesProvider);

    return MemyModuleScaffold(
      key: const Key('finance_categories'),
      title: 'Categories',
      fallbackPath: RoutePaths.finance,
      trailing: MemyIconPlain(
        icon: Icons.add_rounded,
        onPressed: () => _editCategory(context, ref),
      ),
      child: catsAsync.when(
        loading: () => const LoadingCardSkeleton(height: 120, lines: 3),
        error: (error, _) => InlineErrorCard(
          key: const Key('categories_error'),
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(financeCategoriesProvider),
        ),
        data: (categories) {
          final income = categories
              .where((c) => c.type == TransactionType.income)
              .toList();
          final expense = categories
              .where((c) => c.type == TransactionType.expense)
              .toList();
          return Column(
            key: const Key('categories_populated'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Expense',
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final category in expense) _CategoryTile(category: category),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Income',
                style: AppTextStyles.titleSmall().copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final category in income) _CategoryTile(category: category),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({required this.category});

  final FinanceCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suffix = [
      if (category.isBuiltIn) 'Built-in',
      if (category.isArchived) 'Archived',
    ].join(' · ');
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        key: Key('category_tile_${category.id}'),
        contentPadding: EdgeInsets.zero,
        title: Text(category.name),
        subtitle: Text(
          suffix.isEmpty
              ? category.type.label
              : '${category.type.label} · $suffix',
          style: AppTextStyles.bodySmall(color: AppColors.faintText),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            final repo = ref.read(financeRepositoryProvider);
            try {
              switch (value) {
                case 'edit':
                  await _editCategory(context, ref, existing: category);
                case 'archive':
                  await repo.archiveCategory(category.id);
                  ref.invalidate(financeCategoriesProvider);
                case 'restore':
                  await repo.restoreCategory(category.id);
                  ref.invalidate(financeCategoriesProvider);
              }
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(userFacingErrorMessage(error))),
              );
            }
          },
          itemBuilder: (context) => [
            if (category.isCustom)
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!category.isArchived)
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
            if (category.isArchived)
              const PopupMenuItem(value: 'restore', child: Text('Restore')),
          ],
        ),
      ),
    );
  }
}

Future<void> _editCategory(
  BuildContext context,
  WidgetRef ref, {
  FinanceCategory? existing,
}) async {
  final nameController = TextEditingController(text: existing?.name ?? '');
  var type = existing?.type ?? TransactionType.expense;
  final saved = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(existing == null ? 'Add category' : 'Edit category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const Key('category_name_field'),
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionType>(
                  // ignore: deprecated_member_use
                  value: type,
                  items: [
                    for (final value in TransactionType.values)
                      DropdownMenuItem(value: value, child: Text(value.label)),
                  ],
                  onChanged: existing == null
                      ? (value) {
                          if (value == null) return;
                          setState(() => type = value);
                        }
                      : null,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                key: const Key('category_save_button'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
  final name = nameController.text.trim();
  nameController.dispose();
  if (saved != true || !context.mounted) return;
  if (name.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Name is required')));
    return;
  }
  final repo = ref.read(financeRepositoryProvider);
  try {
    if (existing == null) {
      await repo.createCustomCategory(
        FinanceCategory(
          id: ref.read(uuidProvider).v4(),
          name: name,
          type: type,
          iconKey: 'other',
          isCustom: true,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await repo.updateCustomCategory(existing.copyWith(name: name));
    }
    ref.invalidate(financeCategoriesProvider);
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(userFacingErrorMessage(error))));
  }
}
