import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = CartManager().items;
    final total = CartManager().total;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.background,
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.divider,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Your cart is empty",
                    style: AppTheme.body.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add something from the store!",
                    style: AppTheme.label.copyWith(fontSize: 13),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Cart",
                        style: AppTheme.heading.copyWith(fontSize: 24),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${items.length} item${items.length > 1 ? 's' : ''}",
                          style: AppTheme.label.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Items list ──────────────────────────────────────────
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _CartItemTile(item: items[i]),
                  ),
                ),

                // ── Summary + Checkout (pinned to bottom) ───────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.card(radius: 22),
                  child: Column(
                    children: [
                      _summaryRow(
                        "Subtotal",
                        "${total.toStringAsFixed(2)} JD",
                        false,
                      ),
                      const SizedBox(height: 8),
                      _summaryRow("Shipping", "Free", true),
                      Divider(height: 22, color: AppTheme.divider),
                      _summaryRow(
                        "Total",
                        "${total.toStringAsFixed(2)} JD",
                        false,
                        isTotal: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                            shadowColor: AppTheme.primary.withOpacity(0.35),
                          ),
                          onPressed: () => _checkout(context),
                          child: const Text(
                            "Checkout  →",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 90), // nav bar space
              ],
            ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool isGreen, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTheme.subheading.copyWith(fontSize: 16)
              : AppTheme.body.copyWith(fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTotal ? 18 : 14,
            color: isGreen
                ? Colors.green.shade600
                : isTotal
                ? AppTheme.primary
                : AppTheme.dark,
          ),
        ),
      ],
    );
  }

  void _checkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Confirm Order",
          style: AppTheme.subheading.copyWith(fontSize: 18),
        ),
        content: Text(
          "Total: ${CartManager().total.toStringAsFixed(2)} JD\n\nProceed to payment?",
          style: AppTheme.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(fontFamily: 'Poppins', color: AppTheme.muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final ids = CartManager().items.map((i) => i.id).toList();
              for (final id in ids) CartManager().removeItem(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Order placed! 🎉",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatefulWidget {
  final CartItem item;
  const _CartItemTile({required this.item});
  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.card(radius: 18),
      child: Row(
        children: [
          // icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          // name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTheme.subheading.copyWith(fontSize: 13),
                  maxLines: 2,
                ),
                const SizedBox(height: 3),
                Text(
                  "${item.price.toStringAsFixed(2)} JD",
                  style: AppTheme.body.copyWith(
                    color: AppTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // qty controls
          Row(
            children: [
              _qtyBtn(
                Icons.remove,
                () => CartManager().updateQuantity(item.id, item.quantity - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "${item.quantity}",
                  style: AppTheme.subheading.copyWith(fontSize: 15),
                ),
              ),
              _qtyBtn(
                Icons.add,
                () => CartManager().updateQuantity(item.id, item.quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: AppTheme.primary),
    ),
  );
}
