import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF37E33)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Profile not found"));
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            const Text(
              "Profile Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 25),

            // User Basic Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.email_outlined,
                    "Email",
                    data['email'] ?? "N/A",
                  ),
                  const Divider(height: 30),
                  _infoRow(
                    Icons.flag_outlined,
                    "Nationality",
                    data['nationality'] ?? "Not set",
                  ),
                  const Divider(height: 30),
                  _infoRow(
                    Icons.track_changes,
                    "Goal",
                    data['goal'] ?? "Not set",
                  ),
                  const Divider(height: 30),
                  _infoRow(Icons.wc, "Gender", data['gender'] ?? "Not set"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Physical Stats Grid
            Row(
              children: [
                _statBox("Age", "${data['age'] ?? '0'}", "yrs"),
                const SizedBox(width: 15),
                _statBox("Weight", "${data['weight'] ?? '0'}", "kg"),
                const SizedBox(width: 15),
                _statBox("Height", "${data['height'] ?? '0'}", "cm"),
              ],
            ),
            const SizedBox(height: 100), // Padding for the floating nav bar
          ],
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFF37E33), size: 22),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.black45, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  " $unit",
                  style: const TextStyle(fontSize: 10, color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
