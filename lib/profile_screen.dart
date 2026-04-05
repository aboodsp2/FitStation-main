import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'app_theme.dart';
import 'profile_form_screen.dart' show kNationalities;

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});
  @override State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  bool _editing  = false;
  bool _saving   = false;

  final _nameCtrl        = TextEditingController();
  final _ageCtrl         = TextEditingController();
  final _weightCtrl      = TextEditingController();
  final _heightCtrl      = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  String _gender = "Male";
  String _goal   = "Weight Loss";

  // The URL of the saved photo (from Firestore)
  String? _savedPhotoUrl;
  // A newly picked local file (before saving)
  File?   _pickedFile;

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || !mounted) return;
    final d = doc.data()!;
    setState(() {
      _nameCtrl.text        = d['name']        ?? '';
      _ageCtrl.text         = '${d['age']      ?? ''}';
      _weightCtrl.text      = '${d['weight']   ?? ''}';
      _heightCtrl.text      = '${d['height']   ?? ''}';
      _nationalityCtrl.text = d['nationality'] ?? '';
      _gender               = d['gender']      ?? 'Male';
      _goal                 = d['goal']        ?? 'Weight Loss';
      _savedPhotoUrl        = d['photoUrl'];
    });
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 75);
    if (picked != null && mounted) {
      setState(() => _pickedFile = File(picked.path));
    }
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);

    try {
      // Upload photo if a new one was picked
      String? newUrl = _savedPhotoUrl;
      if (_pickedFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_photos/$uid.jpg');
        await ref.putFile(_pickedFile!);
        newUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name':        _nameCtrl.text.trim(),
        'age':         int.tryParse(_ageCtrl.text)        ?? 0,
        'weight':      double.tryParse(_weightCtrl.text)  ?? 0.0,
        'height':      double.tryParse(_heightCtrl.text)  ?? 0.0,
        'nationality': _nationalityCtrl.text.trim(),
        'gender':      _gender,
        'goal':        _goal,
        if (newUrl != null) 'photoUrl': newUrl,
      });

      // Commit new photo URL locally so header refreshes immediately
      setState(() {
        _savedPhotoUrl = newUrl;
        _pickedFile    = null;
        _editing       = false;
        _saving        = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Profile updated!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _pickNationality() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NationalityPicker(),
    );
    if (result != null) setState(() => _nationalityCtrl.text = result);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _ageCtrl.dispose(); _weightCtrl.dispose();
    _heightCtrl.dispose(); _nationalityCtrl.dispose();
    super.dispose();
  }

  // Which image to show: picked file > saved url > placeholder
  Widget _buildAvatar({double size = 100}) {
    final radius = size / 2;
    Widget child;
    if (_pickedFile != null) {
      child = Image.file(_pickedFile!, fit: BoxFit.cover,
          width: size, height: size);
    } else if (_savedPhotoUrl != null) {
      child = Image.network(_savedPhotoUrl!, fit: BoxFit.cover,
          width: size, height: size,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.person_rounded, color: AppTheme.primary, size: size * 0.5));
    } else {
      child = Icon(Icons.person_rounded, color: AppTheme.primary, size: size * 0.5);
    }

    return Stack(children: [
      Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.accent.withOpacity(0.15),
          border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 2),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: ClipOval(child: child),
      ),
      if (_editing)
        Positioned(bottom: 0, right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(
                  color: AppTheme.primary, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 16),
            ),
          )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? 'N/A';

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      children: [
        // ── Top bar ─────────────────────────────────────────────────────────
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("My Profile", style: AppTheme.heading.copyWith(fontSize: 24)),
          GestureDetector(
            onTap: _editing ? _save : () => setState(() => _editing = true),
            child: _saving
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: AppTheme.primary))
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _editing ? AppTheme.primary : AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.1),
                          blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Text(_editing ? "Save" : "Edit",
                        style: TextStyle(
                            color: _editing ? Colors.white : AppTheme.primary,
                            fontWeight: FontWeight.bold)),
                  ),
          ),
        ]),
        const SizedBox(height: 28),

        // ── Avatar ───────────────────────────────────────────────────────────
        Center(child: _buildAvatar()),
        const SizedBox(height: 12),
        if (!_editing) ...[
          Center(child: Text(_nameCtrl.text.isNotEmpty ? _nameCtrl.text : "User",
              style: AppTheme.subheading.copyWith(fontSize: 18))),
          Center(child: Text(email, style: AppTheme.body.copyWith(fontSize: 13))),
        ],
        const SizedBox(height: 24),

        // ── Info card ────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.card(radius: 22),
          child: Column(children: [
            _row(Icons.email_outlined, "Email", email, readOnly: true),
            _div(),
            _editing
                ? _editField(Icons.person_outline_rounded, "Full Name", _nameCtrl, TextInputType.name)
                : _row(Icons.person_outline_rounded, "Name", _nameCtrl.text),
            _div(),
            _editing
                ? GestureDetector(
                    onTap: _pickNationality,
                    child: _row(Icons.flag_outlined, "Nationality",
                        _nationalityCtrl.text.isEmpty ? "Tap to select" : _nationalityCtrl.text,
                        trailing: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.muted, size: 18)))
                : _row(Icons.flag_outlined, "Nationality",
                    _nationalityCtrl.text.isEmpty ? "Not set" : _nationalityCtrl.text),
            _div(),
            _editing
                ? _genderToggle()
                : _row(Icons.wc_rounded, "Gender", _gender),
            _div(),
            _editing
                ? _goalDropdown()
                : _row(Icons.track_changes_rounded, "Goal", _goal),
          ]),
        ),
        const SizedBox(height: 18),

        // ── Stats ─────────────────────────────────────────────────────────────
        Row(children: [
          _stat("Age",    _ageCtrl,    "yrs"),
          const SizedBox(width: 12),
          _stat("Weight", _weightCtrl, "kg"),
          const SizedBox(width: 12),
          _stat("Height", _heightCtrl, "cm"),
        ]),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _div() => Divider(height: 28, color: AppTheme.divider);

  Widget _row(IconData icon, String label, String value,
      {bool readOnly = false, Widget? trailing}) {
    return Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTheme.label),
        Text(value, style: AppTheme.subheading.copyWith(
            fontSize: 14, color: readOnly ? AppTheme.muted : AppTheme.dark)),
      ])),
      if (trailing != null) trailing,
    ]);
  }

  Widget _editField(IconData icon, String label,
      TextEditingController ctrl, TextInputType type) {
    return Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(child: TextField(
        controller: ctrl,
        keyboardType: type,
        style: AppTheme.subheading.copyWith(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTheme.label,
          isDense: true,
          border: InputBorder.none,
        ),
      )),
    ]);
  }

  Widget _genderToggle() => Row(children: ["Male", "Female"].map((g) {
    final sel = _gender == g;
    return Expanded(child: Padding(
      padding: EdgeInsets.only(right: g == "Male" ? 6 : 0, left: g == "Female" ? 6 : 0),
      child: GestureDetector(
        onTap: () => setState(() => _gender = g),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary : AppTheme.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
          ),
          child: Center(child: Text(g, style: TextStyle(
              color: sel ? Colors.white : AppTheme.muted,
              fontWeight: FontWeight.w600, fontSize: 13))),
        ),
      ),
    ));
  }).toList());

  Widget _goalDropdown() => DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: _goal,
      isExpanded: true,
      style: AppTheme.subheading.copyWith(fontSize: 14),
      items: ["Weight Loss", "Muscle Gain", "Maintenance"]
          .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
      onChanged: (v) { if (v != null) setState(() => _goal = v); },
    ),
  );

  Widget _stat(String label, TextEditingController ctrl, String unit) =>
      Expanded(child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.card(radius: 18),
        child: Column(children: [
          Text(label, style: AppTheme.label),
          const SizedBox(height: 6),
          _editing
              ? TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTheme.subheading.copyWith(fontSize: 16),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    suffixText: unit,
                    suffixStyle: AppTheme.label,
                  ),
                )
              : Row(mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(ctrl.text.isNotEmpty ? ctrl.text : "0",
                        style: AppTheme.subheading.copyWith(fontSize: 16)),
                    Text(" $unit", style: AppTheme.label),
                  ]),
        ]),
      ));
}

// ── Re-usable Nationality Picker (same as in profile_form_screen) ────────────
class _NationalityPicker extends StatefulWidget {
  const _NationalityPicker();
  @override State<_NationalityPicker> createState() => _NationalityPickerState();
}

class _NationalityPickerState extends State<_NationalityPicker> {
  final _ctrl = TextEditingController();
  List<String> _list = List.from(kNationalities);

  void _filter(String q) => setState(() {
    _list = q.isEmpty
        ? List.from(kNationalities)
        : kNationalities
            .where((n) => n.toLowerCase().contains(q.toLowerCase()))
            .toList();
  });

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.85,
    maxChildSize: 0.95,
    minChildSize: 0.5,
    builder: (_, scroll) => Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 16),
        Text("Select Nationality", style: AppTheme.subheading),
        const SizedBox(height: 14),
        TextField(
          controller: _ctrl,
          onChanged: _filter,
          style: TextStyle(color: AppTheme.dark, fontSize: 14),
          decoration: AppTheme.inputDecoration(
              "Search nationality...", Icons.search_rounded),
        ),
        const SizedBox(height: 12),
        Expanded(child: ListView.builder(
          controller: scroll,
          itemCount: _list.length,
          itemBuilder: (_, i) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            title: Text(_list[i],
                style: TextStyle(color: AppTheme.dark, fontSize: 14)),
            onTap: () => Navigator.pop(context, _list[i]),
            trailing: Icon(Icons.chevron_right_rounded,
                color: AppTheme.muted, size: 18),
          ),
        )),
      ]),
    ),
  );
}
