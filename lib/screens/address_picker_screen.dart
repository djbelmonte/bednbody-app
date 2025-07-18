import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class AddressPickerScreen extends StatefulWidget {
  final Function(String address, LatLng coordinates) onLocationPicked;

  const AddressPickerScreen({super.key, required this.onLocationPicked});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  LatLng? _selectedPosition;
  MapController _mapController = MapController();

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5");
    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterApp (youremail@example.com)' // required by Nominatim
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        _suggestions = data
            .map((item) => {
                  'display_name': item['display_name'],
                  'lat': double.parse(item['lat']),
                  'lon': double.parse(item['lon']),
                })
            .toList();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_selectedPosition!, 15.0);
  }

  void _selectLocation(Map<String, dynamic> place) {
    final latLng = LatLng(place['lat'], place['lon']);
    setState(() {
      _selectedPosition = latLng;
      _suggestions = [];
    });
    _mapController.move(latLng, 16.0);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Address')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for address',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchPlaces(_searchController.text),
                ),
              ),
              onSubmitted: _searchPlaces,
            ),
          ),
          if (_suggestions.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (_, index) {
                  final place = _suggestions[index];
                  return ListTile(
                    title: Text(place['display_name']),
                    onTap: () => _selectLocation(place),
                  );
                },
              ),
            )
          else
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _selectedPosition ?? LatLng(14.5995, 120.9842), // Manila
                  zoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() => _selectedPosition = point);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (_selectedPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: _selectedPosition!,
                          child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Confirm Location"),
              onPressed: _selectedPosition == null
                  ? null
                  : () async {
                      final response = await http.get(Uri.parse(
                          "https://nominatim.openstreetmap.org/reverse?lat=${_selectedPosition!.latitude}&lon=${_selectedPosition!.longitude}&format=json"));
                      final data = json.decode(response.body);
                      final address = data['display_name'] ?? "Unknown location";
                      widget.onLocationPicked(address, _selectedPosition!);
                      Navigator.pop(context);
                    },
            ),
          ),
        ],
      ),
    );
  }
}
