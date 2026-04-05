import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'workout_plan_manager.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});
  @override State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {

  late final TabController _tabs;

  static final List<Map<String, dynamic>> _muscles = [
    {"name": "Chest",     "icon": Icons.self_improvement_rounded,
     "color": const Color(0xFF3B2314), "accent": const Color(0xFFC9A87C),
     "exercises": [
       {"name": "Bench Press",          "sets": "4 × 8-10"},
       {"name": "Incline Dumbbell Press","sets": "3 × 10-12"},
       {"name": "Cable Flyes",           "sets": "3 × 12-15"},
       {"name": "Push-Ups",             "sets": "3 × Failure"},
     ]},
    {"name": "Back",      "icon": Icons.airline_seat_flat_rounded,
     "color": const Color(0xFF1C2A1E), "accent": const Color(0xFF52B788),
     "exercises": [
       {"name": "Deadlift",    "sets": "4 × 5-6"},
       {"name": "Pull-Ups",    "sets": "4 × 8-10"},
       {"name": "Barbell Row", "sets": "3 × 8-10"},
       {"name": "Lat Pulldown","sets": "3 × 10-12"},
     ]},
    {"name": "Legs",      "icon": Icons.directions_run_rounded,
     "color": const Color(0xFF2A1C0E), "accent": const Color(0xFFD4A056),
     "exercises": [
       {"name": "Back Squat",        "sets": "5 × 5"},
       {"name": "Romanian Deadlift", "sets": "4 × 8-10"},
       {"name": "Leg Press",         "sets": "3 × 12-15"},
       {"name": "Calf Raises",       "sets": "4 × 15-20"},
     ]},
    {"name": "Shoulders", "icon": Icons.accessibility_new_rounded,
     "color": const Color(0xFF1A1A2A), "accent": const Color(0xFF9B8FC7),
     "exercises": [
       {"name": "Overhead Press","sets": "4 × 8-10"},
       {"name": "Lateral Raises","sets": "4 × 12-15"},
       {"name": "Face Pulls",    "sets": "3 × 15"},
       {"name": "Arnold Press",  "sets": "3 × 10-12"},
     ]},
    {"name": "Arms",      "icon": Icons.fitness_center_rounded,
     "color": const Color(0xFF3B1414), "accent": const Color(0xFFE8895A),
     "exercises": [
       {"name": "Barbell Curl",   "sets": "3 × 10-12"},
       {"name": "Tricep Dips",    "sets": "3 × 10-12"},
       {"name": "Hammer Curl",    "sets": "3 × 10"},
       {"name": "Skull Crushers", "sets": "3 × 10-12"},
     ]},
    {"name": "Core",      "icon": Icons.crop_free_rounded,
     "color": const Color(0xFF0E1F2A), "accent": const Color(0xFF5BBFD4),
     "exercises": [
       {"name": "Plank",              "sets": "3 × 60s"},
       {"name": "Cable Crunch",       "sets": "3 × 15"},
       {"name": "Hanging Leg Raise",  "sets": "3 × 12"},
       {"name": "Russian Twist",      "sets": "3 × 20"},
     ]},
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WorkoutPlanManager().addListener(_refresh);
  }

  @override
  void dispose() {
    WorkoutPlanManager().removeListener(_refresh);
    _tabs.dispose();
    super.dispose();
  }

  void _refresh() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Training Plans",
            style: AppTheme.subheading.copyWith(fontSize: 18)),
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.muted,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2.5,
          tabs: [
            const Tab(text: "Muscle Groups"),
            Tab(text: "My Plan (${WorkoutPlanManager().exercises.length})"),
          ],
        ),
      ),
      body: TabBarView(controller: _tabs, children: [
        _muscleList(),
        _myPlan(),
      ]),
    );
  }

  // ── Tab 1: Muscle list ───────────────────────────────────────────────────
  Widget _muscleList() => ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: _muscles.length,
    itemBuilder: (ctx, i) {
      final m = _muscles[i];
      return GestureDetector(
        onTap: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => _MuscleDetail(muscle: m))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [m["color"] as Color,
                  (m["color"] as Color).withOpacity(0.7)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: (m["color"] as Color).withOpacity(0.35),
                blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Row(children: [
            Container(width: 50, height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(m["icon"] as IconData,
                  color: m["accent"] as Color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(m["name"] as String, style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
              Text("${(m["exercises"] as List).length} exercises",
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13)),
            ])),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.6), size: 26),
          ]),
        ),
      );
    },
  );

  // ── Tab 2: My saved plan ─────────────────────────────────────────────────
  Widget _myPlan() {
    final saved = WorkoutPlanManager().exercises;
    if (saved.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
        Icon(Icons.fitness_center_rounded, size: 64, color: AppTheme.divider),
        const SizedBox(height: 16),
        Text("No exercises added yet",
            style: AppTheme.body.copyWith(fontSize: 15)),
        const SizedBox(height: 6),
        Text("Go to a muscle group and tap \"Add to Plan\"",
            style: AppTheme.label.copyWith(fontSize: 12)),
      ]));
    }

    // Group by muscle
    final Map<String, List<SavedExercise>> grouped = {};
    for (final e in saved) {
      grouped.putIfAbsent(e.muscle, () => []).add(e);
    }

    return ListView(padding: const EdgeInsets.all(20), children: [
      ...grouped.entries.map((entry) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, top: 4),
            child: Text(entry.key,
                style: AppTheme.subheading.copyWith(fontSize: 15)),
          ),
          ...entry.value.map((ex) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: AppTheme.card(radius: 16),
            child: Row(children: [
              Container(width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.fitness_center_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ex.name, style: AppTheme.subheading.copyWith(fontSize: 14)),
                Text(ex.sets, style: AppTheme.body.copyWith(
                    fontSize: 12, color: AppTheme.accent)),
              ])),
              GestureDetector(
                onTap: () => WorkoutPlanManager().remove(ex.id),
                child: Icon(Icons.delete_outline_rounded,
                    color: AppTheme.muted, size: 20),
              ),
            ]),
          )),
          const SizedBox(height: 8),
        ],
      )),
      const SizedBox(height: 80),
    ]);
  }
}

// ── Muscle Detail ────────────────────────────────────────────────────────────
class _MuscleDetail extends StatefulWidget {
  final Map<String, dynamic> muscle;
  const _MuscleDetail({required this.muscle});
  @override State<_MuscleDetail> createState() => _MuscleDetailState();
}

class _MuscleDetailState extends State<_MuscleDetail> {
  @override
  void initState() {
    super.initState();
    WorkoutPlanManager().addListener(_r);
  }
  @override void dispose() { WorkoutPlanManager().removeListener(_r); super.dispose(); }
  void _r() { if (mounted) setState(() {}); }

  @override
  Widget build(BuildContext context) {
    final m        = widget.muscle;
    final exercises = m["exercises"] as List;
    final accent   = m["accent"] as Color;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: m["color"] as Color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("${m["name"]} Training",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: exercises.length,
        itemBuilder: (ctx, i) {
          final ex      = exercises[i] as Map<String, dynamic>;
          final exId    = "${m["name"]}_${ex["name"]}";
          final added   = WorkoutPlanManager().isAdded(exId);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppTheme.card(radius: 20),
            child: Column(children: [
              // Video placeholder
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text("Opening ${ex["name"]} tutorial…"),
                        backgroundColor: accent)),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [m["color"] as Color,
                            (m["color"] as Color).withOpacity(0.7)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(Icons.play_circle_fill_rounded,
                          color: accent, size: 38),
                    ),
                    const SizedBox(height: 8),
                    Text("Watch Tutorial",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 13)),
                  ])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(ex["name"] as String,
                        style: AppTheme.subheading.copyWith(fontSize: 15)),
                    const SizedBox(height: 3),
                    Text(ex["sets"] as String,
                        style: AppTheme.body.copyWith(
                            color: accent, fontWeight: FontWeight.w600)),
                  ])),
                  // ── Add / Remove toggle ──
                  GestureDetector(
                    onTap: () {
                      WorkoutPlanManager().toggle(SavedExercise(
                        id:     exId,
                        muscle: m["name"] as String,
                        name:   ex["name"] as String,
                        sets:   ex["sets"] as String,
                      ));
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: added
                            ? AppTheme.primary
                            : AppTheme.accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(added ? Icons.check_rounded : Icons.add_rounded,
                            color: added ? Colors.white : AppTheme.primary,
                            size: 16),
                        const SizedBox(width: 5),
                        Text(added ? "Added" : "Add to Plan",
                            style: TextStyle(
                                color: added ? Colors.white : AppTheme.primary,
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }
}
