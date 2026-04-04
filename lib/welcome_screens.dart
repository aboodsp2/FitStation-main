import 'package:fitness_app/profile_form_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreens extends StatefulWidget {
  const WelcomeScreens({super.key});

  @override
  State<WelcomeScreens> createState() => _WelcomeScreensState();
}

class _WelcomeScreensState extends State<WelcomeScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On the last screen, go to the dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileFormScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              _WelcomeSlide(
                title: "Welcome to FitStation",
                description: "Your personalized fitness journey starts here.",
                icon: Icons.fitness_center,
              ),
              _WelcomeSlide(
                title: "Track Your Progress",
                description:
                    "Monitor your workouts and see your improvements daily.",
                icon: Icons.auto_graph,
              ),
              _WelcomeSlide(
                title: "Achieve Your Goals",
                description: "Let's move together and smash those targets!",
                icon: Icons.emoji_events,
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  _currentPage == 2 ? "GET STARTED" : "NEXT",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSlide extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _WelcomeSlide({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 120, color: Colors.pink),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 80), // Space for the button at the bottom
        ],
      ),
    );
  }
}
