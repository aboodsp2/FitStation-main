import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_screen.dart';
import 'training_screen.dart';
import 'supplement_store_screen.dart';
import 'meal_plan_screen.dart';
import 'consultation_screen.dart';
import 'cart_screen.dart';
import 'about_screen.dart';
import 'profile_screen.dart';

// ─── GLOBAL CART STATE ──────────────────────────────────────────────────────
class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> items = [];
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) => _listeners.add(listener);
  void removeListener(VoidCallback listener) => _listeners.remove(listener);
  void _notify() {
    for (final l in _listeners) l();
  }

  void addItem(CartItem item) {
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      items[idx] = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: items[idx].quantity + 1,
        icon: item.icon,
      );
    } else {
      items.add(item);
    }
    _notify();
  }

  void removeItem(String id) {
    items.removeWhere((i) => i.id == id);
    _notify();
  }

  void updateQuantity(String id, int qty) {
    final idx = items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      if (qty <= 0) {
        items.removeAt(idx);
      } else {
        items[idx] = CartItem(
          id: items[idx].id,
          name: items[idx].name,
          price: items[idx].price,
          quantity: qty,
          icon: items[idx].icon,
        );
      }
    }
    _notify();
  }

  double get total => items.fold(0, (sum, i) => sum + i.price * i.quantity);
  int get count => items.fold(0, (sum, i) => sum + i.quantity);
}

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final IconData icon;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.icon,
  });
}

// ─── DASHBOARD ──────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _cartCount = 0;

  static const Color backgroundBeige = Color(0xFFF8F4EF);
  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    CartManager().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartManager().removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() => _cartCount = CartManager().count);
  }

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
                _buildHomeTab(),
                const AboutScreen(),
                CartScreen(),
                const ProfileSection(),
              ],
            ),
            _buildFloatingBottomNavBar(),
          ],
        ),
      ),
    );
  }

  // ── HOME TAB ──────────────────────────────────────────────────────────────
  Widget _buildHomeTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 10),
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 25),
        _buildPromoBanner(),
        const SizedBox(height: 25),
        const Text(
          "Explore",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 15),
        _buildProductGrid(),
        const SizedBox(height: 100),
      ],
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        String name = "User";
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['name'] ?? "User";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryOrange, Color(0xFFFF5A00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hey, $name 👋",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: darkText,
                      ),
                    ),
                    const Text(
                      "Let's crush today's goals",
                      style: TextStyle(color: Colors.black45, fontSize: 13),
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
                    MaterialPageRoute(builder: (context) => const AuthFlowHandler()),
                    (route) => false,
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.logout_rounded, color: darkText, size: 22),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── SEARCH BAR (no filter icon — Change 1) ───────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.black38, size: 22),
          SizedBox(width: 12),
          Text(
            "Search plans, supplements...",
            style: TextStyle(color: Colors.black38, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── PROMO BANNER ──────────────────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF37E33), Color(0xFFFF5A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: primaryOrange.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "LIMITED OFFER",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "20% Off\nFresh Plans",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Shop Now",
                    style: TextStyle(
                      color: primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_fire_department_rounded, size: 90, color: Colors.white24),
        ],
      ),
    );
  }

  // ── PRODUCT GRID (Change 6 — tappable cards) ─────────────────────────────
  Widget _buildProductGrid() {
    final List<Map<String, dynamic>> items = [
      {
        "title": "Training Plan",
        "sub": "By Muscle Group",
        "icon": Icons.fitness_center_rounded,
        "color": const Color(0xFF1A1A2E),
        "accent": const Color(0xFF4361EE),
      },
      {
        "title": "Supplements",
        "sub": "Elite Store",
        "icon": Icons.science_rounded,
        "color": const Color(0xFF0F3460),
        "accent": const Color(0xFF00B4D8),
      },
      {
        "title": "Meal Plan",
        "sub": "Custom Diet",
        "icon": Icons.restaurant_menu_rounded,
        "color": const Color(0xFF1B4332),
        "accent": const Color(0xFF52B788),
      },
      {
        "title": "Consultation",
        "sub": "Book a Session",
        "icon": Icons.video_call_rounded,
        "color": const Color(0xFF4A0E8F),
        "accent": const Color(0xFFC77DFF),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Widget screen;
            switch (index) {
              case 0:
                screen = const TrainingScreen();
                break;
              case 1:
                screen = const SupplementStoreScreen();
                break;
              case 2:
                screen = const MealPlanScreen();
                break;
              case 3:
                screen = const ConsultationScreen();
                break;
              default:
                return;
            }
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          },
          child: Container(
            decoration: BoxDecoration(
              color: item["color"],
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (item["accent"] as Color).withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (item["accent"] as Color).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item["icon"] as IconData, color: item["accent"] as Color, size: 26),
                ),
                const Spacer(),
                Text(
                  item["title"] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item["sub"] as String,
                  style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (item["accent"] as Color).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded, color: item["accent"] as Color, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── NAV BAR (Change 4 — cart icon with badge) ────────────────────────────
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
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(0, Icons.home_rounded),
            _navIcon(1, Icons.info_outline_rounded),
            _navIconWithBadge(2, Icons.shopping_cart_outlined, _cartCount),
            _navIcon(3, Icons.person_outline_rounded),
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
          color: isSelected ? const Color(0xFFF37E33).withOpacity(0.12) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFF37E33) : Colors.black38,
          size: 28,
        ),
      ),
    );
  }

  Widget _navIconWithBadge(int index, IconData icon, int count) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFF37E33).withOpacity(0.12) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFFF37E33) : Colors.black38,
              size: 28,
            ),
          ),
          if (count > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFFF37E33),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count > 9 ? "9+" : "$count",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
