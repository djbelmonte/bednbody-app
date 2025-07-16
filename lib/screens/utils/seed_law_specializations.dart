import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedLawSpecializations() async {
  final specializations = [
    {
      "name": "Criminal Law",
      "description": "Deals with crimes, prosecution, penalties, and criminal defense."
    },
    {
      "name": "Civil Law",
      "description": "Covers personal disputes such as contracts, damages, property, and family issues."
    },
    {
      "name": "Family Law",
      "description": "Focuses on legal issues related to family relationships including marriage, divorce, and custody."
    },
    {
      "name": "Labor Law",
      "description": "Governs employer-employee relationships, including rights and obligations."
    },
    {
      "name": "Taxation Law",
      "description": "Deals with the rules, policies, and laws that oversee the tax process."
    },
    {
      "name": "Corporate Law",
      "description": "Regulates the formation, operation, and governance of corporations and businesses."
    },
    {
      "name": "Intellectual Property Law",
      "description": "Protects creations of the mind like inventions, literary works, and symbols."
    },
    {
      "name": "Environmental Law",
      "description": "Regulates the interaction between humans and the natural environment."
    },
    {
      "name": "Human Rights Law",
      "description": "Focuses on protecting the basic rights and freedoms of individuals."
    },
    {
      "name": "Election Law",
      "description": "Governs the conduct of elections, political campaigns, and voting procedures."
    },
    {
      "name": "Immigration Law",
      "description": "Regulates entry, stay, and status of individuals within a country."
    },
    {
      "name": "Maritime Law",
      "description": "Deals with matters related to shipping, navigation, and marine resources."
    },
    {
      "name": "Agrarian Law",
      "description": "Relates to land distribution and rights of farmers and landowners."
    },
    {
      "name": "Administrative Law",
      "description": "Covers the rules and regulations of government agencies."
    },
    {
      "name": "Public International Law",
      "description": "Governs relationships between sovereign nations and international entities."
    },
    {
      "name": "Private International Law",
      "description": "Addresses conflicts between private individuals across borders."
    },
    {
      "name": "Banking and Finance Law",
      "description": "Regulates financial institutions, transactions, and lending practices."
    }
  ];

  final collection = FirebaseFirestore.instance.collection('law_specializations');

  for (var spec in specializations) {
    final query = await collection.where('name', isEqualTo: spec['name']).get();

    if (query.docs.isEmpty) {
      await collection.add(spec);
      print("✅ Added: \${spec['name']}");
    } else {
      print("⏩ Skipped (already exists): \${spec['name']}");
    }
  }

  print("✅ Seeding complete.");
}
