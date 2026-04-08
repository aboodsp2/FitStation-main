import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_theme.dart';
import 'dashboard_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;
  final VoidCallback onOrderPlaced;
  const CheckoutScreen({
    super.key,
    required this.total,
    required this.onOrderPlaced,
  });
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _payMethod = 'cod'; // 'cod' | 'visa'
  bool _placing = false;

  // visa
  final _cardNumCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    _cardNumCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  // Opens Google Maps so customer can share / confirm their location
  Future<void> _openMaps() async {
    final query = Uri.encodeComponent(
      '${_addressCtrl.text} ${_cityCtrl.text}'.trim().isNotEmpty
          ? '${_addressCtrl.text} ${_cityCtrl.text}'
          : 'Amman, Jordan',
    );
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _placeOrder() async {
    if (_addressCtrl.text.trim().isEmpty) {
      _snack("Please enter your delivery address.", Colors.redAccent);
      return;
    }
    if (_payMethod == 'visa') {
      final num = _cardNumCtrl.text.replaceAll(' ', '');
      if (num.length < 16) {
        _snack("Please enter a valid 16-digit card number.", Colors.redAccent);
        return;
      }
      if (_expiryCtrl.text.length < 5) {
        _snack("Please enter a valid expiry date (MM/YY).", Colors.redAccent);
        return;
      }
      if (_cvvCtrl.text.length < 3) {
        _snack("Please enter a valid CVV.", Colors.redAccent);
        return;
      }
    }

    setState(() => _placing = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate processing

    widget.onOrderPlaced();
    if (!mounted) return;
    setState(() => _placing = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => _OrderSuccessScreen(
          total: widget.total,
          payMethod: _payMethod,
          address: '${_addressCtrl.text.trim()}, ${_cityCtrl.text.trim()}',
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.dark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Checkout",
          style: AppTheme.subheading.copyWith(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Total pill ──────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Order Total",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${widget.total.toStringAsFixed(2)} JD",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppTheme.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Delivery Address ────────────────────────────────────────────
            _sectionTitle("📍 Delivery Address"),
            const SizedBox(height: 12),
            _input(
              _addressCtrl,
              "Street address *",
              Icons.home_outlined,
              TextInputType.streetAddress,
            ),
            const SizedBox(height: 10),
            _input(
              _cityCtrl,
              "City / Area",
              Icons.location_city_outlined,
              TextInputType.text,
            ),
            const SizedBox(height: 10),
            _input(
              _notesCtrl,
              "Delivery notes (optional)",
              Icons.note_outlined,
              TextInputType.text,
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Open in Maps button
            GestureDetector(
              onTap: _openMaps,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map_outlined, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      "Confirm location on Google Maps",
                      style: AppTheme.body.copyWith(
                        fontSize: 13,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: AppTheme.muted,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Payment Method ──────────────────────────────────────────────
            _sectionTitle("💳 Payment Method"),
            const SizedBox(height: 12),
            _payOption(
              'cod',
              Icons.payments_outlined,
              "Cash on Delivery",
              "Pay when your order arrives",
            ),
            const SizedBox(height: 10),
            _payOption(
              'visa',
              Icons.credit_card_rounded,
              "Pay Online (Visa)",
              "Secure card payment",
            ),

            // Visa form — animated expand
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _payMethod == 'visa'
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: AppTheme.card(radius: 18),
                        child: Column(
                          children: [
                            _cardField(
                              _cardNumCtrl,
                              "Card Number",
                              "1234  5678  9012  3456",
                              Icons.credit_card_rounded,
                              TextInputType.number,
                              formatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardNumberFormatter(),
                              ],
                              maxLen: 19,
                            ),
                            const SizedBox(height: 12),
                            _cardField(
                              _cardNameCtrl,
                              "Cardholder Name",
                              "Name on card",
                              Icons.person_outline_rounded,
                              TextInputType.name,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _cardField(
                                    _expiryCtrl,
                                    "Expiry",
                                    "MM/YY",
                                    Icons.calendar_today_outlined,
                                    TextInputType.number,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      _ExpiryFormatter(),
                                    ],
                                    maxLen: 5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _cardField(
                                    _cvvCtrl,
                                    "CVV",
                                    "•••",
                                    Icons.lock_outline_rounded,
                                    TextInputType.number,
                                    formatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    maxLen: 3,
                                    obscure: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.lock_rounded,
                                  color: Colors.green.shade600,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Your payment info is encrypted & secure",
                                  style: AppTheme.label.copyWith(
                                    fontSize: 11,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),

            // ── Place Order ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 5,
                  shadowColor: AppTheme.primary.withOpacity(0.4),
                ),
                onPressed: _placing ? null : _placeOrder,
                child: _placing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _payMethod == 'visa'
                            ? "Pay ${widget.total.toStringAsFixed(2)} JD"
                            : "Place Order",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) =>
      Text(t, style: AppTheme.subheading.copyWith(fontSize: 15));

  Widget _input(
    TextEditingController c,
    String hint,
    IconData icon,
    TextInputType type, {
    int maxLines = 1,
  }) => TextField(
    controller: c,
    keyboardType: type,
    maxLines: maxLines,
    style: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      color: AppTheme.dark,
    ),
    decoration: AppTheme.inputDecoration(hint, icon),
  );

  Widget _payOption(String value, IconData icon, String title, String sub) {
    final sel = _payMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _payMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sel ? AppTheme.primary : AppTheme.divider,
            width: 1.5,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: sel
                    ? Colors.white.withOpacity(0.15)
                    : AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: sel ? AppTheme.accent : AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: sel ? Colors.white : AppTheme.dark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: sel
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (sel)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
    TextInputType type, {
    List<TextInputFormatter>? formatters,
    int? maxLen,
    bool obscure = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTheme.label.copyWith(fontSize: 11)),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl,
        keyboardType: type,
        obscureText: obscure,
        inputFormatters: formatters,
        maxLength: maxLen,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppTheme.dark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            color: AppTheme.muted,
            fontSize: 13,
          ),
          prefixIcon: Icon(icon, color: AppTheme.accent, size: 18),
          filled: true,
          fillColor: AppTheme.background,
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.divider),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 14,
          ),
        ),
      ),
    ],
  );
}

// ── Card number auto-format ────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return next.copyWith(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

// ── Expiry auto-format MM/YY ───────────────────────────────────────────────────
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll('/', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final s = buf.toString();
    return next.copyWith(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

// ── Order Success ──────────────────────────────────────────────────────────────
class _OrderSuccessScreen extends StatelessWidget {
  final double total;
  final String payMethod;
  final String address;
  const _OrderSuccessScreen({
    required this.total,
    required this.payMethod,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade500,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  "Order Placed! 🎉",
                  style: AppTheme.heading.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 12),
                Text(
                  payMethod == 'visa'
                      ? "Payment of ${total.toStringAsFixed(2)} JD confirmed."
                      : "You'll pay ${total.toStringAsFixed(2)} JD on delivery.",
                  textAlign: TextAlign.center,
                  style: AppTheme.body.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  "Delivering to:\n$address",
                  textAlign: TextAlign.center,
                  style: AppTheme.body.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 40),
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
                    onPressed: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                    child: const Text(
                      "Back to Home",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
