import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../data/exercise_assets.dart';
import '../../domain/entities/exercise_category.dart';

/// Loads category artwork with a branded fallback when the asset is missing.
///
/// Avoids indeterminate progress animations so widget tests can settle.
class ExerciseArtwork extends StatelessWidget {
  const ExerciseArtwork({
    super.key,
    required this.category,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = AppRadii.cardRadius,
    this.cacheWidth,
    this.assetPathOverride,
  });

  final ExerciseCategory category;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  /// Decoded width hint in physical pixels for memory-friendly decoding.
  final int? cacheWidth;

  /// Test / debug hook when the real asset path should not be used.
  final String? assetPathOverride;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final logicalWidth = width ?? MediaQuery.sizeOf(context).width;
    final decodedWidth =
        cacheWidth ?? (logicalWidth * dpr).round().clamp(64, 1200);

    return Semantics(
      image: true,
      label: ExerciseAssets.semanticLabelFor(category),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.asset(
          assetPathOverride ?? ExerciseAssets.pathFor(category),
          width: width,
          height: height,
          fit: fit,
          cacheWidth: decodedWidth,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) =>
              _FallbackArt(category: category, width: width, height: height),
        ),
      ),
    );
  }
}

class _FallbackArt extends StatelessWidget {
  const _FallbackArt({required this.category, this.width, this.height});

  final ExerciseCategory category;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('exercise_art_fallback_${category.id}'),
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.canvasDeep, AppColors.canvas],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            color: AppColors.ember,
            size: 36,
          ),
          const SizedBox(height: 8),
          Text(
            category.label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }
}
