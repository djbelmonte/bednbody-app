import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class FinalizeBookingScreen extends StatefulWidget {
  final String branch;
  final List<Map<String, dynamic>> selectedServices;
  final double totalAmount;

  const FinalizeBookingScreen({
    super.key,
    required this.branch,
    required this.selectedServices,
    required this.totalAmount,
  });

  @override
  State<FinalizeBookingScreen> createState() => _FinalizeBookingScreenState();
}

class _FinalizeBookingScreenState extends State<FinalizeBookingScreen> {
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _addressFocusNode = FocusNode();
  String? _userName;
  bool _loading = true;
  LatLng? _pickedLocation;
  List<Map<String, dynamic>> _suggestions = [];

  final _openCageApiKey = "761993462408478eb0b20cfeedc1d76f"; // Replace this

  @override
  void initState() {
    super.initState();
    _fetchUser();

    _addressController.addListener(() {
      if (_addressFocusNode.hasFocus && _addressController.text.length > 3) {
        _fetchAddressSuggestions(_addressController.text);
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  Future<void> _fetchUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final name = "${doc['first_name']} ${doc['last_name']}";
      setState(() {
        _userName = name;
        _loading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied')),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _updateLocation(position.latitude, position.longitude);
  }

  Future<void> _updateLocation(double lat, double lng) async {
    setState(() {
      _pickedLocation = LatLng(lat, lng);
    });

    final url = Uri.parse("https://api.opencagedata.com/geocode/v1/json?q=$lat+$lng&key=$_openCageApiKey&countrycode=ph");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final address = data['results'][0]['formatted'];
      setState(() {
        _addressController.text = address;
      });
    }
  }

  Future<void> _fetchAddressSuggestions(String query) async {
    final url = Uri.parse("https://api.opencagedata.com/geocode/v1/json?q=$query&key=$_openCageApiKey&countrycode=ph");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)['results'];
      setState(() {
        _suggestions = results
            .map<Map<String, dynamic>>((r) => {
                  'formatted': r['formatted'],
                  'lat': r['geometry']['lat'],
                  'lng': r['geometry']['lng'],
                })
            .toList();
      });
    }
  }

  Future<void> _confirmBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: const Text("Please confirm that the details you entered are correct."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'name': _userName,
        'contact': _contactController.text,
        'branch': widget.branch,
        'address': _addressController.text,
        'location': _pickedLocation != null
            ? {'lat': _pickedLocation!.latitude, 'lng': _pickedLocation!.longitude}
            : null,
        'services': widget.selectedServices,
        'total': widget.totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking confirmed!")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Finalize your Booking")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildLabel("Name"),
            // TextFormField(initialValue: _userName, readOnly: true, decoration: const InputDecoration(border: OutlineInputBorder())),
            // const SizedBox(height: 16),

            // _buildLabel("Contact Number"),
            // TextFormField(
            //   controller: _contactController,
            //   keyboardType: TextInputType.phone,
            //   decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter contact number"),
            // ),
            // const SizedBox(height: 16),

            _buildLabel("Address"),
            TextFormField(
              controller: _addressController,
              focusNode: _addressFocusNode,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Enter or search address"),
            ),
            if (_suggestions.isNotEmpty)
              Container(
                height: 150,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (_, index) {
                    final s = _suggestions[index];
                    return ListTile(
                      title: Text(s['formatted']),
                      onTap: () {
                        _addressController.text = s['formatted'];
                        _pickedLocation = LatLng(s['lat'], s['lng']);
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _suggestions = [];
                        });
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.my_location),
              label: const Text("Use current location"),
              onPressed: _getCurrentLocation,
            ),

            const SizedBox(height: 16),
            if (_pickedLocation != null)
              SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(center: _pickedLocation, zoom: 16),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.attorneed',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: _pickedLocation!,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            _buildLabel("Summary"),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedServices.length,
                itemBuilder: (_, index) {
                  final item = widget.selectedServices[index];
                  return ListTile(
                    dense: true,
                    title: Text(item['name']),
                    trailing: Text("₱${item['price']}"),
                    subtitle: Text(item['description'], style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text("Total: ₱${widget.totalAmount}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _contactController.text.trim().isEmpty ? null : _confirmBooking,
                child: const Text("Confirm Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: Theme.of(context).textTheme.labelMedium);
}
