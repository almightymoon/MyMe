import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_feature_card.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../data/exercise_demo_data.dart';
import '../../domain/entities/exercise_category.dart';
import '../../domain/entities/exercise_item.dart';
import '../widgets/exercise_list_tile.dart';

class ExerciseLibraryScreen extends StatelessWidget {
  const ExerciseLibraryScreen({super.key, this.categoryId});

  final String? categoryId;

  /// `null` = all categories. Unknown ids yield an empty list.
  ExerciseCategory? get _knownFilter {
    if (categoryId == null || categoryId!.isEmpty) return null;
    for (final category in ExerciseCategory.values) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  bool get _unknownCategory {
    return categoryId != null && categoryId!.isNotEmpty && _knownFilter == null;
  }

  List<ExerciseItem> _items() {
    if (_unknownCategory) return const [];
    final filter = _knownFilter;
    if (filter == null) return ExerciseDemoData.exercises;
    return ExerciseDemoData.byCategory(filter);
  }

  @override
  Widget build(BuildContext context) {
    final filter = _knownFilter;
    final items = _items();
    final title = _unknownCategory
        ? 'Exercise library'
        : (filter == null ? 'Exercise library' : filter.label);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: title,
              subtitle: _unknownCategory
                  ? 'No matching category'
                  : filter == null
                  ? 'Demo moves with decorative category artwork'
                  : '${filter.subtitle} · artwork is decorative',
              leading: IconButton(
                key: const Key('exercise_library_back'),
                tooltip: 'Back',
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(RoutePaths.exercise);
                  }
                },
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Text(
                'Category images set the mood. They are not exact form '
                'demonstrations or medical advice.',
                style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: items.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(AppSpacing.page),
                      children: [
                        EmptyFeatureCard(
                          key: const Key('exercise_library_empty'),
                          title: title,
                          message:
                              'No demo exercises in this category yet. Try another category or check back soon.',
                          icon: Icons.self_improvement_outlined,
                        ),
                      ],
                    )
                  : ListView.separated(
                      key: const Key('exercise_library_list'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xxxl,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final exercise = items[index];
                        return ExerciseListTile(
                          exercise: exercise,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${exercise.name}: detail coaching media coming later. '
                                  'Safety note — ${exercise.safetyNote}',
                                ),
                              ),
                            );
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
