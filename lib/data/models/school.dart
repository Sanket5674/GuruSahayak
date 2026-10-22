class School {
  final String id;
  final String udiseCode;
  final String nameEn;
  final String nameMr;
  final String district;
  final String blockTaluka;
  final String cluster;
  final String type; // Primary, Upper Primary, Secondary, Higher Secondary
  final int totalStudents;
  final int totalTeachers;
  final String headmasterName;

  const School({
    required this.id,
    required this.udiseCode,
    required this.nameEn,
    required this.nameMr,
    required this.district,
    required this.blockTaluka,
    required this.cluster,
    required this.type,
    required this.totalStudents,
    required this.totalTeachers,
    required this.headmasterName,
  });

  String localizedName(bool isMarathi) => isMarathi ? nameMr : nameEn;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'udiseCode': udiseCode,
      'nameEn': nameEn,
      'nameMr': nameMr,
      'district': district,
      'blockTaluka': blockTaluka,
      'cluster': cluster,
      'type': type,
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'headmasterName': headmasterName,
    };
  }

  factory School.fromMap(Map<String, dynamic> map) {
    return School(
      id: map['id'] ?? '',
      udiseCode: map['udiseCode'] ?? '',
      nameEn: map['nameEn'] ?? '',
      nameMr: map['nameMr'] ?? '',
      district: map['district'] ?? '',
      blockTaluka: map['blockTaluka'] ?? '',
      cluster: map['cluster'] ?? '',
      type: map['type'] ?? '',
      totalStudents: map['totalStudents'] is int ? map['totalStudents'] : int.tryParse(map['totalStudents']?.toString() ?? '0') ?? 0,
      totalTeachers: map['totalTeachers'] is int ? map['totalTeachers'] : int.tryParse(map['totalTeachers']?.toString() ?? '0') ?? 0,
      headmasterName: map['headmasterName'] ?? '',
    );
  }
}
