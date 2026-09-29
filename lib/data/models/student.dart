class Student {
  final String id;
  final String grNumber;
  final String rollNumber;
  final String nameInSchool;
  final String nameInAadhaar;
  final String aadhaarNo;
  final String apaarId;
  final String penNumber;
  final String dob;
  final String gender;
  final String standard;
  final String section;
  final String parentName;
  final String parentPhone;
  final String bankAccount;
  final String ifscCode;
  final bool isAadhaarVerified;
  final bool hasMismatch;
  final bool apaarConsentSigned;
  bool isPresentToday;

  Student({
    required this.id,
    required this.grNumber,
    required this.rollNumber,
    required this.nameInSchool,
    required this.nameInAadhaar,
    required this.aadhaarNo,
    required this.apaarId,
    required this.penNumber,
    required this.dob,
    required this.gender,
    required this.standard,
    required this.section,
    required this.parentName,
    required this.parentPhone,
    required this.bankAccount,
    required this.ifscCode,
    this.isAadhaarVerified = false,
    this.hasMismatch = false,
    this.apaarConsentSigned = false,
    this.isPresentToday = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grNumber': grNumber,
      'rollNumber': rollNumber,
      'nameInSchool': nameInSchool,
      'nameInAadhaar': nameInAadhaar,
      'aadhaarNo': aadhaarNo,
      'apaarId': apaarId,
      'penNumber': penNumber,
      'dob': dob,
      'gender': gender,
      'standard': standard,
      'section': section,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'bankAccount': bankAccount,
      'ifscCode': ifscCode,
      'isAadhaarVerified': isAadhaarVerified ? 1 : 0,
      'hasMismatch': hasMismatch ? 1 : 0,
      'apaarConsentSigned': apaarConsentSigned ? 1 : 0,
      'isPresentToday': isPresentToday ? 1 : 0,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] ?? '',
      grNumber: map['grNumber'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      nameInSchool: map['nameInSchool'] ?? '',
      nameInAadhaar: map['nameInAadhaar'] ?? '',
      aadhaarNo: map['aadhaarNo'] ?? '',
      apaarId: map['apaarId'] ?? '',
      penNumber: map['penNumber'] ?? '',
      dob: map['dob'] ?? '',
      gender: map['gender'] ?? 'M',
      standard: map['standard'] ?? '4',
      section: map['section'] ?? 'A',
      parentName: map['parentName'] ?? '',
      parentPhone: map['parentPhone'] ?? '',
      bankAccount: map['bankAccount'] ?? '',
      ifscCode: map['ifscCode'] ?? '',
      isAadhaarVerified: map['isAadhaarVerified'] == 1 || map['isAadhaarVerified'] == true,
      hasMismatch: map['hasMismatch'] == 1 || map['hasMismatch'] == true,
      apaarConsentSigned: map['apaarConsentSigned'] == 1 || map['apaarConsentSigned'] == true,
      isPresentToday: map['isPresentToday'] == 1 || map['isPresentToday'] == true,
    );
  }

  Student copyWith({
    String? id,
    String? grNumber,
    String? rollNumber,
    String? nameInSchool,
    String? nameInAadhaar,
    String? aadhaarNo,
    String? apaarId,
    String? penNumber,
    String? dob,
    String? gender,
    String? standard,
    String? section,
    String? parentName,
    String? parentPhone,
    String? bankAccount,
    String? ifscCode,
    bool? isAadhaarVerified,
    bool? hasMismatch,
    bool? apaarConsentSigned,
    bool? isPresentToday,
  }) {
    return Student(
      id: id ?? this.id,
      grNumber: grNumber ?? this.grNumber,
      rollNumber: rollNumber ?? this.rollNumber,
      nameInSchool: nameInSchool ?? this.nameInSchool,
      nameInAadhaar: nameInAadhaar ?? this.nameInAadhaar,
      aadhaarNo: aadhaarNo ?? this.aadhaarNo,
      apaarId: apaarId ?? this.apaarId,
      penNumber: penNumber ?? this.penNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      standard: standard ?? this.standard,
      section: section ?? this.section,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      bankAccount: bankAccount ?? this.bankAccount,
      ifscCode: ifscCode ?? this.ifscCode,
      isAadhaarVerified: isAadhaarVerified ?? this.isAadhaarVerified,
      hasMismatch: hasMismatch ?? this.hasMismatch,
      apaarConsentSigned: apaarConsentSigned ?? this.apaarConsentSigned,
      isPresentToday: isPresentToday ?? this.isPresentToday,
    );
  }
}
