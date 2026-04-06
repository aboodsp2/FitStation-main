import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';
import 'cart_screen.dart';

// ─── DATA MODEL ─────────────────────────────────────────────────────────────
class SupplementItem {
  final String id, name, category, unit, imageUrl;
  final double price;
  final double rating;
  final int quantity;

  const SupplementItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
    required this.rating,
    required this.quantity,
    this.imageUrl = '',
  });

  factory SupplementItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return SupplementItem(
      id:       doc.id,
      name:     d['name']     ?? '',
      category: d['category'] ?? '',
      unit:     d['unit']     ?? '',
      price:    (d['price']   ?? 0).toDouble(),
      rating:   (d['rating']  ?? 0).toDouble(),
      quantity: (d['quantity'] ?? 0) as int,
      imageUrl: d['imageUrl'] ?? '',
    );
  }
}

// ─── MAIN STORE SCREEN ──────────────────────────────────────────────────────
class SupplementStoreScreen extends StatefulWidget {
  const SupplementStoreScreen({super.key});
  @override State<SupplementStoreScreen> createState() =>
      _SupplementStoreScreenState();
}

class _SupplementStoreScreenState extends State<SupplementStoreScreen> {
  int _cartCount = 0;
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Categories in the order we want to display them
  static const _categories = [
    "Pre-Workouts",
    "Proteins & Recovery",
    "Mass Gainers",
    "Creatine & Performance",
    "Vitamins & Health",
    "Weight Loss",
  ];

  // Map Firestore category field values → display section name
  static const _catMap = {
    "Pre-Workout":          "Pre-Workouts",
    "Protein":              "Proteins & Recovery",
    "Recovery":             "Proteins & Recovery",
    "Mass Gainer":          "Mass Gainers",
    "Creatine":             "Creatine & Performance",
    "Vitamins":             "Vitamins & Health",
    "Weight Loss":          "Weight Loss",
  };

  @override
  void initState() {
    super.initState();
    CartManager().addListener(_onCart);
    _cartCount = CartManager().count;
  }
  @override
  void dispose() {
    CartManager().removeListener(_onCart);
    _searchCtrl.dispose();
    super.dispose();
  }
  void _onCart() { if (mounted) setState(() => _cartCount = CartManager().count); }

  void _addToCart(SupplementItem item) {
    CartManager().addItem(CartItem(
      id: item.id, name: item.name,
      price: item.price, quantity: 1,
      icon: Icons.science_rounded,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${item.name} added to cart",
          style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppTheme.primary,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supplements')
            .orderBy('name')
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                color: AppTheme.primary));
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}",
                style: AppTheme.body));
          }

          final all = (snap.data?.docs ?? [])
              .map(SupplementItem.fromFirestore)
              .toList();

          // Apply search filter
          final items = _query.isEmpty
              ? all
              : all.where((i) =>
                  i.name.toLowerCase().contains(_query.toLowerCase()) ||
                  i.category.toLowerCase().contains(_query.toLowerCase()))
                  .toList();

          // Group by display category
          final Map<String, List<SupplementItem>> grouped = {};
          for (final item in items) {
            final display = _catMap[item.category] ?? item.category;
            grouped.putIfAbsent(display, () => []).add(item);
          }

          return CustomScrollView(slivers: [
            // ── AppBar ──────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.dark),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text("STORE",
                    style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary, fontSize: 18,
                        letterSpacing: 2)),
              ]),
              actions: [
                // Search
                IconButton(
                  icon: Icon(
                    _query.isEmpty
                        ? Icons.search_rounded
                        : Icons.close_rounded,
                    color: AppTheme.dark),
                  onPressed: () {
                    if (_query.isNotEmpty) {
                      _searchCtrl.clear();
                      setState(() => _query = '');
                    } else {
                      _showSearch();
                    }
                  },
                ),
                // Cart with badge
                Stack(children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: AppTheme.dark),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                  if (_cartCount > 0)
                    Positioned(top: 6, right: 6,
                      child: Container(
                        width: 17, height: 17,
                        decoration: const BoxDecoration(
                            color: AppTheme.primary, shape: BoxShape.circle),
                        child: Center(child: Text(
                          _cartCount > 9 ? "9+" : "$_cartCount",
                          style: const TextStyle(color: Colors.white,
                              fontSize: 9, fontWeight: FontWeight.bold),
                        )),
                      )),
                ]),
                const SizedBox(width: 4),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: AppTheme.divider),
              ),
            ),

            // ── Hero banner ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _heroBanner()),

            // ── Search active: flat list ─────────────────────────────────
            if (_query.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(delegate: SliverChildBuilderDelegate(
                  (_, i) => _listTile(items[i]),
                  childCount: items.length,
                )),
              )
            else ...[
              // ── Category sections ────────────────────────────────────
              for (final cat in _categories)
                if (grouped.containsKey(cat))
                  SliverToBoxAdapter(
                    child: _categorySection(cat, grouped[cat]!),
                  ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ]);
        },
      ),
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────
  Widget _heroBanner() => Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    decoration: BoxDecoration(
      color: AppTheme.dark,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const Text("WE HAVE EVERYTHING\nYOU NEED FROM A-Z",
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white,
                fontWeight: FontWeight.w800, fontSize: 15, height: 1.3)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) =>
                  const _AllSupplementsScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Shop All",
                style: TextStyle(fontFamily: 'Poppins',
                    color: Colors.white, fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ),
      ])),
      const Icon(Icons.shopping_bag_outlined,
          color: Colors.white38, size: 60),
    ]),
  );

  // ── Category section with 3 items + View More ──────────────────────────
  Widget _categorySection(String title, List<SupplementItem> items) {
    final preview = items.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        // Section header
        Text(title.toUpperCase(),
            style: const TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w800, fontSize: 13,
                color: AppTheme.dark, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        // 3 items in a row
        Row(children: preview.map((item) =>
            Expanded(child: Padding(
              padding: EdgeInsets.only(
                  right: preview.indexOf(item) < 2 ? 8 : 0),
              child: _productCard(item),
            ))).toList()),
        const SizedBox(height: 12),
        // View More button
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => _CategoryScreen(category: title, allItems: items))),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Center(child: Text("VIEW MORE",
                style: TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, fontSize: 12,
                    color: AppTheme.primary, letterSpacing: 1.2))),
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: AppTheme.divider, height: 1),
      ]),
    );
  }

  // ── Product card (in section row) ─────────────────────────────────────
  Widget _productCard(SupplementItem item) => Container(
    decoration: AppTheme.card(radius: 14),
    padding: const EdgeInsets.all(10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // image or placeholder
      Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: item.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(item.imageUrl, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.science_rounded, color: AppTheme.accent, size: 36)))
            : Icon(Icons.science_rounded, color: AppTheme.accent, size: 36)),
      ),
      const SizedBox(height: 8),
      Text(item.name, maxLines: 2,
          style: const TextStyle(fontFamily: 'Poppins',
              fontWeight: FontWeight.w600, fontSize: 11,
              color: AppTheme.dark, height: 1.3)),
      const SizedBox(height: 4),
      Text("${item.price.toStringAsFixed(0)} JD",
          style: const TextStyle(fontFamily: 'Poppins',
              fontWeight: FontWeight.w700, fontSize: 12,
              color: AppTheme.primary)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => _addToCart(item),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Text("ADD TO CART",
              style: TextStyle(fontFamily: 'Poppins',
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: AppTheme.primary, letterSpacing: 0.8))),
        ),
      ),
    ]),
  );

  // ── List tile for search results ───────────────────────────────────────
  Widget _listTile(SupplementItem item) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: AppTheme.card(radius: 14),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: item.imageUrl.isNotEmpty
            ? ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.network(item.imageUrl, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.science_rounded, color: AppTheme.accent, size: 28)))
            : Icon(Icons.science_rounded, color: AppTheme.accent, size: 28),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Text(item.name, style: AppTheme.subheading.copyWith(fontSize: 14)),
        const SizedBox(height: 2),
        Text(item.unit, style: AppTheme.body.copyWith(fontSize: 12)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text("${item.price.toStringAsFixed(0)} JD",
            style: AppTheme.subheading.copyWith(
                color: AppTheme.primary, fontSize: 14)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _addToCart(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Add", style: TextStyle(fontFamily: 'Poppins',
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ]),
  );

  void _showSearch() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Search Supplements",
            style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: TextField(
          controller: _searchCtrl,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontFamily: 'Poppins'),
          decoration: AppTheme.inputDecoration(
              "Type product name...", Icons.search_rounded),
        ),
        actions: [
          TextButton(
            onPressed: () { Navigator.pop(context); },
            child: const Text("Done", style: TextStyle(
                fontFamily: 'Poppins', color: AppTheme.primary,
                fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── CATEGORY DETAIL SCREEN ──────────────────────────────────────────────────
class _CategoryScreen extends StatefulWidget {
  final String category;
  final List<SupplementItem> allItems;
  const _CategoryScreen({required this.category, required this.allItems});
  @override State<_CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<_CategoryScreen> {
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    CartManager().addListener(_onCart);
    _cartCount = CartManager().count;
  }
  @override void dispose() { CartManager().removeListener(_onCart); super.dispose(); }
  void _onCart() { if (mounted) setState(() => _cartCount = CartManager().count); }

  void _addToCart(SupplementItem item) {
    CartManager().addItem(CartItem(
      id: item.id, name: item.name,
      price: item.price, quantity: 1,
      icon: Icons.science_rounded,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${item.name} added to cart",
          style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppTheme.primary,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

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
        title: Text(widget.category,
            style: const TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.dark)),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.dark),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
            if (_cartCount > 0)
              Positioned(top: 6, right: 6,
                child: Container(width: 17, height: 17,
                  decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  child: Center(child: Text(
                    _cartCount > 9 ? "9+" : "$_cartCount",
                    style: const TextStyle(color: Colors.white,
                        fontSize: 9, fontWeight: FontWeight.bold),
                  )))),
          ]),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.allItems.length,
        itemBuilder: (_, i) => _detailCard(widget.allItems[i]),
      ),
    );
  }

  // Detailed card matching screenshot 4 style
  Widget _detailCard(SupplementItem item) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: AppTheme.card(radius: 18),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // image
      Container(
        width: 110, height: 130,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
        ),
        child: item.imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: Image.network(item.imageUrl, fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.science_rounded, color: AppTheme.accent, size: 46)))
            : Icon(Icons.science_rounded, color: AppTheme.accent, size: 46),
      ),
      // details
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name,
                style: const TextStyle(fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700, fontSize: 13,
                    color: AppTheme.dark, height: 1.3)),
            const SizedBox(height: 4),
            Text(item.unit,
                style: AppTheme.body.copyWith(fontSize: 12)),
            const SizedBox(height: 4),
            // rating
            Row(children: [
              ...List.generate(5, (i) => Icon(
                i < item.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: AppTheme.accent, size: 14)),
              const SizedBox(width: 4),
              Text("(${item.rating})",
                  style: AppTheme.body.copyWith(fontSize: 11)),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("${item.price.toStringAsFixed(0)} JD",
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800, fontSize: 15,
                      color: AppTheme.primary)),
              GestureDetector(
                onTap: () => _addToCart(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("BUY NOW",
                      style: TextStyle(fontFamily: 'Poppins',
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    ]),
  );
}

// ─── ALL SUPPLEMENTS SCREEN ──────────────────────────────────────────────────
class _AllSupplementsScreen extends StatefulWidget {
  const _AllSupplementsScreen();
  @override State<_AllSupplementsScreen> createState() =>
      _AllSupplementsScreenState();
}

class _AllSupplementsScreenState extends State<_AllSupplementsScreen> {
  int _cartCount = 0;
  @override
  void initState() {
    super.initState();
    CartManager().addListener(_onCart);
    _cartCount = CartManager().count;
  }
  @override void dispose() { CartManager().removeListener(_onCart); super.dispose(); }
  void _onCart() { if (mounted) setState(() => _cartCount = CartManager().count); }

  void _addToCart(SupplementItem item) {
    CartManager().addItem(CartItem(
      id: item.id, name: item.name,
      price: item.price, quantity: 1,
      icon: Icons.science_rounded,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${item.name} added to cart",
          style: const TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppTheme.primary,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("All Products",
            style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w700, fontSize: 17, color: AppTheme.dark)),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.dark),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CartScreen())),
            ),
            if (_cartCount > 0)
              Positioned(top: 6, right: 6,
                child: Container(width: 17, height: 17,
                  decoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  child: Center(child: Text(
                    _cartCount > 9 ? "9+" : "$_cartCount",
                    style: const TextStyle(color: Colors.white,
                        fontSize: 9, fontWeight: FontWeight.bold),
                  )))),
          ]),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supplements')
            .orderBy('name')
            .snapshots(),
        builder: (_, snap) {
          if (!snap.hasData) return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
          final items = snap.data!.docs
              .map(SupplementItem.fromFirestore).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: AppTheme.card(radius: 16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Container(
                    width: 100, height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: item.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Image.network(item.imageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                    Icons.science_rounded,
                                    color: AppTheme.accent, size: 40)))
                        : Icon(Icons.science_rounded,
                            color: AppTheme.accent, size: 40),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.name, style: const TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                          fontSize: 13, color: AppTheme.dark, height: 1.3)),
                      const SizedBox(height: 3),
                      Text(item.unit, style: AppTheme.body.copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        Text("${item.price.toStringAsFixed(0)} JD",
                            style: const TextStyle(fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800, fontSize: 14,
                                color: AppTheme.primary)),
                        GestureDetector(
                          onTap: () => _addToCart(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text("ADD",
                                style: TextStyle(fontFamily: 'Poppins',
                                    color: Colors.white, fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ]),
                    ]),
                  )),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
