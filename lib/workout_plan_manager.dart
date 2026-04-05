// Global singleton to hold user's saved exercises across sessions (in-memory)
class WorkoutPlanManager {
  static final WorkoutPlanManager _instance = WorkoutPlanManager._internal();
  factory WorkoutPlanManager() => _instance;
  WorkoutPlanManager._internal();

  final List<SavedExercise> exercises = [];
  final List<void Function()> _listeners = [];

  void addListener(void Function() l) => _listeners.add(l);
  void removeListener(void Function() l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) l(); }

  bool isAdded(String id) => exercises.any((e) => e.id == id);

  void toggle(SavedExercise ex) {
    if (isAdded(ex.id)) {
      exercises.removeWhere((e) => e.id == ex.id);
    } else {
      exercises.add(ex);
    }
    _notify();
  }

  void remove(String id) {
    exercises.removeWhere((e) => e.id == id);
    _notify();
  }
}

class SavedExercise {
  final String id;       // e.g. "Chest_Bench Press"
  final String muscle;
  final String name;
  final String sets;

  const SavedExercise({
    required this.id,
    required this.muscle,
    required this.name,
    required this.sets,
  });
}
