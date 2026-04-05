import 'package:fitness_app/welcome_screens.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthFlowHandler extends StatefulWidget {
  const AuthFlowHandler({super.key});

  @override
  State<AuthFlowHandler> createState() => _AuthFlowHandlerState();
}

class _AuthFlowHandlerState extends State<AuthFlowHandler> {
  final PageController _pageController = PageController();
  String _tempName = "";

  void _navigateTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          IntroPage(onGetStarted: () => _navigateTo(1)),
          SignInPage(onSignUpTap: () => _navigateTo(2)),
          SignUpPage(
            onLoginTap: () => _navigateTo(1),
            onVerificationSent: (name) {
              setState(() {
                _tempName = name;
              });
              _navigateTo(3);
            },
            // Navigate to Verify Page
          ),
          VerifyEmailPage(
            onBackToLogin: () => _navigateTo(2),
            fullName: _tempName,
          ),
        ],
      ),
    );
  }
}

class VerifyEmailPage extends StatelessWidget {
  final VoidCallback onBackToLogin;
  final String fullName;

  const VerifyEmailPage({
    super.key,
    required this.onBackToLogin,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black, // Matches screenshot
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () async {
            await user?.delete();
            onBackToLogin();
          }, // Takes you back to Login
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.mark_email_unread_outlined,
              color: Colors.pink,
              size: 100,
            ),
            const SizedBox(height: 40),
            const Text(
              "Verify Your Email",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "We've sent a verification link to:\n${user?.email ?? 'your email'}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 50),
            _Button(
              label: "I'VE VERIFIED MY EMAIL",
              color: Colors.pink, // Brand color from screenshot
              textColor: Colors.white,
              onTap: () async {
                await user?.reload(); // Refresh user state
                final updatedUser = FirebaseAuth.instance.currentUser;

                if (updatedUser?.emailVerified ?? false) {
                  // SUCCESS: Email is verified, now write to Firestore

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(updatedUser!.uid)
                      .set({
                        'name': fullName, // This will now have the actual name
                        'email': updatedUser.email,
                        'createdAt': FieldValue.serverTimestamp(),
                        'isVerified': true,
                      });

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreens()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("PLease verify your email first ."),
                      ),
                    );
                  }
                } else {
                  // FAIL: Still not verified
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Email not verified yet. Please check your inbox.",
                        ),
                      ),
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 30),
            TextButton(
              onPressed: () => user?.sendEmailVerification(),
              child: const Text(
                "Didn't receive it? Resend Email",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- INTRO SCREEN ---
class IntroPage extends StatefulWidget {
  final VoidCallback onGetStarted;
  const IntroPage({super.key, required this.onGetStarted});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        _controller.setVolume(0);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : Container(color: Colors.black),
        ),
        Container(color: Colors.black26),
        Column(
          children: [
            const SizedBox(height: 60),
            _LogoHeader(),
            const Spacer(),
            const Text(
              "LET'S MOVE",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const Text(
              "Fitness and wellness for\nyou anytime, anywhere.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 30),
            _Button(
              label: "GET STARTED",
              color: Colors.white,
              textColor: Colors.black,
              onTap: widget.onGetStarted,
            ),
            const SizedBox(height: 60),
          ],
        ),
      ],
    );
  }
}

// --- SIGN IN SCREEN ---
class SignInPage extends StatefulWidget {
  final VoidCallback onSignUpTap;
  const SignInPage({super.key, required this.onSignUpTap});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthBg(
      image: 'assets/Sign_in.jpg',
      child: SingleChildScrollView(
        // This ensures that even if the keyboard opens, everything stays reachable
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _LogoHeader(),
              const SizedBox(height: 80),
              const Text(
                "LOG IN",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              _Input(
                icon: Icons.email_outlined,
                hint: "Email",
                controller: _emailController,
              ),
              _Input(
                icon: Icons.lock_outline,
                hint: "Password",
                isPass: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 30),

              // PRIMARY LOGIN BUTTON
              _Button(
                label: "LOG IN",
                color: Colors.black,
                textColor: Colors.white,
                onTap: _login,
              ),

              const SizedBox(height: 15),

              // GUEST BUTTON (Moved up and styled for better visibility)
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Continue as Guest",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: widget.onSignUpTap,
                child: const Text(
                  "Don't have an account? SIGN UP",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SIGN UP SCREEN ---
class SignUpPage extends StatefulWidget {
  final VoidCallback onLoginTap;
  final Function(String) onVerificationSent;
  const SignUpPage({
    super.key,
    required this.onLoginTap,
    required this.onVerificationSent,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await userCredential.user?.sendEmailVerification();
      widget.onVerificationSent(_nameController.text.trim());
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Sign Up Failed")));
    } catch (e) {
      print("Firestore Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthBg(
      image: 'assets/Sign_up.jpg',
      child: Stack(
        children: [
          // 1. THE CONTENT (Form)
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                _LogoHeader(),
                const SizedBox(height: 80),
                const Text(
                  "SIGN UP",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _Input(
                  icon: Icons.person_outline,
                  hint: "Full Name",
                  controller: _nameController,
                ),
                _Input(
                  icon: Icons.email_outlined,
                  hint: "Email",
                  controller: _emailController,
                ),
                _Input(
                  icon: Icons.lock_outline,
                  hint: "Password",
                  isPass: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 30),
                _Button(
                  label: "SIGN UP",
                  color: Colors.black,
                  textColor: Colors.white,
                  onTap: _signUp,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),

          // 2. THE BACK ARROW (Placed last in Stack to be on top)
          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed:
                    widget.onLoginTap, // This triggers the slide back to page 1
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---
class _LogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.change_history, color: Colors.pink, size: 30),
        const SizedBox(width: 10),
        const Text(
          "FITSTATION",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool isPass;
  final TextEditingController controller;
  const _Input({
    required this.icon,
    required this.hint,
    this.isPass = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.black45,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  const _Button({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class _AuthBg extends StatelessWidget {
  final String image;
  final Widget child;
  const _AuthBg({required this.image, required this.child});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(child: Image.asset(image, fit: BoxFit.cover)),
        Container(color: Colors.black38),
        SafeArea(child: child),
      ],
    );
  }
}
