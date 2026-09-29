enum AssetCondition {
  working,
  minorIssue,
  damaged,
}

extension AssetConditionExtension on AssetCondition {
  String get label {
    switch (this) {
      case AssetCondition.working:
        return 'Functional (सुरु आहे)';
      case AssetCondition.minorIssue:
        return 'Minor Issue (दुरुस्ती आवश्यक)';
      case AssetCondition.damaged:
        return 'Damaged / Broken (नादुरुस्त)';
    }
  }
}

class SchoolAsset {
  final String id;
  final String name;
  final String category; // 'Furniture', 'Electronics / Smart TV', 'Drinking Water & Sanitation', 'Sports & Lab'
  final int quantity;
  final AssetCondition condition;
  final String fundingScheme; // 'Samagra Shiksha', 'CSR Grant', 'ZP District Fund'
  final String location;
  final String purchaseYear;
  final String remarks;

  SchoolAsset({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.condition,
    required this.fundingScheme,
    required this.location,
    required this.purchaseYear,
    this.remarks = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'condition': condition.name,
      'fundingScheme': fundingScheme,
      'location': location,
      'purchaseYear': purchaseYear,
      'remarks': remarks,
    };
  }

  factory SchoolAsset.fromMap(Map<String, dynamic> map) {
    return SchoolAsset(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Furniture',
      quantity: map['quantity'] ?? 1,
      condition: AssetCondition.values.firstWhere(
        (e) => e.name == map['condition'],
        orElse: () => AssetCondition.working,
      ),
      fundingScheme: map['fundingScheme'] ?? 'Samagra Shiksha',
      location: map['location'] ?? 'Classroom',
      purchaseYear: map['purchaseYear'] ?? '2023',
      remarks: map['remarks'] ?? '',
    );
  }
}
