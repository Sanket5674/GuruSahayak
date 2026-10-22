enum UserRole {
  admin,
  officer,
  headmaster,
  teacher,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'System Administrator (प्रशासक)';
      case UserRole.officer:
        return 'Cluster/Block Officer (गटशिक्षणाधिकारी)';
      case UserRole.headmaster:
        return 'Headmaster (मुख्याध्यापक)';
      case UserRole.teacher:
        return 'Class Teacher (वर्गशिक्षक)';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.officer:
        return 'Officer';
      case UserRole.headmaster:
        return 'Headmaster';
      case UserRole.teacher:
        return 'Teacher';
    }
  }

  String get marathiName {
    switch (this) {
      case UserRole.admin:
        return 'प्रशासक';
      case UserRole.officer:
        return 'गटशिक्षणाधिकारी';
      case UserRole.headmaster:
        return 'मुख्याध्यापक';
      case UserRole.teacher:
        return 'वर्गशिक्षक';
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
  String get schoolOrJurisdiction {
    if (role == UserRole.admin) {
      return 'District Education Office (जिल्हा शिक्षण विभाग)';
    } else if (role == UserRole.officer) {
      return '$clusterName • $blockTaluka';
    }
    return schoolName;
  }

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
