import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        const Text(
          "About & Contact",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: darkText),
        ),
        const SizedBox(height: 25),

        // ── Who We Are ──────────────────────────────────────────────
        _sectionCard(
          icon: Icons.fitness_center_rounded,
          title: "Who We Are",
          child: const Text(
            "FitStation is your all-in-one wellness companion. We provide personalized training plans, premium supplements, custom meal plans, and professional consultations — all in one place. Our mission is to help you achieve your health and fitness goals with expert guidance and community support.",
            style: TextStyle(color: Colors.black54, height: 1.6, fontSize: 14),
          ),
        ),

        const SizedBox(height: 16),

        // ── FAQ ─────────────────────────────────────────────────────
        _sectionCard(
          icon: Icons.help_outline_rounded,
          title: "FAQ",
          child: Column(
            children: [
              _faqItem("How do I get started?", "Sign up, complete your profile, and explore our training plans, supplements, and meal options."),
              _faqItem("Can I change my plan anytime?", "Yes! You can switch between plans at any time from your profile settings."),
              _faqItem("Are the supplements authentic?", "All supplements in our store are sourced from certified manufacturers with full quality guarantees."),
              _faqItem("How do consultations work?", "Book a slot, confirm your location, and our certified trainers will connect with you at your chosen time."),
              _faqItem("Is my data secure?", "Absolutely. We use Firebase with end-to-end encryption to keep your data safe."),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Contact ─────────────────────────────────────────────────
        _sectionCard(
          icon: Icons.contact_support_rounded,
          title: "Contact Us",
          child: Column(
            children: [
              _contactRow(
                Icons.phone_rounded,
                "Phone",
                "+962 7 9999 8888",
                onTap: () => launchUrl(Uri.parse("tel:+96279999888")),
              ),
              const SizedBox(height: 14),
              _contactRow(
                Icons.email_outlined,
                "Email",
                "support@fitstation.com",
                onTap: () => launchUrl(Uri.parse("mailto:support@fitstation.com")),
              ),
              const SizedBox(height: 14),
              _contactRow(
                Icons.location_on_outlined,
                "Location",
                "Amman, Jordan",
                onTap: null,
              ),
            ],
          ),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _sectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: primaryOrange, size: 18),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        iconColor: primaryOrange,
        collapsedIconColor: Colors.black38,
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: darkText)),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(answer, style: const TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryOrange, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: onTap != null ? primaryOrange : darkText,
                  decoration: onTap != null ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
