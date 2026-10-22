class Teacher {
  final String id;
  final String employeeId;
  final String name;
  final String subject;
  final String gradesAssigned; // e.g. "5-10", "6-8"
  final String phone;
  final String email;
  final String schoolId;
  final String status; // "Active", "On Leave"
  final String designation; // e.g. "Assistant Teacher", "TGT", "PGT"

  const Teacher({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.subject,
    required this.gradesAssigned,
    required this.phone,
    required this.email,
    required this.schoolId,
    this.status = 'Active',
    this.designation = 'Assistant Teacher',
  });

  bool get isActive => status.toLowerCase() == 'active';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'subject': subject,
      'gradesAssigned': gradesAssigned,
      'phone': phone,
      'email': email,
      'schoolId': schoolId,
      'status': status,
      'designation': designation,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      name: map['name'] ?? '',
      subject: map['subject'] ?? '',
      gradesAssigned: map['gradesAssigned'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      schoolId: map['schoolId'] ?? '',
      status: map['status'] ?? 'Active',
      designation: map['designation'] ?? 'Assistant Teacher',
    );
  }

  Teacher copyWith({
    String? id,
    String? employeeId,
    String? name,
    String? subject,
    String? gradesAssigned,
    String? phone,
    String? email,
    String? schoolId,
    String? status,
    String? designation,
  }) {
    return Teacher(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      gradesAssigned: gradesAssigned ?? this.gradesAssigned,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      schoolId: schoolId ?? this.schoolId,
      status: status ?? this.status,
      designation: designation ?? this.designation,
    );
  }
}
