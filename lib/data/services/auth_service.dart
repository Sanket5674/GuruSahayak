import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class AuthService extends ChangeNotifier {
  UserProfile _currentUser = _defaultTeacher;
  bool _isLoggedIn = false;

  UserProfile get currentUser => _currentUser;
  UserRole get currentRole => _currentUser.role;
  bool get isLoggedIn => _isLoggedIn;

  bool get isAdmin => _currentUser.role == UserRole.admin;
  bool get isTeacher => _currentUser.role == UserRole.teacher;
  bool get isHeadmaster => _currentUser.role == UserRole.headmaster;
  bool get isOfficer => _currentUser.role == UserRole.officer;

  // 1-Click Demo Profiles for instant review
  static final UserProfile _defaultAdmin = UserProfile(
    id: 'ADM_001',
    name: 'Admin (प्रशासक)',
    email: 'admin@gurusahayak.gov.in',
    phone: '+91 98230 00112',
    role: UserRole.admin,
    schoolName: 'District Education Office, Pune',
    udiseCode: '27250000000',
    clusterName: 'Pune District (12 Schools)',
    blockTaluka: 'Haveli / Pune City',
    district: 'Pune',
    assignedClass: 'Portal Administrator',
  );

  static final UserProfile _defaultTeacher = UserProfile(
    id: 'TCH_101',
    name: 'Suresh Patil (सुरेश पाटील)',
    email: 'teacher@gurusahayak.gov.in',
    phone: '+91 98220 11445',
    role: UserRole.teacher,
    schoolName: 'Z.P. Primary School, Kothrud',
    udiseCode: '27250100101',
    clusterName: 'Kothrud Central',
    blockTaluka: 'Haveli',
    district: 'Pune',
    assignedClass: 'Class 4-A',
  );

  static final UserProfile _defaultHeadmaster = UserProfile(
    id: 'HM_202',
    name: 'Sunita Deshmukh (सुनिता देशमुख)',
    email: 'headmaster@gurusahayak.gov.in',
    phone: '+91 94220 99881',
    role: UserRole.headmaster,
    schoolName: 'Z.P. Primary School, Kothrud',
    udiseCode: '27250100101',
    clusterName: 'Kothrud Central',
    blockTaluka: 'Haveli',
    district: 'Pune',
    assignedClass: 'All Classes (1 to 7)',
  );

  static final UserProfile _defaultOfficer = UserProfile(
    id: 'OFF_303',
    name: 'Dr. Anand Kulkarni (आनंद कुलकर्णी)',
    email: 'officer@gurusahayak.gov.in',
    phone: '+91 99230 44552',
    role: UserRole.officer,
    schoolName: 'BEO Education Office, Haveli Block',
    udiseCode: '27250100000',
    clusterName: 'Haveli Taluka (12 Schools)',
    blockTaluka: 'Haveli',
    district: 'Pune',
    assignedClass: 'Cluster Administrator',
  );

  void switchRole(UserRole role) {
    _isLoggedIn = true;
    switch (role) {
      case UserRole.admin:
        _currentUser = _defaultAdmin;
        break;
      case UserRole.teacher:
        _currentUser = _defaultTeacher;
        break;
      case UserRole.headmaster:
        _currentUser = _defaultHeadmaster;
        break;
      case UserRole.officer:
        _currentUser = _defaultOfficer;
        break;
    }
    notifyListeners();
  }

  void loginWithPhone(String phone, String name, UserRole role) {
    _isLoggedIn = true;
    _currentUser = UserProfile(
      id: 'USR_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: '$phone@gurusahayak.gov.in',
      phone: phone,
      role: role,
      schoolName: 'Z.P. Primary School, Kothrud',
      udiseCode: '27250100101',
      clusterName: 'Kothrud Central',
      blockTaluka: 'Haveli',
      district: 'Pune',
      assignedClass: role == UserRole.teacher ? 'Class 4-A' : 'School Wide',
    );
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
