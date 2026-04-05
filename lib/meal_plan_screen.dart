import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF8F4EF);

  String? _selectedGoal;

  final List<Map<String, dynamic>> _goals = [
    {"label": "Weight Loss", "icon": Icons.trending_down_rounded, "color": const Color(0xFF1B4332), "accent": const Color(0xFF52B788), "cal": "1,500 kcal/day"},
    {"label": "Maintain", "icon": Icons.balance_rounded, "color": const Color(0xFF0F3460), "accent": const Color(0xFF00B4D8), "cal": "2,000 kcal/day"},
    {"label": "Muscle Gain", "icon": Icons.trending_up_rounded, "color": const Color(0xFF1A1A2E), "accent": const Color(0xFF4361EE), "cal": "2,800 kcal/day"},
  ];

  final Map<String, List<Map<String, dynamic>>> _preparedMeals = {
    "Weight Loss": [
      {
        "name": "Lean Green Plan",
        "price": 35.0,
        "desc": "Grilled chicken + salad",
        "breakfast": "Oatmeal with berries & almond milk",
        "lunch": "Grilled chicken breast + quinoa salad",
        "dinner": "Steamed fish + broccoli & sweet potato",
      },
      {
        "name": "Keto Slim Plan",
        "price": 40.0,
        "desc": "Low-carb, high-fat",
        "breakfast": "Avocado eggs & bacon",
        "lunch": "Tuna lettuce wraps",
        "dinner": "Grilled salmon + asparagus",
      },
    ],
    "Maintain": [
      {
        "name": "Balanced Daily Plan",
        "price": 38.0,
        "desc": "Complete macro balance",
        "breakfast": "Whole wheat toast + eggs + fruit",
        "lunch": "Chicken rice bowl + veggies",
        "dinner": "Pasta with lean mince + salad",
      },
      {
        "name": "Mediterranean Plan",
        "price": 42.0,
        "desc": "Heart-healthy & diverse",
        "breakfast": "Greek yogurt + granola + honey",
        "lunch": "Hummus + falafel wrap",
        "dinner": "Baked salmon + olives + couscous",
      },
    ],
    "Muscle Gain": [
      {
        "name": "Bulk Builder Plan",
        "price": 48.0,
        "desc": "High-protein, high-calorie",
        "breakfast": "5 eggs + oats + banana protein shake",
        "lunch": "Double chicken breast + brown rice + broccoli",
        "dinner": "Beef steak + sweet potato + spinach",
      },
      {
        "name": "Mass Pro Plan",
        "price": 55.0,
        "desc": "For serious mass gains",
        "breakfast": "Pancakes + eggs + milk",
        "lunch": "Tuna pasta + veggies",
        "dinner": "Chicken thighs + rice + avocado",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () {
            if (_selectedGoal != null) {
              setState(() => _selectedGoal = null);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _selectedGoal == null ? "Meal Plans" : _selectedGoal!,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
      ),
      body: _selectedGoal == null ? _buildGoalSelection() : _buildMealOptions(),
    );
  }

  Widget _buildGoalSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's your goal?", style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 20),
          ..._goals.map((goal) => GestureDetector(
                onTap: () => setState(() => _selectedGoal = goal["label"]),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: goal["color"] as Color,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: (goal["accent"] as Color).withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: (goal["accent"] as Color).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(goal["icon"] as IconData, color: goal["accent"] as Color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal["label"] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(goal["cal"] as String, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                ),
              )),
          // Custom Plan
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const _CustomMealPlanScreen())),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryOrange.withOpacity(0.3)),
                boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.1), blurRadius: 12)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.tune_rounded, color: primaryOrange, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Custom Meal Plan", style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("Build your own plan", style: TextStyle(color: Colors.black45, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: primaryOrange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealOptions() {
    final meals = _preparedMeals[_selectedGoal] ?? [];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text("Choose a Plan", style: TextStyle(fontSize: 16, color: Colors.black45)),
        const SizedBox(height: 16),
        ...meals.map((meal) => _MealCard(meal: meal, goal: _selectedGoal!)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final String goal;

  const _MealCard({required this.meal, required this.goal});

  static const Color primaryOrange = Color(0xFFF37E33);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primaryOrange.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal["name"] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1A1A))),
                    Text(meal["desc"] as String, style: const TextStyle(color: Colors.black45, fontSize: 13)),
                  ],
                ),
                Text("\$${(meal["price"] as double).toStringAsFixed(0)}/wk",
                    style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _mealRow("🌅", "Breakfast", meal["breakfast"] as String),
                const SizedBox(height: 10),
                _mealRow("☀️", "Lunch", meal["lunch"] as String),
                const SizedBox(height: 10),
                _mealRow("🌙", "Dinner", meal["dinner"] as String),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      CartManager().addItem(CartItem(
                        id: meal["name"] as String,
                        name: meal["name"] as String,
                        price: meal["price"] as double,
                        quantity: 1,
                        icon: Icons.restaurant_menu_rounded,
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Plan added to cart!"), backgroundColor: Colors.green),
                      );
                    },
                    child: const Text("Add to Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11)),
              Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Custom Meal Plan Screen ─────────────────────────────────────────────────
class _CustomMealPlanScreen extends StatefulWidget {
  const _CustomMealPlanScreen();

  @override
  State<_CustomMealPlanScreen> createState() => _CustomMealPlanScreenState();
}

class _CustomMealPlanScreenState extends State<_CustomMealPlanScreen> {
  static const Color primaryOrange = Color(0xFFF37E33);

  final _breakfastController = TextEditingController();
  final _lunchController = TextEditingController();
  final _dinnerController = TextEditingController();
  final _notesController = TextEditingController();
  int _weeks = 1;

  double get _price => _weeks * 25.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F4EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Custom Meal Plan", style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                _inputField("🌅 Breakfast Preference", _breakfastController),
                const SizedBox(height: 14),
                _inputField("☀️ Lunch Preference", _lunchController),
                const SizedBox(height: 14),
                _inputField("🌙 Dinner Preference", _dinnerController),
                const SizedBox(height: 14),
                _inputField("📝 Additional Notes / Allergies", _notesController, maxLines: 3),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text("Duration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _qtyBtn(Icons.remove, () => setState(() => _weeks = (_weeks - 1).clamp(1, 12))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text("$_weeks week${_weeks > 1 ? 's' : ''}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(Icons.add, () => setState(() => _weeks = (_weeks + 1).clamp(1, 12))),
                  ],
                ),
                const SizedBox(height: 12),
                Text("\$25/week → Total: \$${_price.toStringAsFixed(0)}", style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () {
                CartManager().addItem(CartItem(
                  id: "custom_meal_${DateTime.now().millisecondsSinceEpoch}",
                  name: "Custom Meal Plan (${_weeks}wk)",
                  price: _price,
                  quantity: 1,
                  icon: Icons.tune_rounded,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Custom plan added to cart!"), backgroundColor: Colors.green),
                );
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Add to Cart — \$${_price.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F4EF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: primaryOrange, size: 20),
      ),
    );
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
