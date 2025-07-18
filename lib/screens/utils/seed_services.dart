import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedServices() async {
  final firestore = FirebaseFirestore.instance;
  final servicesRef = firestore.collection('services');

  final List<Map<String, dynamic>> services = [
    // SPECIALIZED
    {
      "name": "Full Body Massage - 1 hr",
      "description": "Combination of Swedish and Shiatsu with Body Stretching",
      "price": 299,
      "service_type": "Specialized",
      "key": "full_body"
    },
    {
      "name": "Full Body Massage - 1.5 hrs",
      "description": "Combination of Swedish and Shiatsu with Body Stretching",
      "price": 499,
      "service_type": "Specialized",
      "key": "full_body"
    },
    {
      "name": "Full Body Massage - 2 hrs",
      "description": "Combination of Swedish and Shiatsu with Body Stretching",
      "price": 598,
      "service_type": "Specialized",
      "key": "full_body"
    },
    {
      "name": "Foot Reflex Massage - 1 hr",
      "description": "Foot and Hand Reflexology Treatment",
      "price": 349,
      "service_type": "Specialized",
      "key": "foot_reflex"
    },
    {
      "name": "Foot Reflex Massage - 1.5 hrs",
      "description": "Foot and Hand Reflexology Treatment",
      "price": 529,
      "service_type": "Specialized",
      "key": "foot_reflex"
    },
    {
      "name": "Foot Reflex Massage - 2 hrs",
      "description": "Foot and Hand Reflexology Treatment",
      "price": 698,
      "service_type": "Specialized",
      "key": "foot_reflex"
    },
    {
      "name": "Deep Tissue Massage - 1 hr",
      "description": "Structural Heavy Pressure Massage",
      "price": 499,
      "service_type": "Specialized",
      "key": "deep_tissue"
    },
    {
      "name": "Deep Tissue Massage - 1.5 hrs",
      "description": "Structural Heavy Pressure Massage",
      "price": 749,
      "service_type": "Specialized",
      "key": "deep_tissue"
    },
    {
      "name": "Deep Tissue Massage - 2 hrs",
      "description": "Structural Heavy Pressure Massage",
      "price": 998,
      "service_type": "Specialized",
      "key": "deep_tissue"
    },
    {
      "name": "Dry Massage - 1 hr",
      "description": "Namikoshi Shiatsu Massage Therapy",
      "price": 499,
      "service_type": "Specialized",
      "key": "dry"
    },
    {
      "name": "Dry Massage - 1.5 hrs",
      "description": "Namikoshi Shiatsu Massage Therapy",
      "price": 749,
      "service_type": "Specialized",
      "key": "dry"
    },
    {
      "name": "Dry Massage - 2 hrs",
      "description": "Namikoshi Shiatsu Massage Therapy",
      "price": 998,
      "service_type": "Specialized",
      "key": "dry"
    },
    {
      "name": "Pregnant Massage - 1 hr",
      "description": "Postnatal and Prenatal Massage",
      "price": 599,
      "service_type": "Specialized",
      "key": "pregnant"
    },
    {
      "name": "Pregnant Massage - 1.5 hrs",
      "description": "Postnatal and Prenatal Massage",
      "price": 799,
      "service_type": "Specialized", 
      "key": "pregnant"
    },
    {
      "name": "Pregnant Massage - 2 hrs",
      "description": "Postnatal and Prenatal Massage",
      "price": 999,
      "service_type": "Specialized", 
      "key": "pregnant"
    },

    // PREMIUM
    {
      "name": "Premium Therapeutic - 1 hr",
      "description": "Ventosa Therapy with Hot Stone Treatment and Combination Massage",
      "price": 799,
      "service_type": "Premium",
      "key": "therapeutic"
    },
    {
      "name": "Premium Therapeutic - 1.5 hrs",
      "description": "Ventosa Therapy with Hot Stone Treatment and Combination Massage",
      "price": 999,
      "service_type": "Premium",
      "key": "therapeutic"
    },
    {
      "name": "Premium Therapeutic - 2 hrs",
      "description": "Ventosa Therapy with Hot Stone Treatment and Combination Massage",
      "price": 1199,
      "service_type": "Premium",
      "key": "therapeutic"
    },
    {
      "name": "Couple Massage Promo - 1 hr",
      "description": "Combination of Swedish and Shiatsu with Body Stretching for Two",
      "price": 849,
      "service_type": "Premium",
      "key": "couple"
    },
    {
      "name": "Couple Massage Promo - 1.5 hrs",
      "description": "Combination of Swedish and Shiatsu with Body Stretching for Two",
      "price": 1149,
      "service_type": "Premium",
      "key": "couple"
    },
    {
      "name": "Couple Massage Promo - 2 hrs",
      "description": "Combination of Swedish and Shiatsu with Body Stretching for Two",
      "price": 1440,
      "service_type": "Premium",
      "key": "couple"
    },
    {
      "name": "Ventosa Therapy - 1 hr",
      "description": "Traditional Cupping Massage Therapy",
      "price": 599,
      "service_type": "Premium",
      "key": "ventosa"
    },
    {
      "name": "Ventosa Therapy - 1.5 hrs",
      "description": "Traditional Cupping Massage Therapy",
      "price": 799,
      "service_type": "Premium",
      "key": "ventosa"
    },
    {
      "name": "Ventosa Therapy - 2 hrs",
      "description": "Traditional Cupping Massage Therapy",
      "price": 998,
      "service_type": "Premium",
      "key": "ventosa"
    },
    {
      "name": "Hot Stone Treatment - 1 hr",
      "description": "Hot Stone Healing Massage Treatment",
      "price": 599,
      "service_type": "Premium",
      "key": "hot_stone"
    },
    {
      "name": "Hot Stone Treatment - 1.5 hrs",
      "description": "Hot Stone Healing Massage Treatment",
      "price": 799,
      "service_type": "Premium",
      "key": "hot_stone"
    },
    {
      "name": "Hot Stone Treatment - 2 hrs",
      "description": "Hot Stone Healing Massage Treatment",
      "price": 998,
      "service_type": "Premium",
      "key": "hot_stone"
    },

    // ADD-ONS
    {
      "name": "Ear Candling",
      "description": "Ear wax removal through heat suction",
      "price": 200,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Hot Compress Therapy",
      "description": "Hot compress therapy to relieve muscle pain",
      "price": 200,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Hand Massage / 15 mins",
      "description": "Quick massage focused on hand relief",
      "price": 100,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Kiddie Massage / 40 mins",
      "description": "Gentle massage designed for kids",
      "price": 250,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Full Body Massage / 30 mins Extension",
      "description": "Extension for Full Body Massage",
      "price": 150,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Foot Reflex / 30 mins Extension",
      "description": "Extension for Foot Reflex Massage",
      "price": 175,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Deep Tissue / 30 mins Extension",
      "description": "Extension for Deep Tissue Massage",
      "price": 250,
      "service_type": "Add On",
      "key": "generic"
    },
    {
      "name": "Pregnant Massage / 30 mins Extension",
      "description": "Extension for Prenatal or Postnatal Massage",
      "price": 300,
      "service_type": "Add On",
      "key": "generic"
    },
  ];

  for (var service in services) {
    final existing = await servicesRef.where('name', isEqualTo: service['name']).get();
    if (existing.docs.isEmpty) {
      await servicesRef.add(service);
      print("✅ Added: ${service['name']}");
    } else {
      print("⏭️ Skipped (exists): ${service['name']}");
    }
  }

  print("🎉 Services seeding complete.");
}
