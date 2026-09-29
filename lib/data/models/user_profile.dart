enum UserRole {
  teacher,
  headmaster,
  officer,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'Class Teacher (वर्गशिक्षक)';
      case UserRole.headmaster:
        return 'Headmaster (मुख्याध्यापक)';
      case UserRole.officer:
        return 'Cluster/Block Officer (गटशिक्षणाधिकारी)';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.headmaster:
        return 'Headmaster';
      case UserRole.officer:
        return 'Officer';
    }
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String schoolName;
  final String udiseCode;
  final String clusterName;
  final String blockTaluka;
  final String district;
  final String assignedClass;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.schoolName,
    required this.udiseCode,
    required this.clusterName,
    required this.blockTaluka,
    required this.district,
    required this.assignedClass,
  });

  String get roleDisplayName => role.displayName;
  String get schoolOrJurisdiction => role == UserRole.officer ? '$clusterName • $blockTaluka' : schoolName;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'schoolName': schoolName,
      'udiseCode': udiseCode,
      'clusterName': clusterName,
      'blockTaluka': blockTaluka,
      'district': district,
      'assignedClass': assignedClass,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.teacher,
      ),
      schoolName: map['schoolName'] ?? '',
      udiseCode: map['udiseCode'] ?? '',
      clusterName: map['clusterName'] ?? '',
      blockTaluka: map['blockTaluka'] ?? '',
      district: map['district'] ?? '',
      assignedClass: map['assignedClass'] ?? '',
    );
  }
}
