import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String category;
  final List<String> searchTerms;

  Medicine({
    required this.id,
    required this.name,
    required this.category,
    required this.searchTerms,
  });

  factory Medicine.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Medicine(
      id: doc.id,
      name: (data['name'] ?? data['medicineName'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      searchTerms: (data['searchTerms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'searchTerms': searchTerms,
    };
  }
}
