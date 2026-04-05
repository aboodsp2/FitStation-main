import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);

  bool _isEditing = false;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _nationalityController = TextEditingController();
  String _selectedGender = "Male";
  String _selectedGoal = "Weight Loss";
  String? _photoUrl;
  File? _pickedImage;

  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      final data = doc.data()!;
      setState(() {
        _userData = data;
        _nameController.text = data['name'] ?? '';
        _ageController.text = '${data['age'] ?? ''}';
        _weightController.text = '${data['weight'] ?? ''}';
        _heightController.text = '${data['height'] ?? ''}';
        _nationalityController.text = data['nationality'] ?? '';
        _selectedGender = data['gender'] ?? 'Male';
        _selectedGoal = data['goal'] ?? 'Weight Loss';
        _photoUrl = data['photoUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadPhoto(String uid) async {
    if (_pickedImage == null) return _photoUrl;
    try {
      final ref = FirebaseStorage.instance.ref().child('profile_photos/$uid.jpg');
      await ref.putFile(_pickedImage!);
      return await ref.getDownloadURL();
    } catch (_) {
      return _photoUrl;
    }
  }

  Future<void> _saveChanges() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    try {
      final newPhotoUrl = await _uploadPhoto(uid);
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'age': int.tryParse(_ageController.text) ?? 0,
        'weight': double.tryParse(_weightController.text) ?? 0.0,
        'height': double.tryParse(_heightController.text) ?? 0.0,
        'nationality': _nationalityController.text.trim(),
        'gender': _selectedGender,
        'goal': _selectedGoal,
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
      });

      setState(() {
        _photoUrl = newPhotoUrl;
        _pickedImage = null;
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _nationalityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final email = FirebaseAuth.instance.currentUser?.email ?? 'N/A';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _userData == null) {
          return const Center(child: CircularProgressIndicator(color: primaryOrange));
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          if (!_isEditing) {
            // Sync display values from Firestore when not editing
            _photoUrl = data['photoUrl'];
          }
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // ── Header ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_isEditing) {
                      _saveChanges();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryOrange),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isEditing ? primaryOrange : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 3))
                            ],
                          ),
                          child: Text(
                            _isEditing ? "Save" : "Edit",
                            style: TextStyle(
                              color: _isEditing ? Colors.white : primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // ── Avatar ──────────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [primaryOrange, Color(0xFFFF5A00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(color: primaryOrange.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))
                        ],
                      ),
                      child: ClipOval(
                        child: _pickedImage != null
                            ? Image.file(_pickedImage!, fit: BoxFit.cover)
                            : _photoUrl != null
                                ? Image.network(_photoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: Colors.white, size: 50))
                                : const Icon(Icons.person_rounded, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (!_isEditing) ...[
              Center(
                child: Text(
                  _nameController.text.isNotEmpty ? _nameController.text : "User",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                ),
              ),
              Center(
                child: Text(email, style: const TextStyle(color: Colors.black45, fontSize: 13)),
              ),
            ],

            const SizedBox(height: 25),

            // ── Info Card ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Email (always read-only)
                  _readOnlyRow(Icons.email_outlined, "Email", email),
                  const Divider(height: 28),

                  // Name
                  _isEditing
                      ? _editableField(Icons.person_outline_rounded, "Full Name", _nameController, TextInputType.name)
                      : _readOnlyRow(Icons.person_outline_rounded, "Name", _nameController.text),
                  const Divider(height: 28),

                  // Nationality
                  _isEditing
                      ? _editableField(Icons.flag_outlined, "Nationality", _nationalityController, TextInputType.text)
                      : _readOnlyRow(Icons.flag_outlined, "Nationality", _nationalityController.text.isNotEmpty ? _nationalityController.text : "Not set"),
                  const Divider(height: 28),

                  // Goal
                  _isEditing
                      ? _buildDropdownRow(Icons.track_changes_rounded, "Goal", ["Weight Loss", "Muscle Gain", "Maintenance"], _selectedGoal, (v) => setState(() => _selectedGoal = v!))
                      : _readOnlyRow(Icons.track_changes_rounded, "Goal", _selectedGoal),
                  const Divider(height: 28),

                  // Gender
                  _isEditing
                      ? _buildDropdownRow(Icons.wc_rounded, "Gender", ["Male", "Female", "Other"], _selectedGender, (v) => setState(() => _selectedGender = v!))
                      : _readOnlyRow(Icons.wc_rounded, "Gender", _selectedGender),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats ───────────────────────────────────────────────────
            Row(
              children: [
                _statBox("Age", _ageController, "yrs"),
                const SizedBox(width: 12),
                _statBox("Weight", _weightController, "kg"),
                const SizedBox(width: 12),
                _statBox("Height", _heightController, "cm"),
              ],
            ),

            const SizedBox(height: 100),
          ],
        );
      },
    );
  }

  Widget _readOnlyRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryOrange, size: 18),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A1A))),
          ],
        ),
      ],
    );
  }

  Widget _editableField(IconData icon, String label, TextEditingController controller, TextInputType type) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryOrange, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: type,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A1A)),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.black38, fontSize: 11),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(IconData icon, String label, List<String> options, String current, ValueChanged<String?> onChanged) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: primaryOrange, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: current,
              isExpanded: true,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1A1A1A)),
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, TextEditingController controller, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.black38, fontSize: 11)),
            const SizedBox(height: 6),
            _isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      suffixText: unit,
                      suffixStyle: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(controller.text.isNotEmpty ? controller.text : "0",
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                      Text(" $unit", style: const TextStyle(fontSize: 10, color: Colors.black38)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
