import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const Color backgroundBeige = Color(0xFFFDF7F2);
  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBeige,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHomeTab(), // This is the method that was "missing"
                const Center(child: Text("About & Contact")),
                const Center(child: Text("Favorites")),
                const ProfileSection(), // This is the new Profile UI we created
              ],
            ),
            _buildFloatingBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // --- HOME TAB METHOD ---
  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildHeader(), // Dynamic header with User Name
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 25),
        _buildPromoBanner(),
        const SizedBox(height: 25),
        _buildProductGrid(),
        const SizedBox(height: 100),
      ],
    );
  }

  // --- DYNAMIC HEADER ---
  Widget _buildHeader() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        String name = "User";
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? "User";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hey, $name 👋", // Shows name from Firestore
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkText,
                      ),
                    ),
                    const Text(
                      "Good Morning",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const AuthFlowHandler(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: darkText, size: 22),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- SEARCH BAR ---
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.black26),
                SizedBox(width: 10),
                Text(
                  "Search",
                  style: TextStyle(color: Colors.black26, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.tune, color: darkText),
        ),
      ],
    );
  }

  // --- PROMO BANNER ---
  Widget _buildPromoBanner() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hurry Up! Get 20% Off",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            "Fresh Plans Everyday\nFrom FitStation",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Shop Now",
              style: TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- PRODUCT GRID ---
  Widget _buildProductGrid() {
    final List<Map<String, String>> items = [
      {"title": "Training Plan", "sub": "12 Weeks"},
      {"title": "Supplements", "sub": "Elite Range"},
      {"title": "Meal Plan", "sub": "Custom Diet"},
      {"title": "Consultation", "sub": "Pro Advice"},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                items[index]["title"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                items[index]["sub"]!,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$30",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                  Icon(Icons.add_circle, color: primaryOrange),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // --- NAV BAR ---
  Widget _buildFloatingBottomNavBar() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(0, Icons.home_filled),
            _navIcon(1, Icons.info_outline),
            _navIcon(2, Icons.favorite_border),
            _navIcon(3, Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(int index, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryOrange.withOpacity(0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? primaryOrange : Colors.black45,
          size: 28,
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Column(
          children: [
            ListTile(
              title: const Text("Goal"),
              subtitle: Text(data['goal'] ?? "Not set"),
            ),
            ListTile(
              title: const Text("Nationality"),
              subtitle: Text(data['nationality'] ?? "Not set"),
            ),
            ListTile(
              title: const Text("Stats"),
              subtitle: Text("${data['height']}cm | ${data['weight']}kg"),
            ),
          ],
        );
      },
    );
  }
}
