import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class SupplementStoreScreen extends StatefulWidget {
  const SupplementStoreScreen({super.key});

  @override
  State<SupplementStoreScreen> createState() => _SupplementStoreScreenState();
}

class _SupplementStoreScreenState extends State<SupplementStoreScreen> {
  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF8F4EF);

  String _selectedCategory = "All";

  final List<String> _categories = ["All", "Protein", "Pre-Workout", "Vitamins", "Recovery", "Weight Loss", "Creatine"];

  final List<Map<String, dynamic>> _products = [
    {"name": "Whey Protein Gold", "category": "Protein", "price": 49.99, "unit": "2.27kg", "icon": Icons.sports_bar_rounded, "rating": 4.9, "color": const Color(0xFF1A1A2E), "accent": const Color(0xFF4361EE)},
    {"name": "Casein Night Protein", "category": "Protein", "price": 39.99, "unit": "907g", "icon": Icons.bedtime_rounded, "rating": 4.7, "color": const Color(0xFF0F3460), "accent": const Color(0xFF00B4D8)},
    {"name": "Pre-Workout Extreme", "category": "Pre-Workout", "price": 34.99, "unit": "300g", "icon": Icons.bolt_rounded, "rating": 4.8, "color": const Color(0xFF7B2D00), "accent": const Color(0xFFFF8C42)},
    {"name": "Stim-Free Pre", "category": "Pre-Workout", "price": 29.99, "unit": "250g", "icon": Icons.local_fire_department_rounded, "rating": 4.6, "color": const Color(0xFF4A0E8F), "accent": const Color(0xFFC77DFF)},
    {"name": "Creatine Monohydrate", "category": "Creatine", "price": 19.99, "unit": "500g", "icon": Icons.science_rounded, "rating": 5.0, "color": const Color(0xFF1B4332), "accent": const Color(0xFF52B788)},
    {"name": "Multivitamin Pro", "category": "Vitamins", "price": 24.99, "unit": "90 caps", "icon": Icons.eco_rounded, "rating": 4.8, "color": const Color(0xFF003049), "accent": const Color(0xFFFCBF49)},
    {"name": "Omega-3 Fish Oil", "category": "Vitamins", "price": 22.99, "unit": "60 softgels", "icon": Icons.water_drop_rounded, "rating": 4.7, "color": const Color(0xFF0D3B66), "accent": const Color(0xFF60D0F0)},
    {"name": "BCAAs Recovery", "category": "Recovery", "price": 27.99, "unit": "400g", "icon": Icons.refresh_rounded, "rating": 4.6, "color": const Color(0xFF3D2B1F), "accent": const Color(0xFFF4A261)},
    {"name": "Glutamine Powder", "category": "Recovery", "price": 18.99, "unit": "300g", "icon": Icons.healing_rounded, "rating": 4.5, "color": const Color(0xFF1A3A1A), "accent": const Color(0xFF76C893)},
    {"name": "Fat Burner Pro", "category": "Weight Loss", "price": 36.99, "unit": "60 caps", "icon": Icons.whatshot_rounded, "rating": 4.4, "color": const Color(0xFF5C1A1A), "accent": const Color(0xFFE63946)},
    {"name": "L-Carnitine Liquid", "category": "Weight Loss", "price": 26.99, "unit": "500ml", "icon": Icons.directions_run_rounded, "rating": 4.6, "color": const Color(0xFF2D1A3D), "accent": const Color(0xFFB07FED)},
    {"name": "Mass Gainer 3000", "category": "Protein", "price": 59.99, "unit": "3kg", "icon": Icons.trending_up_rounded, "rating": 4.5, "color": const Color(0xFF1A2A3D), "accent": const Color(0xFF64B5F6)},
  ];

  List<Map<String, dynamic>> get _filtered =>
      _selectedCategory == "All" ? _products : _products.where((p) => p["category"] == _selectedCategory).toList();

  void _addToCart(Map<String, dynamic> product) {
    CartManager().addItem(CartItem(
      id: product["name"] as String,
      name: product["name"] as String,
      price: product["price"] as double,
      quantity: 1,
      icon: product["icon"] as IconData,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product["name"]} added to cart!"),
        backgroundColor: primaryOrange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

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
        title: const Text("Supplement Store", style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: darkText),
                onPressed: () => Navigator.pop(context), // go back to see cart tab
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Category Filter ──
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryOrange : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Product Grid ──
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final p = _filtered[index];
                return Container(
                  decoration: BoxDecoration(
                    color: p["color"] as Color,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (p["accent"] as Color).withOpacity(0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: (p["accent"] as Color).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(p["icon"] as IconData, color: p["accent"] as Color, size: 22),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star_rounded, size: 14, color: (p["accent"] as Color)),
                              const SizedBox(width: 3),
                              Text("${p["rating"]}", style: TextStyle(color: (p["accent"] as Color), fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        p["name"] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 4),
                      Text(p["unit"] as String, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "\$${(p["price"] as double).toStringAsFixed(2)}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          GestureDetector(
                            onTap: () => _addToCart(p),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (p["accent"] as Color).withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add_shopping_cart_rounded, color: p["accent"] as Color, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
