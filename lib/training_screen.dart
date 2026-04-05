import 'package:flutter/material.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF8F4EF);

  static final List<Map<String, dynamic>> _muscles = [
    {
      "name": "Chest",
      "icon": Icons.self_improvement_rounded,
      "color": const Color(0xFF1A1A2E),
      "accent": const Color(0xFF4361EE),
      "exercises": [
        {"name": "Bench Press", "sets": "4 x 8-10", "videoId": "rT7DgCr-3pg"},
        {"name": "Incline Dumbbell Press", "sets": "3 x 10-12", "videoId": "8iPEnn-ltC8"},
        {"name": "Cable Flyes", "sets": "3 x 12-15", "videoId": "Iwe6AmxVf7o"},
        {"name": "Push-Ups", "sets": "3 x Failure", "videoId": "IODxDxX7oi4"},
      ],
    },
    {
      "name": "Back",
      "icon": Icons.airline_seat_flat_rounded,
      "color": const Color(0xFF0F3460),
      "accent": const Color(0xFF00B4D8),
      "exercises": [
        {"name": "Deadlift", "sets": "4 x 5-6", "videoId": "op9kVnSso6Q"},
        {"name": "Pull-Ups", "sets": "4 x 8-10", "videoId": "eGo4IYlbE5g"},
        {"name": "Barbell Row", "sets": "3 x 8-10", "videoId": "kBWAon7ItDw"},
        {"name": "Lat Pulldown", "sets": "3 x 10-12", "videoId": "CAwf7n6Luuc"},
      ],
    },
    {
      "name": "Legs",
      "icon": Icons.directions_run_rounded,
      "color": const Color(0xFF1B4332),
      "accent": const Color(0xFF52B788),
      "exercises": [
        {"name": "Back Squat", "sets": "5 x 5", "videoId": "ultWZbUMPL8"},
        {"name": "Romanian Deadlift", "sets": "4 x 8-10", "videoId": "JCXUYuzwNrM"},
        {"name": "Leg Press", "sets": "3 x 12-15", "videoId": "IZxyjW7MPJQ"},
        {"name": "Calf Raises", "sets": "4 x 15-20", "videoId": "gwLzBJYoWlI"},
      ],
    },
    {
      "name": "Shoulders",
      "icon": Icons.accessibility_new_rounded,
      "color": const Color(0xFF4A0E8F),
      "accent": const Color(0xFFC77DFF),
      "exercises": [
        {"name": "Overhead Press", "sets": "4 x 8-10", "videoId": "2yjwXTZQDDI"},
        {"name": "Lateral Raises", "sets": "4 x 12-15", "videoId": "3VcKaXpzqRo"},
        {"name": "Face Pulls", "sets": "3 x 15", "videoId": "rep-qVOkqgk"},
        {"name": "Arnold Press", "sets": "3 x 10-12", "videoId": "6Z15_WdXmVw"},
      ],
    },
    {
      "name": "Arms",
      "icon": Icons.fitness_center_rounded,
      "color": const Color(0xFF7B2D00),
      "accent": const Color(0xFFFF8C42),
      "exercises": [
        {"name": "Barbell Curl", "sets": "3 x 10-12", "videoId": "kwG2ipFRgfo"},
        {"name": "Tricep Dips", "sets": "3 x 10-12", "videoId": "wjUmnZH528Y"},
        {"name": "Hammer Curl", "sets": "3 x 10", "videoId": "zC3nLlEvin4"},
        {"name": "Skull Crushers", "sets": "3 x 10-12", "videoId": "NIKSMZmfGDQ"},
      ],
    },
    {
      "name": "Core",
      "icon": Icons.crop_free_rounded,
      "color": const Color(0xFF003049),
      "accent": const Color(0xFFFCBF49),
      "exercises": [
        {"name": "Plank", "sets": "3 x 60s", "videoId": "ASdvN_XEl_c"},
        {"name": "Cable Crunch", "sets": "3 x 15", "videoId": "taI4XduLpTk"},
        {"name": "Hanging Leg Raise", "sets": "3 x 12", "videoId": "Pr1ieGZ5atk"},
        {"name": "Russian Twist", "sets": "3 x 20", "videoId": "wkD8rjkodUI"},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Training Plans", style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _muscles.length,
        itemBuilder: (context, index) {
          final muscle = _muscles[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _MuscleDetailScreen(muscle: muscle)),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: muscle["color"] as Color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (muscle["accent"] as Color).withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: (muscle["accent"] as Color).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(muscle["icon"] as IconData, color: muscle["accent"] as Color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscle["name"] as String,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          "${(muscle["exercises"] as List).length} exercises",
                          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.6), size: 28),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Muscle Detail Screen ────────────────────────────────────────────────────
class _MuscleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> muscle;
  const _MuscleDetailScreen({required this.muscle});

  @override
  Widget build(BuildContext context) {
    final exercises = muscle["exercises"] as List;
    final accent = muscle["accent"] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        backgroundColor: muscle["color"] as Color,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${muscle["name"]} Training",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final ex = exercises[index] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Thumbnail Placeholder (YouTube embed via webview would go here)
                GestureDetector(
                  onTap: () {
                    // In a real app: launch YouTube URL
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Opening: ${ex["name"]} video..."), backgroundColor: accent),
                    );
                  },
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: muscle["color"] as Color,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.play_circle_fill_rounded, color: accent, size: 40),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Watch Tutorial",
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex["name"] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A)),
                            ),
                            const SizedBox(height: 4),
                            Text(ex["sets"] as String, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("Add to Plan", style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
