import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dashboard_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  static const Color primaryOrange = Color(0xFFF37E33);
  static const Color darkText = Color(0xFF1A1A1A);
  static const Color background = Color(0xFFF8F4EF);

  final _addressController = TextEditingController();
  String? _selectedTrainer;
  DateTime? _selectedDate;
  String? _selectedTime;
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  static const LatLng _defaultLocation = LatLng(31.9539, 35.9106); // Amman, Jordan

  final List<Map<String, dynamic>> _trainers = [
    {"name": "Ahmed Al-Rashid", "specialty": "Strength & Conditioning", "rating": 4.9, "price": 60.0},
    {"name": "Sara Mansour", "specialty": "Nutrition & Weight Loss", "rating": 4.8, "price": 55.0},
    {"name": "Khalid Nasser", "specialty": "Muscle Building", "rating": 4.7, "price": 65.0},
    {"name": "Lara Haddad", "specialty": "Yoga & Recovery", "rating": 5.0, "price": 50.0},
  ];

  final List<String> _timeSlots = ["9:00 AM", "10:00 AM", "11:00 AM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"];

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() => _selectedLocation = latLng);
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: primaryOrange),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  double get _totalPrice {
    if (_selectedTrainer == null) return 0;
    return _trainers.firstWhere((t) => t["name"] == _selectedTrainer)["price"] as double;
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
        title: const Text("Book Consultation", style: TextStyle(color: darkText, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Trainer Selection ──
          const Text("Choose Your Trainer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
          const SizedBox(height: 12),
          ...(_trainers.map((trainer) => GestureDetector(
                onTap: () => setState(() => _selectedTrainer = trainer["name"] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedTrainer == trainer["name"] ? primaryOrange : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
                    border: Border.all(
                      color: _selectedTrainer == trainer["name"] ? primaryOrange : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _selectedTrainer == trainer["name"] ? Colors.white.withOpacity(0.2) : primaryOrange.withOpacity(0.1),
                        child: Icon(Icons.person_rounded, color: _selectedTrainer == trainer["name"] ? Colors.white : primaryOrange),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trainer["name"] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _selectedTrainer == trainer["name"] ? Colors.white : darkText,
                              ),
                            ),
                            Text(
                              trainer["specialty"] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: _selectedTrainer == trainer["name"] ? Colors.white.withOpacity(0.7) : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.star_rounded, size: 14, color: _selectedTrainer == trainer["name"] ? Colors.white : primaryOrange),
                              const SizedBox(width: 3),
                              Text("${trainer["rating"]}", style: TextStyle(fontSize: 12, color: _selectedTrainer == trainer["name"] ? Colors.white : primaryOrange, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            "\$${(trainer["price"] as double).toStringAsFixed(0)}/hr",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _selectedTrainer == trainer["name"] ? Colors.white : darkText),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ))),

          const SizedBox(height: 20),

          // ── Date & Time ──
          const Text("Pick Date & Time", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, color: primaryOrange),
                  const SizedBox(width: 14),
                  Text(
                    _selectedDate == null
                        ? "Select a date"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: TextStyle(
                      color: _selectedDate == null ? Colors.black38 : darkText,
                      fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final time = _timeSlots[index];
                final isSelected = time == _selectedTime;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryOrange : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                    ),
                    child: Center(
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Address ──
          const Text("Your Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: "Enter your address",
              prefixIcon: const Icon(Icons.home_outlined, color: primaryOrange),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: primaryOrange, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Map ──
          const Text("Pin Your Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _selectedLocation ?? _defaultLocation, zoom: 14),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: _selectedLocation != null
                        ? {Marker(markerId: const MarkerId("user"), position: _selectedLocation!)}
                        : {},
                    onTap: (latLng) => setState(() => _selectedLocation = latLng),
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _getCurrentLocation,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                        child: const Icon(Icons.my_location_rounded, color: primaryOrange, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Book Button ──
          if (_selectedTrainer != null && _selectedDate != null && _selectedTime != null)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Consultation Fee", style: TextStyle(color: Colors.black45)),
                      Text("\$${_totalPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: primaryOrange.withOpacity(0.4),
                      ),
                      onPressed: () {
                        CartManager().addItem(CartItem(
                          id: "consult_${_selectedTrainer}_${DateTime.now().millisecondsSinceEpoch}",
                          name: "Consultation: $_selectedTrainer",
                          price: _totalPrice,
                          quantity: 1,
                          icon: Icons.video_call_rounded,
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Booking added to cart! Complete payment to confirm."), backgroundColor: Colors.green),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text("Book & Pay  →", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
