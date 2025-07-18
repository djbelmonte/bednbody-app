// run this once in your Flutter app (e.g. in a debug screen or cloud function)
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedBranches() async {
  final branches = [
    {
      'name': 'Angono',
      'address': 'Angono, Rizal, Philippines',
      'location': GeoPoint(14.526, 121.150), // from Philatlas / Wikipedia :contentReference[oaicite:1]{index=1}
    },
    {
      'name': 'Cainta',
      'address': 'Cainta, Rizal, Philippines',
      'location': GeoPoint(14.58, 121.1153), // from Philatlas :contentReference[oaicite:2]{index=2}
    },
    {
      'name': 'Westbank Floodway',
      'address': 'Westbank Floodway, Taytay/Cainta, Rizal, Philippines',
      'location': GeoPoint(14.525, 121.13611), // from Manggahan Floodway coords :contentReference[oaicite:3]{index=3}
    },
    {
      'name': 'Taytay',
      'address': 'Taytay, Rizal, Philippines',
      'location': GeoPoint(14.56917, 121.1325), // from Wikipedia :contentReference[oaicite:4]{index=4}
    },
    {
      'name': 'Fairview',
      'address': 'Fairview, Quezon City, Metro Manila', // add correct coords yourself
      'location': GeoPoint(14.649, 121.067), // approximate
    },
    {
      'name': 'Karangalan',
      'address': 'Karangalan Village, Cainta, Rizal, Philippines',
      'location': GeoPoint(14.6083, 121.1045), // approximate within Cainta :contentReference[oaicite:5]{index=5}
    },
    {
      'name': 'Cogeo',
      'address': 'Cogeo, Antipolo, Rizal, Philippines',
      'location': GeoPoint(14.611, 121.119), // approximate
    },
    {
      'name': 'Antipolo',
      'address': 'Antipolo, Rizal, Philippines',
      'location': GeoPoint(14.6091, 121.0958), // approximate
    },
    {
      'name': 'Pasig',
      'address': 'Pasig, Metro Manila, Philippines',
      'location': GeoPoint(14.5764, 121.0851), // approximate
    },
    {
      'name': 'Marikina',
      'address': 'Marikina, Metro Manila, Philippines',
      'location': GeoPoint(14.6506, 121.1024), // approximate
    },
    {
      'name': 'Rizal Ave. Taytay',
      'address': 'Rizal Avenue, Taytay, Rizal, Philippines',
      'location': GeoPoint(14.56917, 121.1325), // same as Taytay center
    },
  ];

  final batch = FirebaseFirestore.instance.batch();
  final col = FirebaseFirestore.instance.collection('branches');

  for (var branch in branches) {
    final docRef = col.doc(branch['name'].toString().replaceAll(' ', '_').toLowerCase());
    batch.set(docRef, {
      'name': branch['name'],
      'address': branch['address'],
      'location': branch['location'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  await batch.commit();
  print('📍 Seeded ${branches.length} branches.');
}
