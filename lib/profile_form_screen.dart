import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _nationalityController = TextEditingController();

  String _selectedGender = "Male";
  String _selectedGoal = "Weight Loss";

  Future<void> _submitProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'age': int.tryParse(_ageController.text) ?? 0,
            'weight': double.tryParse(_weightController.text) ?? 0.0,
            'height': double.tryParse(_heightController.text) ?? 0.0,
            'gender': _selectedGender,
            'goal': _selectedGoal,
            'nationality': _nationalityController.text.trim(),
            'profileCompleted': true,
          });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _buildInput(
              _ageController,
              "Age",
              Icons.calendar_today,
              TextInputType.number,
            ),
            _buildInput(
              _weightController,
              "Weight (kg)",
              Icons.monitor_weight_outlined,
              TextInputType.number,
            ),
            _buildInput(
              _heightController,
              "Height (cm)",
              Icons.height,
              TextInputType.number,
            ),
            _buildInput(
              _nationalityController,
              "Nationality",
              Icons.flag_outlined,
              TextInputType.text,
            ),
            const SizedBox(height: 15),
            _buildDropdown(
              "Gender",
              ["Male", "Female", "Other"],
              _selectedGender,
              (val) => setState(() => _selectedGender = val!),
            ),
            _buildDropdown(
              "Your Goal",
              ["Weight Loss", "Muscle Gain", "Maintenance"],
              _selectedGoal,
              (val) => setState(() => _selectedGoal = val!),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: const StadiumBorder(),
                ),
                onPressed: _submitProfile,
                child: const Text(
                  "SAVE PROFILE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint,
    IconData icon,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.pink),
          hintText: hint,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String current,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        DropdownButton<String>(
          value: current,
          isExpanded: true,
          dropdownColor: Colors.grey[900],
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
