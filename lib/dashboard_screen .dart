import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
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

  void addListener(VoidCallback l)    => _listeners.add(l);
  void removeListener(VoidCallback l) => _listeners.remove(l);
  void _notify() { for (final l in _listeners) l(); }

  void addItem(CartItem item) {
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      items[idx] = CartItem(id: item.id, name: item.name, price: item.price,
          quantity: items[idx].quantity + 1, icon: item.icon);
    } else {
      items.add(item);
    }
    _notify();
  }

  void removeItem(String id) { items.removeWhere((i) => i.id == id); _notify(); }

  void updateQuantity(String id, int qty) {
    final idx = items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      if (qty <= 0) { items.removeAt(idx); }
      else {
        items[idx] = CartItem(id: items[idx].id, name: items[idx].name,
            price: items[idx].price, quantity: qty, icon: items[idx].icon);
      }
      _notify();
    }
  }

  double get total => items.fold(0, (s, i) => s + i.price * i.quantity);
  int    get count => items.fold(0, (s, i) => s + i.quantity);
}

class CartItem {
  final String id, name;
  final double price;
  final int quantity;
  final IconData icon;
  const CartItem({required this.id, required this.name, required this.price,
      required this.quantity, required this.icon});
}

// ─── DASHBOARD SHELL ────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab      = 0;
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    CartManager().addListener(_onCart);
  }
  @override
  void dispose() {
    CartManager().removeListener(_onCart);
    super.dispose();
  }
  void _onCart() { if (mounted) setState(() => _cartCount = CartManager().count); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          IndexedStack(index: _tab, children: [
            _HomeTab(onNavToCart: () => setState(() => _tab = 2)),
            const AboutScreen(),
            const CartScreen(),
            const ProfileSection(),
          ]),
          _nav(),
        ]),
      ),
    );
  }

  Widget _nav() => Positioned(
    bottom: 20, left: 20, right: 20,
    child: Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.12),
            blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _ni(0, Icons.home_rounded),
        _ni(1, Icons.info_outline_rounded),
        _nb(2, Icons.shopping_cart_outlined, _cartCount),
        _ni(3, Icons.person_outline_rounded),
      ]),
    ),
  );

  Widget _ni(int index, IconData icon) {
    final sel = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: sel ? AppTheme.primary : AppTheme.muted, size: 26),
      ),
    );
  }

  Widget _nb(int index, IconData icon, int count) {
    final sel = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: sel ? AppTheme.primary : AppTheme.muted, size: 26),
        ),
        if (count > 0)
          Positioned(top: 4, right: 4,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              child: Center(child: Text(count > 9 ? "9+" : "$count",
                  style: const TextStyle(color: Colors.white, fontSize: 10,
                      fontWeight: FontWeight.bold))),
            )),
      ]),
    );
  }
}

// ─── HOME TAB ───────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final VoidCallback onNavToCart;
  const _HomeTab({required this.onNavToCart});
  @override State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _searchCtrl = TextEditingController();
  String _query  = '';
  int _bannerIdx = 0;
  late final PageController _bannerCtrl;
  Timer? _timer;

  static const _banners = [
    {"tag": "LIMITED OFFER",  "title": "20% Off\nFresh Plans",   "btn": "Shop Now",  "icon": Icons.local_fire_department_rounded},
    {"tag": "NEW ARRIVALS",   "title": "Elite\nSupplements",     "btn": "Explore",   "icon": Icons.science_rounded},
    {"tag": "BOOK NOW",       "title": "1-on-1\nConsultation",   "btn": "Reserve",   "icon": Icons.video_call_rounded},
  ];

  static const _allItems = [
    {"title": "Training Plan", "sub": "By Muscle Group", "icon": Icons.fitness_center_rounded,  "idx": 0},
    {"title": "Supplements",   "sub": "Elite Store",     "icon": Icons.science_rounded,          "idx": 1},
    {"title": "Meal Plan",     "sub": "Custom Diet",     "icon": Icons.restaurant_menu_rounded,  "idx": 2},
    {"title": "Consultation",  "sub": "Book a Session",  "icon": Icons.video_call_rounded,       "idx": 3},
  ];

  List<Map<String, dynamic>> get _filtered => _query.isEmpty
      ? List.from(_allItems)
      : _allItems.where((i) =>
          i['title']!.toString().toLowerCase().contains(_query.toLowerCase()) ||
          i['sub']!.toString().toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  void initState() {
    super.initState();
    _bannerCtrl = PageController();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_bannerIdx + 1) % _banners.length;
      _bannerCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bannerCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      children: [
        const SizedBox(height: 12),
        _header(),
        const SizedBox(height: 20),
        _searchBar(),
        const SizedBox(height: 24),
        _banner(),
        const SizedBox(height: 26),
        Text("Explore", style: AppTheme.subheading.copyWith(fontSize: 18)),
        const SizedBox(height: 14),
        _grid(),
        const SizedBox(height: 110),
      ],
    );
  }

  // ── Header with profile photo ────────────────────────────────────────────
  Widget _header() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (ctx, snap) {
        String name = "User";
        String? photoUrl;
        if (snap.hasData && snap.data!.exists) {
          final d = snap.data!.data() as Map<String, dynamic>;
          name     = d['name']     ?? "User";
          photoUrl = d['photoUrl'];
        }
        return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            // avatar — shows photo if saved
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withOpacity(0.35), width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: photoUrl != null
                    ? Image.network(photoUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person_rounded, color: AppTheme.primary, size: 26))
                    : Icon(Icons.person_rounded, color: AppTheme.primary, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Hey, $name 👋", style: AppTheme.subheading.copyWith(fontSize: 17)),
              Text("Let's crush today's goals",
                  style: AppTheme.body.copyWith(fontSize: 13)),
            ]),
          ]),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (ctx.mounted) Navigator.of(ctx).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthFlowHandler()), (_) => false);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.card(radius: 14),
              child: Icon(Icons.logout_rounded, color: AppTheme.primary, size: 21),
            ),
          ),
        ]);
      },
    );
  }

  // ── Search bar (functional) ──────────────────────────────────────────────
  Widget _searchBar() => Container(
    height: 52,
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.divider),
      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.05),
          blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v),
      style: TextStyle(color: AppTheme.dark, fontSize: 14),
      decoration: InputDecoration(
        hintText: "Search plans, supplements...",
        hintStyle: TextStyle(color: AppTheme.muted, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.muted, size: 22),
        suffixIcon: _query.isNotEmpty
            ? GestureDetector(
                onTap: () { _searchCtrl.clear(); setState(() => _query = ''); },
                child: Icon(Icons.close_rounded, color: AppTheme.muted, size: 20))
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    ),
  );

  // ── Banner — 3 slides, fixed height, no overflow ─────────────────────────
  Widget _banner() => Column(children: [
    SizedBox(
      height: 158,
      child: PageView.builder(
        controller: _bannerCtrl,
        itemCount: _banners.length,
        onPageChanged: (i) => setState(() => _bannerIdx = i),
        itemBuilder: (_, i) {
          final b = _banners[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.28),
                  blurRadius: 16, offset: const Offset(0, 6))],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(b["tag"] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 7),
                  Text(b["title"] as String,
                      style: const TextStyle(color: Colors.white, fontSize: 19,
                          fontWeight: FontWeight.bold, height: 1.25)),
                  const SizedBox(height: 11),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(b["btn"] as String,
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              )),
              Icon(b["icon"] as IconData, size: 68,
                  color: Colors.white.withOpacity(0.12)),
            ]),
          );
        },
      ),
    ),
    const SizedBox(height: 10),
    // dot indicators
    Row(mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _bannerIdx == i ? 20 : 6, height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: _bannerIdx == i
              ? AppTheme.primary
              : AppTheme.accent.withOpacity(0.35),
          borderRadius: BorderRadius.circular(10),
        ),
      ))),
  ]);

  // ── Grid ─────────────────────────────────────────────────────────────────
  Widget _grid() {
    final list = _filtered;
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(child: Text('No results for "$_query"',
            style: AppTheme.body.copyWith(fontSize: 15))),
      );
    }

    const screens = <Widget>[
      TrainingScreen(),
      SupplementStoreScreen(),
      MealPlanScreen(),
      ConsultationScreen(),
    ];

    const cardGradients = [
      [Color(0xFF3B2314), Color(0xFF7B5035)],
      [Color(0xFF1C2A1E), Color(0xFF3A5C3E)],
      [Color(0xFF2A1C0E), Color(0xFF6B4C2A)],
      [Color(0xFF1A1A2A), Color(0xFF3D3460)],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.92,
        crossAxisSpacing: 14, mainAxisSpacing: 14,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final item = list[i];
        final idx  = item["idx"] as int;
        final cols = cardGradients[idx % cardGradients.length];
        return GestureDetector(
          onTap: () => Navigator.push(ctx,
              MaterialPageRoute(builder: (_) => screens[idx])),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: cols,
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: cols[0].withOpacity(0.35),
                  blurRadius: 14, offset: const Offset(0, 5))],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(item["icon"] as IconData,
                    color: AppTheme.accent, size: 24),
              ),
              const Spacer(),
              Text(item["title"] as String,
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 3),
              Text(item["sub"] as String,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: AppTheme.accent, size: 16),
                )),
            ]),
          ),
        );
      },
    );
  }
}
