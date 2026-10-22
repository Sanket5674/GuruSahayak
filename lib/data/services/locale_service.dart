import 'package:flutter/material.dart';

enum AppLanguage {
  english,
  marathi,
}

class LocaleService extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  bool get isMarathi => _language == AppLanguage.marathi;
  bool get isEnglish => _language == AppLanguage.english;

  String get languageCode => _language == AppLanguage.marathi ? 'mr' : 'en';

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _language = _language == AppLanguage.english ? AppLanguage.marathi : AppLanguage.english;
    notifyListeners();
  }

  /// Instant translator helper returning either English or Marathi string based on active locale
  String t(String en, String mr) {
    return _language == AppLanguage.marathi ? mr : en;
  }

  // Common system terms
  String get portalTitle => t('Government School Management Portal', 'शासकीय शाळा व्यवस्थापन पोर्टल');
  String get portalSubtitle => t('Better Education | Brighter Future', 'उत्तम शिक्षण | उज्ज्वल भविष्य');
  String get portalShortName => t('Government School Portal', 'शासकीय शाळा पोर्टल');

  // Navigation Items
  String get navDashboard => t('Dashboard', 'मुख्यपृष्ठ');
  String get navStudents => t('Student Management', 'विद्यार्थी व्यवस्थापन');
  String get navTeachers => t('Teacher Management', 'शिक्षक व्यवस्थापन');
  String get navForms => t('Government Forms', 'शासकीय अर्ज व फॉर्म');
  String get navTasks => t('Tasks & Approvals', 'दैनंदिन कामे व मंजुरी');
  String get navReports => t('Reports & Analytics', 'अहवाल');
  String get navNotices => t('Notices & Circulars', 'सूचना व परिपत्रके');
  String get navSchoolProfile => t('School Profile & Assets', 'शाळा माहिती व साधन');
  String get navSettings => t('Settings & Roles', 'सेटिंग्ज');

  // Actions
  String get addStudent => t('Add Student', 'विद्यार्थी जोडा');
  String get addTeacher => t('Add Teacher', 'शिक्षक जोडा');
  String get submitForm => t('Submit Form', 'फॉर्म सादर करा');
  String get assignTask => t('Assign Task', 'काम वाटप करा');
  String get viewAll => t('View All', 'सर्व पहा');
  String get logout => t('Logout', 'लॉगआउट');
  String get search => t('Search', 'शोधा');
  String get filter => t('Filter', 'फिल्टर');
  String get save => t('Save', 'जतन करा');
  String get cancel => t('Cancel', 'रद्द करा');
  String get approve => t('Approve', 'मंजूर करा');
  String get reject => t('Reject', 'नाकारणे');
  String get requestCorrection => t('Request Correction', 'दुरुस्ती मागवा');

  // Metrics
  String get totalSchools => t('Total Schools', 'एकूण शाळा');
  String get totalStudents => t('Total Students', 'एकूण विद्यार्थी');
  String get totalTeachers => t('Total Teachers', 'एकूण शिक्षक');
  String get pendingForms => t('Pending Forms', 'प्रलंबित फॉर्म');
  String get studentEnrollment => t('Student Enrollment (Last 6 Months)', 'विद्यार्थी प्रवेश (गेल्या ६ महिने)');
  String get recentActivities => t('Recent Activities', 'नुकतीच झालेली कामे');
  String get quickActions => t('Quick Actions', 'त्वरित कृती');
  String get pendingTasks => t('Pending Tasks', 'प्रलंबित कामे');
  String get boys => t('Boys', 'मुलगे');
  String get girls => t('Girls', 'मुली');

  // Statuses
  String get statusActive => t('Active', 'सक्रिय');
  String get statusPending => t('Pending', 'प्रलंबित');
  String get statusSubmitted => t('Submitted', 'सादर केले');
  String get statusApproved => t('Approved', 'मंजूर');
  String get statusRejected => t('Rejected', 'नाकारले');
  String get statusUnderReview => t('Under Review', 'तपासणी अंतर्गत');
  String get statusCorrection => t('Correction Required', 'दुरुस्ती आवश्यक');
  String get statusCompleted => t('Completed', 'पूर्ण');
  String get statusInProgress => t('In Progress', 'प्रगतीपथावर');

  // Roles
  String get roleAdmin => t('Admin', 'प्रशासक');
  String get roleOfficer => t('Officer', 'गटशिक्षणाधिकारी');
  String get roleHeadmaster => t('Headmaster', 'मुख्याध्यापक');
  String get roleTeacher => t('Teacher', 'वर्गशिक्षक');

  // Role-Specific Navigation Titles
  String get navClassroomDashboard => t('Classroom Dashboard', 'माझा वर्ग डॅशबोर्ड');
  String get navDailyAttendance => t('Daily Attendance', '१-टॅप हजेरी');
  String get navMyStudents => t('My Students', 'माझे विद्यार्थी');
  String get navMyTasks => t('My Tasks & Circulars', 'माझी कामे व परिपत्रके');
  String get navClassSurveys => t('Class Surveys', 'सर्वेक्षण अर्ज');

  String get navSchoolDashboard => t('School Dashboard', 'शाळा मुख्यपृष्ठ');
  String get navSchoolStaff => t('School Teachers', 'शाळेतील शिक्षक');
  String get navMdmLedger => t('MDM & Ration', 'माध्यान्ह भोजन व SMS');
  String get navSchoolAssets => t('School Assets', 'शाळा साधन व दुरुस्ती');
  String get navSchoolReports => t('School Reports', 'शाळा अहवाल');

  String get navTalukaDashboard => t('Taluka Dashboard', 'तालुका मुख्यपृष्ठ');
  String get navSchoolOversight => t('School Oversight', 'शाळा तपासणी व स्थिती');
  String get navApprovalsSanctions => t('Approvals & Sanctions', 'अर्ज व मंजुरी');
  String get navTalukaReports => t('Taluka Reports', 'तालुका अहवाल');
  String get navTeacherDirectory => t('Teacher Directory', 'शिक्षक निर्देशिका');

  // Role-Specific Dashboard Metrics & Labels
  String get classStrength => t('Class Strength', 'वर्ग संख्या');
  String get presentToday => t('Present Today', 'आज हजर');
  String get aadhaarMismatches => t('Aadhaar Mismatches', 'आधार तफावत');
  String get assignedDirectives => t('Assigned Directives', 'वाटप केलेली कामे');
  String get staffOnDuty => t('Staff on Duty', 'कामावर शिक्षक');
  String get schoolAttendance => t('School Attendance', 'शाळा उपस्थिती');
  String get mdmStatus => t('PM-POSHAN (MDM)', 'माध्यान्ह भोजन स्थिती');
  String get monitoredSchools => t('Monitored Schools', 'नियंत्रणातील शाळा');
  String get talukaAttendanceRate => t('Taluka Avg Attendance', 'तालुका सरासरी हजेरी');
  String get pendingSanctions => t('Pending Sanctions', 'प्रलंबित मंजुरी');
  String get mdmReportingCompliance => t('MDM Reporting', 'भोजन SMS पूर्तता');
  String get centralCommand => t('Central Command Center', 'मुख्य नियंत्रण कक्ष');
  String get systemSyncStatus => t('System & Sync Health', 'प्रणाली व डेटा स्थिती');

  // Role-Specific Actions
  String get markAttendance => t('Take Roll Call', 'हजेरी नोंदवा');
  String get resolveAadhaar => t('Resolve Aadhaar', 'आधार दुरुस्ती');
  String get dispatchMdmSms => t('Send SMS to 15544', '१५५४४ वर SMS पाठवा');
  String get submitBeoRequisition => t('Submit BEO Requisition', 'BEO मागणी अर्ज');
  String get issueCircularDirective => t('Issue New Directive', 'नवे परिपत्रक जारी करा');
  String get inspectSchoolAction => t('Inspect School', 'शाळा तपासणी');
  String get downloadTalukaCsv => t('Export Taluka CSV', 'तालुका अहवाल डाउनलोड');
  String get markAllPresent => t('Mark All Present', 'सर्व हजर करा');
  String get markAllAbsent => t('Mark All Absent', 'सर्व गैरहजर');
}
