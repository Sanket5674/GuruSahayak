import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gurusahayak/data/models/user_profile.dart';
import 'package:gurusahayak/data/models/student.dart';
import 'package:gurusahayak/data/models/circular_task.dart';
import 'package:gurusahayak/data/models/school_asset.dart';
import 'package:gurusahayak/data/models/dynamic_form.dart';
import 'package:gurusahayak/data/models/school.dart';
import 'package:gurusahayak/data/models/teacher.dart';
import 'package:gurusahayak/data/services/auth_service.dart';
import 'package:gurusahayak/data/services/locale_service.dart';
import 'package:gurusahayak/data/services/local_database_service.dart';
import 'package:gurusahayak/data/services/ocr_parser_service.dart';
import 'package:gurusahayak/data/services/export_service.dart';
import 'package:gurusahayak/ui/core/app_theme.dart';
import 'package:gurusahayak/ui/features/auth/login_screen.dart';
import 'package:gurusahayak/ui/features/dashboard/main_navigation_shell.dart';
import 'package:gurusahayak/ui/features/dashboard/teacher_dashboard_view.dart';
import 'package:gurusahayak/ui/features/dashboard/headmaster_dashboard_view.dart';
import 'package:gurusahayak/ui/features/dashboard/officer_dashboard_view.dart';
import 'package:gurusahayak/ui/features/students/student_vault_view.dart';
import 'package:gurusahayak/ui/features/tasks/circular_tasks_view.dart';
import 'package:gurusahayak/ui/features/assets/asset_manager_view.dart';
import 'package:gurusahayak/ui/features/forms/dynamic_forms_view.dart';
import 'package:gurusahayak/ui/features/portal/portal_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('1. Authentication & Multi-Role Hierarchy Tests', () {
    late AuthService auth;

    setUp(() {
      auth = AuthService();
    });

    test('Default user starts logged out on Login Screen, login switches state', () {
      expect(auth.isLoggedIn, isFalse);
      auth.switchRole(UserRole.teacher);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentRole, equals(UserRole.teacher));
      expect(auth.isTeacher, isTrue);
      expect(auth.isHeadmaster, isFalse);
      expect(auth.isOfficer, isFalse);
      expect(auth.currentUser.name, contains('Suresh Patil'));
      expect(auth.currentUser.assignedClass, equals('Class 4-A'));
      expect(auth.currentUser.schoolName, contains('Kothrud'));
    });

    test('1-Click role switch to Headmaster (मुख्याध्यापक) with Admin privileges', () {
      auth.switchRole(UserRole.headmaster);
      expect(auth.currentRole, equals(UserRole.headmaster));
      expect(auth.isHeadmaster, isTrue);
      expect(auth.currentUser.name, contains('Sunita Deshmukh'));
      expect(auth.currentUser.roleDisplayName, contains('Headmaster'));
      expect(auth.currentUser.assignedClass, contains('All Classes'));
    });

    test('1-Click role switch to System Administrator (Admin) with Multi-School oversight', () {
      auth.switchRole(UserRole.admin);
      expect(auth.currentRole, equals(UserRole.admin));
      expect(auth.isAdmin, isTrue);
      expect(auth.currentUser.name, contains('Admin'));
      expect(auth.currentUser.roleDisplayName, contains('Administrator'));
      expect(auth.currentUser.clusterName, contains('12 Schools'));
      expect(auth.currentUser.schoolOrJurisdiction, contains('District Education Office'));
    });

    test('1-Click role switch to Block Education Officer (SuperAdmin)', () {
      auth.switchRole(UserRole.officer);
      expect(auth.currentRole, equals(UserRole.officer));
      expect(auth.isOfficer, isTrue);
      expect(auth.currentUser.name, contains('Dr. Anand Kulkarni'));
      expect(auth.currentUser.clusterName, contains('12 Schools'));
      expect(auth.currentUser.schoolOrJurisdiction, contains('Haveli'));
    });

    test('Custom phone number login flow', () {
      auth.loginWithPhone('9876543210', 'Ramesh Jadhav', UserRole.teacher);
      expect(auth.currentUser.phone, equals('9876543210'));
      expect(auth.currentUser.name, equals('Ramesh Jadhav'));
      expect(auth.isLoggedIn, isTrue);
    });

    test('Sign out and sign back in', () {
      auth.logout();
      expect(auth.isLoggedIn, isFalse);

      auth.switchRole(UserRole.teacher);
      expect(auth.isLoggedIn, isTrue);
    });
  });

  group('2. Student Master Vault & Aadhaar OCR Verification Tests', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('Seed student roster is populated with realistic ZP school data', () {
      expect(db.students.length, greaterThanOrEqualTo(6));
      expect(db.students.any((s) => s.grNumber == '1452'), isTrue);
    });

    test('Aadhaar discrepancy detection correctly flags name mismatch', () {
      final mismatchedStudent = db.students.firstWhere((s) => s.id == 'STD_103');
      expect(mismatchedStudent.hasMismatch, isTrue);
      expect(mismatchedStudent.isAadhaarVerified, isFalse);

      // Verify OCR discrepancy algorithm
      final scanResult = OcrParserService.parseAadhaarText(
        'Government of India\n${mismatchedStudent.nameInAadhaar}\nDOB: ${mismatchedStudent.dob}\n${mismatchedStudent.aadhaarNo}',
        schoolRegisterName: mismatchedStudent.nameInSchool,
      );
      expect(scanResult.isSuspectedMismatch, isTrue);
      expect(scanResult.mismatchReason, isNotNull);
    });

    test('Resolving Aadhaar mismatch successfully updates student status', () {
      db.resolveMismatch('STD_103', 'Jadhav Rohan Sandeep');
      final updated = db.students.firstWhere((s) => s.id == 'STD_103');
      expect(updated.hasMismatch, isFalse);
      expect(updated.isAadhaarVerified, isTrue);
      expect(updated.nameInAadhaar, equals('Jadhav Rohan Sandeep'));
    });

    test('Adding a new student expands the vault and triggers notification', () {
      final initialCount = db.students.length;
      final newStudent = Student(
        id: 'STD_999',
        grNumber: '1460',
        rollNumber: '09',
        nameInSchool: 'Gawade Tanvi Santosh',
        nameInAadhaar: 'Tanvi S Gawade',
        aadhaarNo: '9988 7766 5544',
        apaarId: 'APAAR98234109',
        penNumber: 'PEN272501009',
        dob: '2016-04-12',
        gender: 'F',
        standard: '4',
        section: 'A',
        parentName: 'Santosh Gawade',
        parentPhone: '9822998877',
        bankAccount: '12345678901',
        ifscCode: 'SBIN0001423',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      );

      db.addStudent(newStudent);
      expect(db.students.length, equals(initialCount + 1));
      expect(db.students.any((s) => s.id == 'STD_999'), isTrue);
    });
  });

  group('3. 1-Tap Attendance & PM-POSHAN (MDM) Ration Math Engine', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('Toggling attendance updates present count and recalculates MDM daily ration', () {
      final student = db.students.first;
      final initialPresent = student.isPresentToday;
      final initialMdmServed = db.todayMdm?.totalStudentsServed ?? 0;

      db.toggleStudentAttendance(student.id);
      expect(student.isPresentToday, equals(!initialPresent));

      // MDM ration dynamically recalculates
      final newMdmServed = db.todayMdm?.totalStudentsServed ?? 0;
      if (!initialPresent) {
        expect(newMdmServed, equals(initialMdmServed + 1));
      } else {
        expect(newMdmServed, equals(initialMdmServed - 1));
      }
    });

    test('Marking all attendance recalculates complete ration and sets SMS message', () {
      db.markAllAttendance(true);
      final total = db.students.length;
      expect(db.todayMdm?.totalStudentsServed, equals(total));
      expect(db.todayMdm?.primaryPresent, equals(total));

      // Primary formula: 100g Rice, 20g Dal, 5g Oil per student
      expect(db.todayMdm?.riceGrams, equals(total * 100.0));
      expect(db.todayMdm?.dalGrams, equals(total * 20.0));
      expect(db.todayMdm?.oilGrams, equals(total * 5.0));

      // SMS format for 15544
      final sms = db.todayMdm?.toSmsMessage('27250100101');
      expect(sms, equals('MDM 27250100101 $total'));
    });
  });

  group('4. Circular Tasks & AI Action Checklist Engine', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('Circular tasks are loaded with priorities, deadlines, and checklists', () {
      expect(db.tasks.isNotEmpty, isTrue);
      final highPriority = db.tasks.where((t) => t.priority == 'high');
      expect(highPriority.isNotEmpty, isTrue);
    });

    test('Toggling task completion updates status and proof remarks', () {
      final task = db.tasks.first;
      final initialStatus = task.isCompleted;

      db.toggleTaskCompletion(task.id, proofRemarks: 'Verified and signed by Headmaster');
      expect(task.isCompleted, equals(!initialStatus));
      expect(task.proofRemarks, equals('Verified and signed by Headmaster'));
    });

    test('AI Circular document parser generates structured task from raw text', () {
      final result = OcrParserService.parseCircular('Government Resolution on ICT lab maintenance');
      expect(result.grNumber, contains('GR-PRE-2026'));
      expect(result.checklist.isNotEmpty, isTrue);
      expect(result.priority, equals('high'));
      expect(result.deadline, isNotEmpty);

      // Add to database
      final newTask = CircularTask(
        id: 'TSK_AI_1',
        grNumber: result.grNumber,
        title: result.title,
        summary: result.summary,
        issuedBy: 'Education Department',
        deadline: result.deadline,
        priority: result.priority,
        checklist: result.checklist,
      );
      db.addCircularTask(newTask);
      expect(db.tasks.any((t) => t.id == 'TSK_AI_1'), isTrue);
    });
  });

  group('5. School Assets & Formal BEO Repair Requisition Tests', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('Assets inventory contains categorized infrastructure records', () {
      expect(db.assets.length, greaterThanOrEqualTo(6));
      expect(db.assets.any((a) => a.category.contains('Electronics')), isTrue);
      expect(db.assets.any((a) => a.condition == AssetCondition.damaged), isTrue);
    });

    test('Updating asset condition records damage remarks', () {
      final asset = db.assets.first;
      db.updateAssetCondition(asset.id, AssetCondition.damaged, 'Broken screen during heavy rains');
      final updated = db.assets.firstWhere((a) => a.id == asset.id);
      expect(updated.condition, equals(AssetCondition.damaged));
      expect(updated.remarks, equals('Broken screen during heavy rains'));
    });

    test('Adding a newly procured school asset', () {
      final initialCount = db.assets.length;
      final newAsset = SchoolAsset(
        id: 'AST_NEW_1',
        name: 'Fire Extinguisher ABC Type (5kg)',
        category: 'Safety & Security',
        quantity: 4,
        condition: AssetCondition.working,
        fundingScheme: 'Disaster Management Grant',
        location: 'All Corridors',
        purchaseYear: '2026',
        remarks: 'Inspected and certified for safety.',
      );

      db.addAsset(newAsset);
      expect(db.assets.length, equals(initialCount + 1));
      expect(db.assets.any((a) => a.id == 'AST_NEW_1'), isTrue);
    });
  });

  group('6. Ad-Hoc Dynamic Survey Forms & Offline Responder Tests', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('Loads pre-configured government surveys', () {
      expect(db.forms.isNotEmpty, isTrue);
      final waterSurvey = db.forms.firstWhere((f) => f.id == 'FRM_101');
      expect(waterSurvey.questions.length, greaterThanOrEqualTo(3));
    });

    test('Submitting survey answers stores offline responses', () {
      final responses = {
        'Q1': 'true',
        'Q2': '12',
        'Q3': 'Borewell with RO Filter',
      };

      db.submitFormResponse('FRM_101', responses);
      final form = db.forms.firstWhere((f) => f.id == 'FRM_101');
      expect(form.isSubmitted, isTrue);
      expect(form.responses['Q1'], equals('true'));
      expect(form.responses['Q2'], equals('12'));
      expect(form.responses['Q3'], equals('Borewell with RO Filter'));
    });

    test('Officer creates a new ad-hoc field survey form', () {
      final initialCount = db.forms.length;
      final newForm = DynamicForm(
        id: 'FRM_NEW_1',
        title: 'Mid-Day Meal Kitchen Hygiene Inspection',
        description: 'Audit of cooking utensils, LPG cylinder safety, and grain storage.',
        createdBy: 'BEO Haveli Block Office',
        deadline: '30 Oct 2026',
        questions: [
          FormQuestion(id: 'HQ1', label: 'LPG connection functional and safe?', type: FormFieldType.boolean),
          FormQuestion(id: 'HQ2', label: 'Grain storage tin containers airtight?', type: FormFieldType.boolean),
          FormQuestion(id: 'HQ3', label: 'Cook-cum-helper medical checkup completed?', type: FormFieldType.boolean),
        ],
      );

      db.addDynamicForm(newForm);
      expect(db.forms.length, equals(initialCount + 1));
      expect(db.forms.any((f) => f.id == 'FRM_NEW_1'), isTrue);
    });
  });

  group('7. Export & Compliance Generators Tests', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('UDISE+ CSV generator outputs correct headers and all student records', () {
      final csv = ExportService.generateUdiseCsv(db.students);
      expect(csv, contains('GR Number,Roll No,Student Name'));
      expect(csv, contains('Patil Aarav Ramesh'));
      expect(csv, contains('APAAR98234101'));
      expect(csv.split('\n').length, greaterThanOrEqualTo(db.students.length + 1));
    });

    test('School Assets CSV generator outputs complete infrastructure ledger', () {
      final csv = ExportService.generateAssetsCsv(db.assets);
      expect(csv, contains('Asset ID,Item Name,Category,Quantity'));
      expect(csv, contains('Smart Classroom'));
      expect(csv, contains('Commercial RO Filter'));
    });

    test('MDM Daily Report text contains official 15544 dispatch format and ration breakdown', () {
      final report = ExportService.generateMdmReportText(
        schoolName: 'Z.P. Primary School, Kothrud',
        udiseCode: '27250100101',
        mdm: db.todayMdm!,
      );

      expect(report, contains('PM POSHAN (MDM)'));
      expect(report, contains('Rice Consumed'));
      expect(report, contains('Pulses / Dal Consumed'));
      expect(report, contains('OFFICIAL SMS DISPATCH (to 15544)'));
      expect(report, contains('MDM 27250100101'));
    });
  });

  group('8. Widget & UI Navigation Integration Tests', () {
    testWidgets('Renders Login Screen with 1-Click Demo Buttons and Form Entry', (WidgetTester tester) async {
      final auth = AuthService();
      auth.logout(); // start on login screen

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: auth),
            ChangeNotifierProvider<LocalDatabaseService>.value(value: LocalDatabaseService()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );

      await tester.pump();

      // Verify branding and 1-Click Demo options
      expect(find.textContaining('GuruSahayak'), findsOneWidget);
      expect(find.textContaining('गुरुसहायक'), findsOneWidget);
      expect(find.textContaining('डेमो प्रवेश'), findsOneWidget);
      expect(find.textContaining('Class Teacher'), findsWidgets);
      expect(find.textContaining('Headmaster'), findsWidgets);
      expect(find.textContaining('BEO / Officer'), findsOneWidget);
    });

    testWidgets('Main Navigation Shell renders 5 tabs and Top Role Switcher', (WidgetTester tester) async {
      final auth = AuthService();
      final db = LocalDatabaseService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: auth),
            ChangeNotifierProvider<LocalDatabaseService>.value(value: db),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MainNavigationShell(),
          ),
        ),
      );

      await tester.pump();

      // Top app bar elements
      expect(find.text('गुरुसहायक'), findsOneWidget);
      expect(find.text('GuruSahayak'), findsOneWidget);
      expect(find.text('Teacher'), findsOneWidget); // role badge

      // 5 Bottom Navigation Destinations
      expect(find.text('डॅशबोर्ड'), findsOneWidget);
      expect(find.text('विद्यार्थी'), findsOneWidget);
      expect(find.text('शासन निर्णय'), findsOneWidget);
      expect(find.text('शाळा साधन'), findsOneWidget);
      expect(find.text('सर्वेक्षणे'), findsOneWidget);

      // Verify Teacher Dashboard is rendered by default
      expect(find.byType(TeacherDashboardView), findsOneWidget);

      // Tap 'विद्यार्थी' tab to switch to Student Vault
      await tester.tap(find.text('विद्यार्थी'));
      await tester.pump();
      expect(find.byType(StudentVaultView), findsOneWidget);

      // Tap 'शासन निर्णय' tab to switch to Circular Tasks
      await tester.tap(find.text('शासन निर्णय'));
      await tester.pump();
      expect(find.byType(CircularTasksView), findsOneWidget);

      // Tap 'शाळा साधन' tab to switch to Assets Manager
      await tester.tap(find.text('शाळा साधन'));
      await tester.pump();
      expect(find.byType(AssetManagerView), findsOneWidget);

      // Tap 'सर्वेक्षणे' tab to switch to Dynamic Forms
      await tester.tap(find.text('सर्वेक्षणे'));
      await tester.pump();
      expect(find.byType(DynamicFormsView), findsOneWidget);
    });

    testWidgets('Switching role dynamically changes Dashboard view', (WidgetTester tester) async {
      final auth = AuthService();
      final db = LocalDatabaseService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: auth),
            ChangeNotifierProvider<LocalDatabaseService>.value(value: db),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const MainNavigationShell(),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(TeacherDashboardView), findsOneWidget);

      // Switch to Headmaster
      auth.switchRole(UserRole.headmaster);
      await tester.pump();
      expect(find.byType(HeadmasterDashboardView), findsOneWidget);
      expect(find.text('Headmaster'), findsOneWidget); // badge updated

      // Switch to Officer
      auth.switchRole(UserRole.officer);
      await tester.pump();
      expect(find.byType(OfficerDashboardView), findsOneWidget);
      expect(find.text('BEO Officer'), findsOneWidget); // badge updated

      // Switch to Admin
      auth.switchRole(UserRole.admin);
      await tester.pump();
      expect(find.byType(OfficerDashboardView), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });
  });

  group('9. Bilingual Engine & LocaleService Tests', () {
    test('Default language starts in English and toggles to Marathi dynamically', () {
      final locale = LocaleService();
      expect(locale.language, equals(AppLanguage.english));
      expect(locale.isEnglish, isTrue);
      expect(locale.isMarathi, isFalse);
      expect(locale.languageCode, equals('en'));

      // Translation helper
      expect(locale.t('Student Management', 'विद्यार्थी व्यवस्थापन'), equals('Student Management'));
      expect(locale.portalTitle, equals('Government School Management Portal'));

      // Toggle to Marathi
      locale.toggleLanguage();
      expect(locale.language, equals(AppLanguage.marathi));
      expect(locale.isMarathi, isTrue);
      expect(locale.isEnglish, isFalse);
      expect(locale.languageCode, equals('mr'));
      expect(locale.t('Student Management', 'विद्यार्थी व्यवस्थापन'), equals('विद्यार्थी व्यवस्थापन'));
      expect(locale.portalTitle, equals('शासकीय शाळा व्यवस्थापन पोर्टल'));

      // Toggle back
      locale.setLanguage(AppLanguage.english);
      expect(locale.isEnglish, isTrue);
    });
  });

  group('10. Multi-School Platform & Teacher Management Tests', () {
    late LocalDatabaseService db;

    setUp(() async {
      db = LocalDatabaseService();
      await db.init();
    });

    test('12 Seed Schools loaded with UDISE codes and composite student/teacher metrics', () {
      expect(db.schools.length, equals(12));
      final School primary = db.schools.first;
      expect(primary.nameEn, contains('ZP'));
      expect(primary.udiseCode, startsWith('2725'));
      expect(primary.district, equals('Pune'));
      expect(primary.totalStudents, isPositive);
      expect(primary.totalTeachers, isPositive);
    });

    test('School filter changes selected school and updates filtered teachers list', () {
      expect(db.selectedSchoolId, equals('ALL'));
      expect(db.filteredTeachers.length, equals(8));

      // Filter by School 1
      db.setSelectedSchool('SCH_01');
      expect(db.selectedSchoolId, equals('SCH_01'));
      expect(db.filteredTeachers.every((t) => t.schoolId == 'SCH_01'), isTrue);

      // Reset to ALL
      db.setSelectedSchool('ALL');
      expect(db.filteredTeachers.length, equals(8));
    });

    test('Teacher CRUD operations (Add, Update, Delete) are persistent in state', () {
      final initialCount = db.teachers.length;
      const newTeacher = Teacher(
        id: 'TCH_NEW_99',
        employeeId: 'MH2024999',
        name: 'M. Shinde',
        subject: 'Mathematics',
        gradesAssigned: '8-10',
        phone: '9890123456',
        email: 'mshinde@gurusahayak.gov.in',
        schoolId: 'SCH_01',
        status: 'Active',
        designation: 'Math Specialist',
      );

      db.addTeacher(newTeacher);
      expect(db.teachers.length, equals(initialCount + 1));
      expect(db.teachers.any((t) => t.id == 'TCH_NEW_99'), isTrue);

      // Update teacher status
      final updated = newTeacher.copyWith(status: 'On Leave');
      db.updateTeacher(updated);
      expect(db.teachers.firstWhere((t) => t.id == 'TCH_NEW_99').status, equals('On Leave'));

      // Delete teacher
      db.deleteTeacher('TCH_NEW_99');
      expect(db.teachers.length, equals(initialCount));
      expect(db.teachers.any((t) => t.id == 'TCH_NEW_99'), isFalse);
    });

    test('Dynamic Government Form status approval lifecycle', () {
      expect(db.forms.isNotEmpty, isTrue);
      final form = db.forms.first;

      db.updateFormStatus(form.id, 'Approved');
      expect(db.forms.firstWhere((f) => f.id == form.id).status, equals('Approved'));
      expect(db.forms.firstWhere((f) => f.id == form.id).isSubmitted, isTrue);

      db.updateFormStatus(form.id, 'Rejected');
      expect(db.forms.firstWhere((f) => f.id == form.id).status, equals('Rejected'));
    });
  });

  group('11. Government School Management Portal UI (PortalShell) Integration Tests', () {
    testWidgets('PortalShell renders dynamic Role-Specific Dashboards & Navigation for all 4 profiles', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final auth = AuthService();
      final db = LocalDatabaseService();
      final locale = LocaleService();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: auth),
            ChangeNotifierProvider<LocalDatabaseService>.value(value: db),
            ChangeNotifierProvider<LocaleService>.value(value: locale),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const PortalShell(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Top Header elements
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('मराठी'), findsOneWidget);

      // --- 1. Class Teacher Profile Verification ---
      // Teacher sidebar items
      expect(find.text('Classroom Dashboard'), findsWidgets);
      expect(find.text('Daily Attendance'), findsWidgets);
      expect(find.text('My Students'), findsWidgets);
      expect(find.text('My Tasks & Circulars'), findsWidgets);
      expect(find.text('Class Surveys'), findsWidgets);
      // Teacher should NOT see Admin or Officer items
      expect(find.text('Central Command'), findsNothing);
      expect(find.text('School Oversight'), findsNothing);
      expect(find.text('Teacher Management'), findsNothing);

      // Teacher dashboard metrics
      expect(find.text('Class Strength'), findsOneWidget);
      expect(find.text('Present Today'), findsOneWidget);

      // Toggle to Marathi live for Teacher
      locale.toggleLanguage();
      await tester.pumpAndSettle();
      expect(find.text('माझा वर्ग डॅशबोर्ड'), findsWidgets);
      expect(find.text('वर्ग संख्या'), findsOneWidget);
      locale.toggleLanguage(); // Switch back to EN
      await tester.pumpAndSettle();

      // --- 2. Headmaster Profile Verification ---
      auth.switchRole(UserRole.headmaster);
      await tester.pumpAndSettle();

      expect(find.text('School Dashboard'), findsWidgets);
      expect(find.text('School Teachers'), findsWidgets);
      expect(find.text('MDM & Ration'), findsWidgets);
      expect(find.text('Staff on Duty'), findsOneWidget);
      expect(find.text('PM-POSHAN (MDM)'), findsOneWidget);

      // --- 3. Education Officer Profile Verification ---
      auth.switchRole(UserRole.officer);
      await tester.pumpAndSettle();

      expect(find.text('School Oversight'), findsWidgets);
      expect(find.text('Teacher Directory'), findsWidgets);
      expect(find.text('Approvals & Sanctions'), findsWidgets);
      expect(find.text('Monitored Schools'), findsOneWidget);
      expect(find.text('Pending Sanctions'), findsOneWidget);

      // --- 4. Administrator Profile Verification ---
      auth.switchRole(UserRole.admin);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsWidgets);
      expect(find.text('Teacher Management'), findsWidgets);
      expect(find.text('Total Schools'), findsOneWidget);
      expect(find.text('Total Students'), findsOneWidget);
    });
  });
}
