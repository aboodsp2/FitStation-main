import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';

// ── Explore Restaurants placeholder ─────────────────────────────────────────
class ExploreRestaurantsScreen extends StatelessWidget {
  const ExploreRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text("Explore Restaurants")),
      body: const Center(child: Text("Coming soon…", style: AppTheme.body)),
    );
  }
}

// ── Main Meal Plan Screen ────────────────────────────────────────────────────
class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({super.key});

  static const List<Map<String, dynamic>> _goals = [
    {
      "label": "Weight Loss",
      "icon": Icons.trending_down_rounded,
      "color": Color(0xFF1B4332),
      "accent": Color(0xFF52B788),
      "cal": "1,500 kcal/day",
      "recommended": true,
    },
    {
      "label": "Maintain",
      "icon": Icons.balance_rounded,
      "color": Color(0xFF0F3460),
      "accent": Color(0xFF00B4D8),
      "cal": "2,000 kcal/day",
      "recommended": false,
    },
    {
      "label": "Muscle Gain",
      "icon": Icons.trending_up_rounded,
      "color": Color(0xFF1A1A2E),
      "accent": Color(0xFF4361EE),
      "cal": "2,800 kcal/day",
      "recommended": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Meal Plans"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            "What's your goal?",
            style: AppTheme.body.copyWith(fontSize: 15, color: AppTheme.muted),
          ),
          const SizedBox(height: 20),

          // ── Goal Cards ───────────────────────────────────────────────────
          ..._goals.map((goal) {
            final bool isRec = goal["recommended"] as bool;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRec) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text(
                          "Recommended for you",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _MealDetailScreen(
                        goalLabel: goal["label"] as String,
                        goalColor: goal["color"] as Color,
                        goalAccent: goal["accent"] as Color,
                        goalCal: goal["cal"] as String,
                      ),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: goal["color"] as Color,
                      borderRadius: BorderRadius.circular(24),
                      border: isRec
                          ? Border.all(color: AppTheme.accent, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: (goal["accent"] as Color).withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (goal["accent"] as Color).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            goal["icon"] as IconData,
                            color: goal["accent"] as Color,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal["label"] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                goal["cal"] as String,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 4),

          // ── Explore Restaurants ──────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExploreRestaurantsScreen(),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: AppTheme.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Explore Restaurants", style: AppTheme.subheading),
                        const SizedBox(height: 2),
                        Text(
                          "Find healthy spots near you",
                          style: AppTheme.body.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meal Detail Screen ───────────────────────────────────────────────────────
class _MealDetailScreen extends StatelessWidget {
  final String goalLabel;
  final Color goalColor;
  final Color goalAccent;
  final String goalCal;

  const _MealDetailScreen({
    required this.goalLabel,
    required this.goalColor,
    required this.goalAccent,
    required this.goalCal,
  });

  // Image asset paths — name your files exactly as listed here and put them in
  // the matching assets/meals/<folder>/ directory, then register in pubspec.yaml
  static const Map<String, List<Map<String, dynamic>>> _sections = {
    "Weight Loss": [
      {
        "section": "BREAKFAST",
        "items": [
          {
            "name": "Sunrise Fuel",
            "asset": "assets/meals/weight_loss/sunrise_fuel.jpg",
            "desc":
                "A balanced plate of eggs, avocado, vegetables, and chickpeas — rich in protein, fiber, and healthy fats to support energy and metabolism.",
            "kcal": "250 kcal",
            "protein": "22g Protein",
            "carbs": "28g Carbs",
            "fat": "32g Fat",
          },
          {
            "name": "Berry Power Bowl",
            "asset": "assets/meals/weight_loss/berry_bowl.jpg",
            "desc":
                "A creamy bowl of oats and chia topped with bananas, strawberries, blueberries, and walnuts for sustained energy and antioxidant support.",
            "kcal": "300 kcal",
            "protein": "14g Protein",
            "carbs": "51g Carbs",
            "fat": "16g Fat",
          },
          {
            "name": "Hummus Toast",
            "asset": "assets/meals/weight_loss/hummus_toast.jpg",
            "desc":
                "Whole grain toast with creamy hummus, roasted chickpeas, cherry tomatoes, arugula, and a light balsamic drizzle.",
            "kcal": "290 kcal",
            "protein": "17g Protein",
            "carbs": "45g Carbs",
            "fat": "14g Fat",
          },
        ],
      },
      {
        "section": "LUNCH",
        "items": [
          {
            "name": "Steak & Strength",
            "asset": "assets/meals/weight_loss/steak_lunch.jpg",
            "desc":
                "Grilled steak with mashed potatoes, roasted vegetables, and greens — a balanced, high-protein lunch.",
            "kcal": "650 kcal",
            "protein": "52g Protein",
            "carbs": "40g Carbs",
            "fat": "25g Fat",
          },
          {
            "name": "Grilled Salmon Plate",
            "asset": "assets/meals/weight_loss/salmon_plate.jpg",
            "desc":
                "Grilled salmon with roasted vegetables and lemon for a clean, high-protein meal rich in omega-3s.",
            "kcal": "500 kcal",
            "protein": "48g Protein",
            "carbs": "38g Carbs",
            "fat": "22g Fat",
          },
          {
            "name": "Grilled Chicken Plate",
            "asset": "assets/meals/weight_loss/chicken_plate.jpg",
            "desc":
                "Grilled chicken breast served with white rice and a fresh vegetable salad for a balanced, lean meal.",
            "kcal": "520 kcal",
            "protein": "44g Protein",
            "carbs": "45g Carbs",
            "fat": "15g Fat",
          },
        ],
      },
      {
        "section": "DINNER",
        "items": [
          {
            "name": "Caesar Wrap",
            "asset": "assets/meals/weight_loss/caesar_wrap.jpg",
            "desc":
                "Grilled chicken, romaine lettuce, tortilla wrap, and Caesar dressing for a high-protein satisfying meal.",
            "kcal": "360 kcal",
            "protein": "32g Protein",
            "carbs": "35g Carbs",
            "fat": "34g Fat",
          },
          {
            "name": "Tuna Beast",
            "asset": "assets/meals/weight_loss/tuna_beast.jpg",
            "desc":
                "Whole grain bread with tuna, lettuce, tomato, cucumber, and olives for a protein-rich meal.",
            "kcal": "290 kcal",
            "protein": "38g Protein",
            "carbs": "12g Carbs",
            "fat": "10g Fat",
          },
          {
            "name": "Stuffed Grape Leaves",
            "asset": "assets/meals/weight_loss/grape_leaves.jpg",
            "desc":
                "Grape leaves stuffed with rice, herbs, and light seasoning for a traditional, fiber-rich dinner.",
            "kcal": "300 kcal",
            "protein": "15g Protein",
            "carbs": "45g Carbs",
            "fat": "11g Fat",
          },
        ],
      },
    ],
    "Maintain": [
      {
        "section": "BREAKFAST",
        "items": [
          {
            "name": "Greek Yogurt Bowl",
            "asset": "assets/meals/maintain/yogurt_bowl.jpg",
            "desc":
                "Creamy Greek yogurt topped with granola, honey, and mixed berries for a balanced, refreshing start.",
            "kcal": "350 kcal",
            "protein": "20g Protein",
            "carbs": "48g Carbs",
            "fat": "10g Fat",
          },
          {
            "name": "Egg & Avocado Toast",
            "asset": "assets/meals/maintain/egg_toast.jpg",
            "desc":
                "Whole wheat toast with smashed avocado, poached eggs, and chili flakes for a balanced morning.",
            "kcal": "400 kcal",
            "protein": "22g Protein",
            "carbs": "35g Carbs",
            "fat": "20g Fat",
          },
        ],
      },
      {
        "section": "LUNCH",
        "items": [
          {
            "name": "Chicken Rice Bowl",
            "asset": "assets/meals/maintain/chicken_rice.jpg",
            "desc":
                "Grilled chicken on a bed of brown rice with sautéed vegetables and a light soy glaze.",
            "kcal": "600 kcal",
            "protein": "42g Protein",
            "carbs": "55g Carbs",
            "fat": "14g Fat",
          },
          {
            "name": "Mediterranean Wrap",
            "asset": "assets/meals/maintain/med_wrap.jpg",
            "desc":
                "Falafel, hummus, fresh veggies, and tzatziki wrapped in a whole grain tortilla.",
            "kcal": "500 kcal",
            "protein": "18g Protein",
            "carbs": "60g Carbs",
            "fat": "18g Fat",
          },
        ],
      },
      {
        "section": "DINNER",
        "items": [
          {
            "name": "Baked Salmon & Couscous",
            "asset": "assets/meals/maintain/salmon_couscous.jpg",
            "desc":
                "Herb-baked salmon served with fluffy couscous, olives, and roasted cherry tomatoes.",
            "kcal": "580 kcal",
            "protein": "44g Protein",
            "carbs": "42g Carbs",
            "fat": "20g Fat",
          },
          {
            "name": "Pasta Bolognese",
            "asset": "assets/meals/maintain/pasta.jpg",
            "desc":
                "Whole wheat pasta with lean mince, rich tomato sauce, and fresh basil.",
            "kcal": "620 kcal",
            "protein": "36g Protein",
            "carbs": "65g Carbs",
            "fat": "16g Fat",
          },
        ],
      },
    ],
    "Muscle Gain": [
      {
        "section": "BREAKFAST",
        "items": [
          {
            "name": "Power Egg Stack",
            "asset": "assets/meals/muscle_gain/egg_stack.jpg",
            "desc":
                "Five scrambled eggs with oats, banana, and a protein shake for maximum morning fuel.",
            "kcal": "700 kcal",
            "protein": "55g Protein",
            "carbs": "60g Carbs",
            "fat": "24g Fat",
          },
          {
            "name": "Protein Pancakes",
            "asset": "assets/meals/muscle_gain/protein_pancakes.jpg",
            "desc":
                "Fluffy pancakes made with protein powder, eggs, and oats topped with peanut butter.",
            "kcal": "650 kcal",
            "protein": "45g Protein",
            "carbs": "70g Carbs",
            "fat": "18g Fat",
          },
        ],
      },
      {
        "section": "LUNCH",
        "items": [
          {
            "name": "Double Chicken & Rice",
            "asset": "assets/meals/muscle_gain/double_chicken.jpg",
            "desc":
                "Two grilled chicken breasts on a large portion of brown rice with steamed broccoli.",
            "kcal": "900 kcal",
            "protein": "80g Protein",
            "carbs": "75g Carbs",
            "fat": "18g Fat",
          },
          {
            "name": "Beef & Sweet Potato",
            "asset": "assets/meals/muscle_gain/beef_potato.jpg",
            "desc":
                "Lean beef mince patties served with roasted sweet potato and fresh spinach.",
            "kcal": "850 kcal",
            "protein": "65g Protein",
            "carbs": "70g Carbs",
            "fat": "22g Fat",
          },
        ],
      },
      {
        "section": "DINNER",
        "items": [
          {
            "name": "Steak & Rice",
            "asset": "assets/meals/muscle_gain/steak_rice.jpg",
            "desc":
                "Grilled ribeye steak with jasmine rice, avocado, and a side of mixed greens.",
            "kcal": "950 kcal",
            "protein": "75g Protein",
            "carbs": "65g Carbs",
            "fat": "35g Fat",
          },
          {
            "name": "Tuna Pasta",
            "asset": "assets/meals/muscle_gain/tuna_pasta.jpg",
            "desc":
                "High-protein tuna pasta with olive oil, cherry tomatoes, and fresh herbs.",
            "kcal": "700 kcal",
            "protein": "58g Protein",
            "carbs": "68g Carbs",
            "fat": "14g Fat",
          },
        ],
      },
    ],
  };

  double get _price => goalLabel == "Weight Loss"
      ? 35.0
      : goalLabel == "Maintain"
      ? 38.0
      : 48.0;

  @override
  Widget build(BuildContext context) {
    final sections = _sections[goalLabel] ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing Header ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: goalColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [goalColor, goalAccent.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 28,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FitStation badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Powered by FitStation",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "YOUR MEAL\nINCLUDES",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              color: goalAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              goalCal,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Meal Sections ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index < sections.length) {
                  final s = sections[index];
                  return _SectionWidget(
                    title: s["section"] as String,
                    items: s["items"] as List<Map<String, dynamic>>,
                    accentColor: goalAccent,
                    headerColor: goalColor,
                  );
                }
                return _AddToCartButton(goalLabel: goalLabel, price: _price);
              }, childCount: sections.length + 1),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Divider + Items ──────────────────────────────────────────────────
class _SectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color accentColor;
  final Color headerColor;

  const _SectionWidget({
    required this.title,
    required this.items,
    required this.accentColor,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 28, 0, 16),
          child: Row(
            children: [
              Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: headerColor,
                  ),
                ),
              ),
              Expanded(child: Divider(color: AppTheme.divider, thickness: 1)),
            ],
          ),
        ),
        ...items.map(
          (item) => _MealItemCard(item: item, accentColor: accentColor),
        ),
      ],
    );
  }
}

// ── Meal Item Card ───────────────────────────────────────────────────────────
class _MealItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color accentColor;

  const _MealItemCard({required this.item, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.card(radius: 20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ────────────────────────────────────────────────────────
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.asset(
              item["asset"] as String,
              fit: BoxFit.cover,
              errorBuilder: (context, error, _) {
                // Shown while images aren't added to pubspec yet
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.18),
                        accentColor.withOpacity(0.06),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 48,
                        color: accentColor.withOpacity(0.45),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item["name"] as String,
                        style: TextStyle(
                          color: accentColor.withOpacity(0.7),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "📁 Add to assets/meals/",
                        style: TextStyle(
                          color: AppTheme.muted.withOpacity(0.5),
                          fontFamily: 'Poppins',
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ── Info ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item["name"] as String, style: AppTheme.subheading),
                const SizedBox(height: 6),
                Text(
                  item["desc"] as String,
                  style: AppTheme.body.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 14),
                // Macro chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip("🔥 ${item["kcal"]}", const Color(0xFFE63946)),
                    _chip("💪 ${item["protein"]}", const Color(0xFF4361EE)),
                    _chip("🌾 ${item["carbs"]}", const Color(0xFF2A9D8F)),
                    _chip("🥑 ${item["fat"]}", const Color(0xFFE9A93E)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Add to Cart Footer ───────────────────────────────────────────────────────
class _AddToCartButton extends StatelessWidget {
  final String goalLabel;
  final double price;

  const _AddToCartButton({required this.goalLabel, required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 48),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.accent],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 17),
            minimumSize: const Size(double.infinity, 0),
          ),
          icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white),
          label: Text(
            "ADD TO CART  —  \$${price.toStringAsFixed(0)}",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          onPressed: () {
            CartManager().addItem(
              CartItem(
                id: "fitstation_$goalLabel",
                name: "FitStation – $goalLabel Plan",
                price: price,
                quantity: 1,
                icon: Icons.restaurant_menu_rounded,
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      "$goalLabel plan added to cart!",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF2A9D8F),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
