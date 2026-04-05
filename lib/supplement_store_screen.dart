import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';
import 'cart_screen.dart';

class SupplementStoreScreen extends StatefulWidget {
  const SupplementStoreScreen({super.key});
  @override State<SupplementStoreScreen> createState() => _SupplementStoreScreenState();
}

class _SupplementStoreScreenState extends State<SupplementStoreScreen> {
  String _cat = "All";
  int _cartCount = 0;

  final _cats = ["All", "Protein", "Pre-Workout", "Vitamins",
      "Recovery", "Weight Loss", "Creatine"];

  final _products = const [
    {"name": "Whey Protein Gold",    "cat": "Protein",     "price": 49.99, "unit": "2.27 kg", "icon": Icons.sports_bar_rounded,          "c1": Color(0xFF3B2314), "c2": Color(0xFF7B5035)},
    {"name": "Casein Night Protein", "cat": "Protein",     "price": 39.99, "unit": "907 g",   "icon": Icons.bedtime_rounded,             "c1": Color(0xFF1C2A1E), "c2": Color(0xFF3A5C3E)},
    {"name": "Pre-Workout Extreme",  "cat": "Pre-Workout", "price": 34.99, "unit": "300 g",   "icon": Icons.bolt_rounded,                "c1": Color(0xFF3B1414), "c2": Color(0xFF7B3030)},
    {"name": "Stim-Free Pre",        "cat": "Pre-Workout", "price": 29.99, "unit": "250 g",   "icon": Icons.local_fire_department_rounded,"c1": Color(0xFF1A1A2A), "c2": Color(0xFF3D3460)},
    {"name": "Creatine Monohydrate", "cat": "Creatine",    "price": 19.99, "unit": "500 g",   "icon": Icons.science_rounded,             "c1": Color(0xFF1C2A1E), "c2": Color(0xFF2A4032)},
    {"name": "Multivitamin Pro",     "cat": "Vitamins",    "price": 24.99, "unit": "90 caps", "icon": Icons.eco_rounded,                 "c1": Color(0xFF2A200E), "c2": Color(0xFF5C4822)},
    {"name": "Omega-3 Fish Oil",     "cat": "Vitamins",    "price": 22.99, "unit": "60 soft", "icon": Icons.water_drop_rounded,          "c1": Color(0xFF0E1F2A), "c2": Color(0xFF1A3D52)},
    {"name": "BCAAs Recovery",       "cat": "Recovery",    "price": 27.99, "unit": "400 g",   "icon": Icons.refresh_rounded,             "c1": Color(0xFF2A1C0E), "c2": Color(0xFF6B4C2A)},
    {"name": "Glutamine Powder",     "cat": "Recovery",    "price": 18.99, "unit": "300 g",   "icon": Icons.healing_rounded,             "c1": Color(0xFF1A2A1A), "c2": Color(0xFF3A5A3A)},
    {"name": "Fat Burner Pro",       "cat": "Weight Loss", "price": 36.99, "unit": "60 caps", "icon": Icons.whatshot_rounded,            "c1": Color(0xFF3B1010), "c2": Color(0xFF7B2020)},
    {"name": "L-Carnitine Liquid",   "cat": "Weight Loss", "price": 26.99, "unit": "500 ml",  "icon": Icons.directions_run_rounded,      "c1": Color(0xFF2D1A3D), "c2": Color(0xFF5A3460)},
    {"name": "Mass Gainer 3000",     "cat": "Protein",     "price": 59.99, "unit": "3 kg",    "icon": Icons.trending_up_rounded,         "c1": Color(0xFF1A2A3D), "c2": Color(0xFF2A4060)},
  ];

  List<Map<String, dynamic>> get _filtered => _cat == "All"
      ? List.from(_products)
      : _products.where((p) => p["cat"] == _cat).toList();

  @override
  void initState() {
    super.initState();
    CartManager().addListener(_onCart);
    _cartCount = CartManager().count;
  }
  @override
  void dispose() { CartManager().removeListener(_onCart); super.dispose(); }
  void _onCart() { if (mounted) setState(() => _cartCount = CartManager().count); }

  void _addToCart(Map<String, dynamic> p) {
    CartManager().addItem(CartItem(
      id:       p["name"] as String,
      name:     p["name"] as String,
      price:    p["price"] as double,
      quantity: 1,
      icon:     p["icon"] as IconData,
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("${p["name"]} added to cart"),
      backgroundColor: AppTheme.primary,
      duration: const Duration(seconds: 1),
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
        title: Text("Supplement Store",
            style: AppTheme.subheading.copyWith(fontSize: 18)),
        // ── Cart icon → goes directly to CartScreen ──
        actions: [
          Stack(children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, color: AppTheme.primary),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(children: [
        // ── category chips ──
        SizedBox(height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final sel = _cats[i] == _cat;
              return GestureDetector(
                onTap: () => setState(() => _cat = _cats[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Center(child: Text(_cats[i],
                    style: TextStyle(
                      color: sel ? Colors.white : AppTheme.muted,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ── product grid ──
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.78,
            crossAxisSpacing: 14, mainAxisSpacing: 14,
          ),
          itemCount: _filtered.length,
          itemBuilder: (_, i) {
            final p = _filtered[i];
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [p["c1"] as Color, p["c2"] as Color],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: (p["c1"] as Color).withOpacity(0.3),
                    blurRadius: 12, offset: const Offset(0, 4))],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(p["icon"] as IconData,
                      color: AppTheme.accent, size: 22),
                ),
                const Spacer(),
                Text(p["name"] as String,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                    maxLines: 2),
                const SizedBox(height: 3),
                Text(p["unit"] as String,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 11)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("\$${(p["price"] as double).toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  GestureDetector(
                    onTap: () => _addToCart(p),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_shopping_cart_rounded,
                          color: AppTheme.accent, size: 16),
                    ),
                  ),
                ]),
              ]),
            );
          },
        )),
      ]),
    );
  }
}
