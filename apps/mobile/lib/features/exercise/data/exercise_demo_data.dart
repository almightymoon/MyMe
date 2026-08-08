import '../domain/entities/exercise_category.dart';
import '../domain/entities/exercise_difficulty.dart';
import '../domain/entities/exercise_item.dart';
import '../domain/entities/featured_workout.dart';

/// Demo catalog for the Exercise module (no backend yet).
abstract final class ExerciseDemoData {
  static const WeeklyActivitySummary weeklySummary = WeeklyActivitySummary(
    sessionsCompleted: 4,
    activeMinutes: 146,
    streakDays: 3,
    weekLabel: 'This week',
  );

  static const FeaturedWorkout featuredWorkout = FeaturedWorkout(
    id: 'featured-strength-flow',
    title: 'Calm Strength Flow',
    subtitle: 'Full-body session with light dumbbells and steady tempo.',
    durationMinutes: 28,
    category: ExerciseCategory.strength,
    focusAreas: ['Legs', 'Core', 'Posture'],
  );

  static const List<RecentActivityItem> recentActivity = [
    RecentActivityItem(
      id: 'recent-1',
      title: 'Morning mobility',
      category: ExerciseCategory.mobility,
      completedLabel: 'Yesterday',
      durationMinutes: 12,
    ),
    RecentActivityItem(
      id: 'recent-2',
      title: 'Easy outdoor run',
      category: ExerciseCategory.running,
      completedLabel: '2 days ago',
      durationMinutes: 32,
    ),
    RecentActivityItem(
      id: 'recent-3',
      title: 'Warrior flow',
      category: ExerciseCategory.yoga,
      completedLabel: '3 days ago',
      durationMinutes: 20,
    ),
  ];

  static const List<ExerciseItem> exercises = [
    ExerciseItem(
      id: 'ex-goblet-squat',
      name: 'Goblet squat',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Dumbbell or kettlebell',
      primaryMuscles: ['Quads', 'Glutes', 'Core'],
      description:
          'Hold a weight at your chest and sit into a controlled squat.',
      safetyNote:
          'Keep heels grounded and knees tracking toes. Category art is decorative — not a form checklist.',
      sets: 3,
      repetitions: 10,
    ),
    ExerciseItem(
      id: 'ex-rdl',
      name: 'Romanian deadlift',
      category: ExerciseCategory.strength,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Dumbbells',
      primaryMuscles: ['Hamstrings', 'Glutes', 'Back'],
      description: 'Hinge at the hips with a soft knee bend and long spine.',
      safetyNote:
          'Prioritize hinge pattern over load. Illustrations nearby are promotional only.',
      sets: 3,
      repetitions: 8,
    ),
    ExerciseItem(
      id: 'ex-easy-run',
      name: 'Easy aerobic run',
      category: ExerciseCategory.running,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Running shoes',
      primaryMuscles: ['Legs', 'Cardio'],
      description: 'Conversational pace outdoors or on a treadmill.',
      safetyNote:
          'Warm up gradually. Artwork shows mood, not stride technique.',
      durationMinutes: 25,
    ),
    ExerciseItem(
      id: 'ex-intervals',
      name: 'Short run intervals',
      category: ExerciseCategory.running,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Running shoes',
      primaryMuscles: ['Legs', 'Cardio'],
      description: 'Alternate brisk efforts with easy recovery jogs.',
      safetyNote: 'Stop if you feel sharp pain. Images are not coaching cues.',
      durationMinutes: 20,
    ),
    ExerciseItem(
      id: 'ex-warrior',
      name: 'Warrior II hold',
      category: ExerciseCategory.yoga,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Yoga mat',
      primaryMuscles: ['Legs', 'Hips', 'Shoulders'],
      description: 'Open stance with arms extended and steady breathing.',
      safetyNote:
          'Modify depth for comfort. The warrior illustration is decorative.',
      durationMinutes: 5,
    ),
    ExerciseItem(
      id: 'ex-cat-cow',
      name: 'Cat–cow flow',
      category: ExerciseCategory.yoga,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Yoga mat',
      primaryMuscles: ['Spine', 'Core'],
      description:
          'Alternate gentle spinal flexion and extension on all fours.',
      safetyNote: 'Move slowly with the breath. Not medical guidance.',
      durationMinutes: 4,
    ),
    ExerciseItem(
      id: 'ex-steady-ride',
      name: 'Steady endurance ride',
      category: ExerciseCategory.cycling,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Bicycle or indoor bike',
      primaryMuscles: ['Quads', 'Glutes', 'Cardio'],
      description:
          'Maintain an easy cadence you could sustain conversationally.',
      safetyNote: 'Check bike fit and traffic awareness outdoors.',
      durationMinutes: 30,
    ),
    ExerciseItem(
      id: 'ex-hill-repeats',
      name: 'Gentle hill repeats',
      category: ExerciseCategory.cycling,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'Bicycle',
      primaryMuscles: ['Legs', 'Cardio'],
      description: 'Short climbs with easy spinning recovery between efforts.',
      safetyNote: 'Stay seated if new to hills. Art is promotional only.',
      durationMinutes: 22,
    ),
    ExerciseItem(
      id: 'ex-squat-pulses',
      name: 'Bodyweight squat pulses',
      category: ExerciseCategory.hiit,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'None',
      primaryMuscles: ['Quads', 'Glutes'],
      description: 'Pulse near the bottom of a squat for short work intervals.',
      safetyNote:
          'The squat illustration is category mood art — not exact form coaching for this move.',
      sets: 4,
      repetitions: 20,
    ),
    ExerciseItem(
      id: 'ex-burpee-lite',
      name: 'Step-back burpee',
      category: ExerciseCategory.hiit,
      difficulty: ExerciseDifficulty.intermediate,
      equipment: 'None',
      primaryMuscles: ['Full body', 'Cardio'],
      description:
          'Step back to a plank, step in, and stand — skip the jump if needed.',
      safetyNote: 'Protect wrists and low back; regress freely.',
      sets: 3,
      repetitions: 8,
    ),
    ExerciseItem(
      id: 'ex-side-stretch',
      name: 'Seated side stretch',
      category: ExerciseCategory.mobility,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Mat or chair',
      primaryMuscles: ['Obliques', 'Lats'],
      description: 'Reach overhead and lengthen through the side body.',
      safetyNote: 'Stay within a comfortable range. Stretch art is decorative.',
      durationMinutes: 3,
    ),
    ExerciseItem(
      id: 'ex-hip-opener',
      name: 'Figure-four hip opener',
      category: ExerciseCategory.mobility,
      difficulty: ExerciseDifficulty.beginner,
      equipment: 'Mat',
      primaryMuscles: ['Hips', 'Glutes'],
      description: 'Cross ankle over opposite thigh and hinge gently.',
      safetyNote: 'Support the knee if it feels sensitive.',
      durationMinutes: 4,
    ),
  ];

  static List<ExerciseItem> byCategory(ExerciseCategory category) {
    return exercises.where((e) => e.category == category).toList();
  }

  /// Parses a JSON list; skips malformed entries instead of crashing the UI.
  static List<ExerciseItem> parseSafely(List<dynamic> raw) {
    final items = <ExerciseItem>[];
    for (final entry in raw) {
      try {
        if (entry is Map<String, dynamic>) {
          items.add(ExerciseItem.fromJson(entry));
        } else if (entry is Map) {
          items.add(ExerciseItem.fromJson(Map<String, dynamic>.from(entry)));
        }
      } catch (_) {
        // Skip malformed demo rows.
      }
    }
    return items;
  }
}
