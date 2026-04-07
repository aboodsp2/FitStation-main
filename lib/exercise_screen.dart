import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ExerciseScreen extends StatelessWidget {
  final String muscleGroup;
  final String level;
  final String gender;

  const ExerciseScreen({
    super.key,
    required this.muscleGroup,
    required this.level,
    required this.gender,
  });

  // Map of all exercises per gender/level/muscle
  static const Map<String, Map<String, Map<String, List<Map<String, String>>>>> _exercises = {
    'male': {
      'beginner': {
        'chest': [
          {'name': 'Bench Press',    'video': 'assets/Mbeginner/chest/bench-press.mp4'},
          {'name': 'Chest Press',    'video': 'assets/Mbeginner/chest/chest-press.mp4'},
          {'name': 'Chest Stretch',  'video': 'assets/Mbeginner/chest/chest-stretch.mp4'},
          {'name': 'Push Up',        'video': 'assets/Mbeginner/chest/push-up.mp4'},
        ],
        'back': [
          {'name': 'Straight Seated Row', 'video': 'assets/Mbeginner/back/straight-seated-row.mp4'},
          {'name': 'Wheel Rollout',        'video': 'assets/Mbeginner/back/wheel-rollout.mp4'},
          {'name': 'Wide Pulldown',        'video': 'assets/Mbeginner/back/wide-pulldown.mp4'},
          {'name': 'Shrug',                'video': 'assets/Mbeginner/back/shrug.mp4'},
        ],
        'legs': [
          {'name': 'Seated Leg Curl', 'video': 'assets/Mbeginner/legs/seated-leg-curl.mp4'},
          {'name': 'Leg Extension',   'video': 'assets/Mbeginner/legs/leg-extension.mp4'},
          {'name': 'Seated Calf',     'video': 'assets/Mbeginner/legs/seated-calf.mp4'},
        ],
        'shoulders': [
          {'name': 'Lying Around The World', 'video': 'assets/Mbeginner/shoulders/lying-around-theworld.mp4'},
          {'name': 'Shoulder Press',          'video': 'assets/Mbeginner/shoulders/shoulder-press.mp4'},
          {'name': 'Lateral Shoulder',        'video': 'assets/Mbeginner/shoulders/lateral-shoulder.mp4'},
        ],
        'arms': [
          {'name': 'Alt Biceps',       'video': 'assets/Mbeginner/arms/alt-biceps.mp4'},
          {'name': 'Curl Biceps',      'video': 'assets/Mbeginner/arms/curl-biceps.mp4'},
          {'name': 'Triceps Pushdown', 'video': 'assets/Mbeginner/arms/triceps-pushdown.mp4'},
          {'name': 'Seated Bench',     'video': 'assets/Mbeginner/arms/seated-bench.mp4'},
        ],
        'core': [
          {'name': 'Lever Back',   'video': 'assets/Mbeginner/core/lever-back.mp4'},
          {'name': 'Lever Seated', 'video': 'assets/Mbeginner/core/lever-seated.mp4'},
          {'name': 'Yoga Cobra',   'video': 'assets/Mbeginner/core/yoga-cobra.mp4'},
        ],
      },
      // Add intermediate and advanced when you have the videos
      'intermediate': {},
      'advanced': {},
    },
    'female': {
      'beginner': {},
      'intermediate': {},
      'advanced': {},
    },
  };

  List<Map<String, String>> get _currentExercises {
    final g = gender.toLowerCase();
    final l = level.toLowerCase();
    final m = muscleGroup.toLowerCase();
    return _exercises[g]?[l]?[m] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _currentExercises;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${muscleGroup[0].toUpperCase()}${muscleGroup.substring(1)} Exercises',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${level[0].toUpperCase()}${level.substring(1)} • ${exercises.length} exercises',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center_rounded,
                      size: 64, color: Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises yet',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return _ExerciseCard(
                  exercise: exercises[index],
                  index: index,
                );
              },
            ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final Map<String, String> exercise;
  final int index;

  const _ExerciseCard({required this.exercise, required this.index});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isPlaying = false;
  bool _loading = false;

  static const List<List<Color>> _cardColors = [
    [Color(0xFF6C5CE7), Color(0xFF3A1F8F)],
    [Color(0xFF00B894), Color(0xFF006B55)],
    [Color(0xFFE17055), Color(0xFF8B3500)],
    [Color(0xFF0984E3), Color(0xFF024D87)],
    [Color(0xFFD63031), Color(0xFF7A0000)],
    [Color(0xFF00CEC9), Color(0xFF006A67)],
  ];

  List<Color> get _colors =>
      _cardColors[widget.index % _cardColors.length];

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initAndPlay() async {
    if (_initialized) {
      // Toggle play/pause
      if (_isPlaying) {
        await _controller!.pause();
        setState(() => _isPlaying = false);
      } else {
        await _controller!.play();
        setState(() => _isPlaying = true);
      }
      return;
    }

    setState(() => _loading = true);

    _controller = VideoPlayerController.asset(widget.exercise['video']!);
    await _controller!.initialize();
    _controller!.setLooping(true);
    await _controller!.play();

    if (mounted) {
      setState(() {
        _initialized = true;
        _isPlaying = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + widget.index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _colors[0].withOpacity(0.15),
              _colors[1].withOpacity(0.08),
            ],
          ),
          border: Border.all(color: _colors[0].withOpacity(0.3)),
        ),
        child: Column(
          children: [
            // ── Video player area ──
            GestureDetector(
              onTap: _initAndPlay,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black,
                  child: _loading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: _colors[0]))
                      : _initialized
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                AspectRatio(
                                  aspectRatio:
                                      _controller!.value.aspectRatio,
                                  child: VideoPlayer(_controller!),
                                ),
                                if (!_isPlaying)
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: _colors[0].withOpacity(0.85),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 32),
                                  ),
                              ],
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _colors[0].withOpacity(0.3),
                                        _colors[1].withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: _colors[0].withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: _colors[0], width: 2),
                                      ),
                                      child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: _colors[0],
                                          size: 34),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Tap to play',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.6),
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                ),
              ),
            ),

            // ── Exercise info ──
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: _colors),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.exercise['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_initialized)
                    GestureDetector(
                      onTap: _initAndPlay,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _colors[0].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _colors[0].withOpacity(0.3)),
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: _colors[0],
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
