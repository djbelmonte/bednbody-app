import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'finalize_booking_screen.dart';

class ChooseServiceScreen extends StatefulWidget {
  final String selectedBranch;

  const ChooseServiceScreen({super.key, required this.selectedBranch});

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  final Map<String, List<Map<String, dynamic>>> _groupedServices = {
    'Specialized': [],
    'Premium': [],
    'Add On': [],
  };

  final List<Map<String, dynamic>> _basket = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final snapshot = await FirebaseFirestore.instance.collection('services').get();
    final services = snapshot.docs.map((doc) => doc.data()).toList();

    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Specialized': [],
      'Premium': [],
      'Add On': [],
    };

    for (var service in services) {
      final type = service['service_type'];
      if (grouped.containsKey(type)) {
        grouped[type]!.add(service);
      }
    }

    setState(() {
      _groupedServices.clear();
      _groupedServices.addAll(grouped);
      _isLoading = false;
    });
  }

  void _addToBasket(Map<String, dynamic> service) {
    setState(() {
      _basket.add(service);
    });
  }

  double get totalPrice => _basket.fold<double>(0.0, (sum, item) => sum + (item['price'] ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // This ensures the back button is shown
        title: Text("Choose Services"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: _groupedServices.entries.expand((entry) {
                        final type = entry.key;
                        final groupedByKey = <String, List<Map<String, dynamic>>>{};

                        for (var service in entry.value) {
                          final key = service['key'];
                          groupedByKey.putIfAbsent(key, () => []).add(service);
                        }

                        final sortedEntries = groupedByKey.entries.toList()
                          ..sort((a, b) => a.key.compareTo(b.key));

                        return [
                          Text(
                            type,
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...sortedEntries.expand((group) => group.value.map((service) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                service['name'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '₱${service['price']}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () => _addToBasket(service),
                                              child: const Text("Add"),
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service['description'] ?? '',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }))
                        ];
                      }).toList(),
                    ),
            ),

            // Sticky Basket
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, -4), // upward shadow
                  ),
                ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_basket.isNotEmpty)
                      Column(
                        children: _basket.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['name'],
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '₱${item['price'].toString()}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _basket.remove(item);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            "Your basket is empty",
                            style: TextStyle(
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ), 
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ₱$totalPrice',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _basket.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FinalizeBookingScreen(
                                        branch: widget.selectedBranch,
                                        selectedServices: _basket,
                                        totalAmount: totalPrice,
                                      ),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Proceed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B2F25),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(fontWeight: FontWeight.w600),
                            disabledBackgroundColor: Colors.grey.shade400,
                            disabledForegroundColor: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}
