import 'package:flutter/material.dart';
import 'exercise_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingPlanScreen extends StatefulWidget {
  final String level;
  final String gender;

  const TrainingPlanScreen({
    super.key,
    required this.level,
    required this.gender,
  });

  @override
  State<TrainingPlanScreen> createState() => _TrainingPlanScreenState();
}

class _TrainingPlanScreenState extends State<TrainingPlanScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _muscleGroups = [];
  bool _loading = true;
  String? _error;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Colors per level
  Map<String, List<Color>> get _levelColors => {
    'beginner': [const Color(0xFF2ECC71), const Color(0xFF1A7A45)],
    'intermediate': [const Color(0xFFF39C12), const Color(0xFF9A5E00)],
    'advanced': [const Color(0xFFE74C3C), const Color(0xFF8B0000)],
  };

  List<Color> get _accentColors =>
      _levelColors[widget.level] ??
      [const Color(0xFFF39C12), const Color(0xFF9A5E00)];

  // Icon mapping per muscle group
  static const Map<String, IconData> _muscleIcons = {
    'chest': Icons.airline_seat_flat_rounded,
    'back': Icons.accessibility_new_rounded,
    'legs': Icons.directions_run_rounded,
    'shoulders': Icons.sports_gymnastics_rounded,
    'arms': Icons.sports_handball_rounded,
    'core': Icons.crop_square_rounded,
    'default': Icons.fitness_center_rounded,
  };

  // Color palette for muscle group cards
  static const List<List<Color>> _cardPalette = [
    [Color(0xFF6C5CE7), Color(0xFF3A1F8F)],
    [Color(0xFF00B894), Color(0xFF006B55)],
    [Color(0xFFE17055), Color(0xFF8B3500)],
    [Color(0xFF0984E3), Color(0xFF024D87)],
    [Color(0xFFD63031), Color(0xFF7A0000)],
    [Color(0xFF00CEC9), Color(0xFF006A67)],
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _loadMuscleGroups();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMuscleGroups() async {
    try {
      // ── Firestore path: training_plans/{gender}/{level}/muscle_groups (collection)
      // Each doc: { name: "Chest", exerciseCount: 4, exercises: [...] }
      // Adjust the path below to match YOUR Firestore structure.
      final snapshot = await FirebaseFirestore.instance
          .collection('training_plans')
          .doc(widget.gender)
          .collection(widget.level)
          .get();

      if (snapshot.docs.isEmpty) {
        // Fallback: try a flat collection with filtering
        final fallback = await FirebaseFirestore.instance
            .collection('training_plans')
            .where('gender', isEqualTo: widget.gender)
            .where('level', isEqualTo: widget.level)
            .get();

        setState(() {
          _muscleGroups = fallback.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
          _loading = false;
        });
      } else {
        setState(() {
          _muscleGroups = snapshot.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
          _loading = false;
        });
      }

      _fadeController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String get _levelLabel {
    switch (widget.level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return widget.level;
    }
  }

  IconData _iconForMuscle(String name) {
    return _muscleIcons[name.toLowerCase()] ?? _muscleIcons['default']!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFF39C12)),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_muscleGroups.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMuscleCard(index),
                  childCount: _muscleGroups.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$_levelLabel Plan',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              '${widget.gender == 'female' ? 'Women' : 'Men'} • ${_muscleGroups.length} muscle groups',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.55),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _accentColors[0].withOpacity(0.2),
                    const Color(0xFF0D0D0D),
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _accentColors[0].withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: _accentColors),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColors[0].withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  _levelLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleCard(int index) {
    final group = _muscleGroups[index];
    final name =
        (group['name'] as String?) ?? group['id'] as String? ?? 'Unknown';
    final exerciseCount = group['exerciseCount'] as int? ?? 0;
    final colors = _cardPalette[index % _cardPalette.length];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _MuscleGroupCard(
          name: name,
          exerciseCount: exerciseCount,
          icon: _iconForMuscle(name),
          colors: colors,
          onTap: () => _onGroupTap(group),
        ),
      ),
    );
  }

  void _onGroupTap(Map<String, dynamic> group) {
    final name = (group['name'] as String? ?? group['id'] as String? ?? '').toLowerCase();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseScreen(
          muscleGroup: name,
          level: widget.level,
          gender: widget.gender,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load plans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() => _loading = true);
                _loadMuscleGroups();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColors[0],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: 72,
              color: _accentColors[0].withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'No plans yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No ${_levelLabel.toLowerCase()} plans found for ${widget.gender == 'female' ? 'women' : 'men'} yet.\nCheck back soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────
// Muscle Group Card Widget
// ──────────────────────────────────────────────────────────────────

class _MuscleGroupCard extends StatefulWidget {
  final String name;
  final int exerciseCount;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _MuscleGroupCard({
    required this.name,
    required this.exerciseCount,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_MuscleGroupCard> createState() => _MuscleGroupCardState();
}

class _MuscleGroupCardState extends State<_MuscleGroupCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) =>
            Transform.scale(scale: _ctrl.value, child: child),
        child: Container(
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.colors[0].withOpacity(0.18),
                widget.colors[1].withOpacity(0.08),
              ],
            ),
            border: Border.all(color: widget.colors[0].withOpacity(0.25)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Shine shimmer
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.colors[0].withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.colors,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: widget.colors[0].withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 16),
                      // Text
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.colors[0],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.exerciseCount} exercises',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.55),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: widget.colors[0].withOpacity(0.12),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: widget.colors[0].withOpacity(0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: widget.colors[0],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
