import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../data/body_seed.dart';
import '../../../app/theme/app_radii.dart';

/// BMI & Body Composition — matches prototype `data-screen="bodycomp"`.
class BodyCompositionScreen extends StatefulWidget {
  const BodyCompositionScreen({super.key});

  @override
  State<BodyCompositionScreen> createState() => _BodyCompositionScreenState();
}

class _BodyCompositionScreenState extends State<BodyCompositionScreen> {
  String _exFilter = 'All';
  late Set<String> _selectedMoves;

  @override
  void initState() {
    super.initState();
    _selectedMoves = {
      for (final m in BodySeed.todayWorkout)
        if (m.selected) m.id,
    };
  }

  List<BodyExercisePreview> get _filteredExercises {
    if (_exFilter == 'All') return BodySeed.exercises;
    return BodySeed.exercises.where((e) => e.tag == _exFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filteredExercises.take(4).toList();

    return MemyModuleScaffold(
      key: const Key('body_composition'),
      title: 'BMI & Body Composition',
      trailing: Builder(
        builder: (menuContext) => MemyIconPlain(
          key: const Key('body_open_drawer'),
          icon: Icons.more_horiz_rounded,
          onPressed: () => openMemyDrawer(menuContext),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _BodyHero(),
          const SizedBox(height: 12),
          const _MetricsGrid(),
          const SizedBox(height: 18),
          Text('Muscle Balance', style: AppTextStyles.titleMedium()),
          const SizedBox(height: 10),
          const _MuscleBalanceCard(),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'AI Recommended Plan',
                  style: AppTextStyles.titleMedium(),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.orangeSoft,
                  borderRadius: AppRadii.pillRadius,
                ),
                child: Text(
                  '7 Days',
                  style: AppTextStyles.labelSmall(color: AppColors.ember)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _AiPlanCard(
            onStart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting AI plan')),
              );
              context.push(RoutePaths.exercise);
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text("Today's Workout", style: AppTextStyles.titleMedium()),
              ),
              TextButton(
                key: const Key('body_workout_view_all'),
                onPressed: () => context.push(RoutePaths.workoutSession),
                child: Text(
                  'View All',
                  style: AppTextStyles.labelMedium(color: AppColors.ember),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 148,
            child: ListView.separated(
              key: const Key('body_today_workout'),
              scrollDirection: Axis.horizontal,
              itemCount: BodySeed.todayWorkout.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final move = BodySeed.todayWorkout[i];
                final on = _selectedMoves.contains(move.id);
                return _TodayMoveCard(
                  move: move,
                  selected: on,
                  onTap: () {
                    setState(() {
                      if (on) {
                        _selectedMoves.remove(move.id);
                      } else {
                        _selectedMoves.add(move.id);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(move.name)),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Exercises Library',
                  style: AppTextStyles.titleMedium(),
                ),
              ),
              TextButton(
                key: const Key('body_exercise_see_all'),
                onPressed: () => context.push(RoutePaths.exercise),
                child: Text(
                  'See all',
                  style: AppTextStyles.labelMedium(color: AppColors.ember),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final tag in BodySeed.filterTags) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: Key('body_ex_filter_$tag'),
                      label: Text(tag),
                      selected: _exFilter == tag,
                      onSelected: (_) => setState(() => _exFilter = tag),
                      selectedColor: AppColors.orangeSoft,
                      labelStyle: AppTextStyles.labelMedium(
                        color: _exFilter == tag
                            ? AppColors.ember
                            : AppColors.secondaryText,
                      ),
                      side: BorderSide(
                        color: _exFilter == tag
                            ? AppColors.ember.withValues(alpha: 0.35)
                            : const Color(0xFFE5E5EA),
                      ),
                      backgroundColor: AppColors.surface,
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < exercises.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _ExerciseRow(
              exercise: exercises[i],
              onOpen: () => context.push(RoutePaths.exerciseLibrary),
              onAdd: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${exercises[i].name}')),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// Clean surface — no clipped Material shadows (those looked like broken borders).
class _BodyPanel extends StatelessWidget {
  const _BodyPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = AppRadii.cardRadius;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: radius,
        boxShadow: AppColors.softShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: onTap == null ? Colors.transparent : null,
          highlightColor: onTap == null ? Colors.transparent : null,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _BodyHero extends StatelessWidget {
  const _BodyHero();

  @override
  Widget build(BuildContext context) {
    return _BodyPanel(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: AppRadii.chipRadius,
                    color: const Color(0xFFFFE8D9),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/branding/avatar.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Great job, ${BodySeed.displayName}!',
                        style: AppTextStyles.titleMedium().copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text.rich(
                        TextSpan(
                          style: AppTextStyles.bodySmall().copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondaryText,
                            height: 1.35,
                          ),
                          children: const [
                            TextSpan(text: "You're in "),
                            TextSpan(
                              text: 'great shape',
                              style: TextStyle(
                                color: AppColors.ember,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: '. Keep going!'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 96,
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            decoration: BoxDecoration(
              color: AppColors.canvasDeep,
              borderRadius: AppRadii.chipRadius,
              border: Border.all(color: const Color(0xFFE8E8ED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Body Score',
                  style: AppTextStyles.labelSmall().copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${BodySeed.bodyScore}',
                        style: AppTextStyles.mono(fontSize: 22).copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: '/100',
                        style: AppTextStyles.labelSmall().copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const SizedBox(
                  height: 20,
                  width: double.infinity,
                  child: CustomPaint(painter: _SparkPainter()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final values = BodySeed.bodyScoreSpark;
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.ember
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid();

  @override
  Widget build(BuildContext context) {
    // Intrinsic 2×2 — avoids GridView aspect-ratio stretch / empty white bands.
    const gap = 10.0;
    return const Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricTile(
                label: 'BMI',
                value: '22.4',
                status: 'Normal',
                statusColor: AppColors.finance,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _MetricTile(
                label: 'Height',
                value: '175',
                unit: 'cm',
                status: 'Average',
                statusColor: AppColors.faintText,
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricTile(
                label: 'Weight',
                value: '72.5',
                unit: 'kg',
                status: '↓ 0.5 kg',
                statusColor: AppColors.finance,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _MetricTile(
                label: 'Body Fat',
                value: '18.6',
                unit: '%',
                status: '↓ 1.2%',
                statusColor: AppColors.finance,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.status,
    required this.statusColor,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return _BodyPanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyles.mono(fontSize: 22).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    height: 1.1,
                  ),
                ),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.bodySmall().copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.faintText,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: AppTextStyles.labelSmall(color: statusColor).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleBalanceCard extends StatelessWidget {
  const _MuscleBalanceCard();

  @override
  Widget build(BuildContext context) {
    return _BodyPanel(
      padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                'assets/images/modules/body.png',
                width: 108,
                height: 190,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.accessibility_new_rounded,
                  size: 72,
                  color: AppColors.ember,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final m in BodySeed.muscleBalance) _MuscleBarRow(stat: m),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleBarRow extends StatelessWidget {
  const _MuscleBarRow({required this.stat});

  final BodyMuscleStat stat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.name,
                  style: AppTextStyles.bodySmall().copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Text(
                stat.status,
                style: AppTextStyles.labelSmall(
                  color: stat.isExcellent
                      ? AppColors.emberDark
                      : AppColors.ember,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Custom track — Material LinearProgressIndicator was drawing
          // broken white strips through the card.
          ClipRRect(
            borderRadius: AppRadii.pillRadius,
            child: SizedBox(
              height: 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: AppColors.progressTrack),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (stat.pct / 100).clamp(0.0, 1.0),
                    child: const ColoredBox(color: AppColors.ember),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPlanCard extends StatelessWidget {
  const _AiPlanCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final focus = BodySeed.workoutFocus;
    return _BodyPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadii.controlRadius,
            child: Image.asset(
              'assets/images/exercise/hiit-bodyweight-squat.webp',
              width: 88,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 88,
                height: 110,
                color: AppColors.orangeSoft,
                alignment: Alignment.center,
                child: const Icon(Icons.fitness_center, color: AppColors.ember),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focus.title,
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  focus.subtitle,
                  style: AppTextStyles.bodySmall(color: AppColors.faintText),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in focus.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.canvasDeep,
                          borderRadius: AppRadii.pillRadius,
                          border: Border.all(color: const Color(0xFFE8E8ED)),
                        ),
                        child: Text(
                          tag,
                          style: AppTextStyles.labelSmall().copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                MemyPrimaryButton(
                  key: const Key('body_start_plan'),
                  label: 'Start Plan',
                  onPressed: onStart,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMoveCard extends StatelessWidget {
  const _TodayMoveCard({
    required this.move,
    required this.selected,
    required this.onTap,
  });

  final BodyTodayMove move;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: Material(
        color: selected ? AppColors.orangeSoft : AppColors.surface,
        borderRadius: AppRadii.controlRadius,
        child: InkWell(
          key: Key('body_today_${move.id}'),
          borderRadius: AppRadii.controlRadius,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: AppRadii.controlRadius,
              border: Border.all(
                color: selected
                    ? AppColors.ember.withValues(alpha: 0.4)
                    : const Color(0xFFE8E8ED),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 18,
                      color: selected ? AppColors.ember : AppColors.faintText,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 16,
                      color: selected ? AppColors.ember : AppColors.faintText,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  move.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  move.detail,
                  style: AppTextStyles.labelSmall(color: AppColors.faintText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.onOpen,
    required this.onAdd,
  });

  final BodyExercisePreview exercise;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return _BodyPanel(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.orangeSoft,
              borderRadius: AppRadii.thumbRadius,
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: AppColors.ember,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 15),
                ),
                Text(
                  '${exercise.muscles} · ${exercise.detail}',
                  style: AppTextStyles.bodySmall(color: AppColors.faintText),
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('body_ex_add_${exercise.id}'),
            tooltip: 'Add',
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.ember,
          ),
        ],
      ),
    );
  }
}
