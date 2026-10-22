import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';
import '../models/circular_task.dart';
import '../models/school_asset.dart';
import '../models/dynamic_form.dart';
import '../models/mdm_record.dart';
import '../models/school.dart';
import '../models/teacher.dart';

class LocalDatabaseService extends ChangeNotifier {
  Database? _db;

  List<School> _schools = [];
  List<Teacher> _teachers = [];
  List<Student> _students = [];
  List<CircularTask> _tasks = [];
  List<SchoolAsset> _assets = [];
  List<DynamicForm> _forms = [];
  MdmRecord? _todayMdm;
  String _selectedSchoolId = 'ALL';

  List<School> get schools => _schools;
  List<Teacher> get teachers => _teachers;
  List<Student> get students => _students;
  List<CircularTask> get tasks => _tasks;
  List<SchoolAsset> get assets => _assets;
  List<DynamicForm> get forms => _forms;
  MdmRecord? get todayMdm => _todayMdm;
  String get selectedSchoolId => _selectedSchoolId;

  School? get selectedSchool => _schools.firstWhere(
    (s) => s.id == _selectedSchoolId,
    orElse: () => _schools.isNotEmpty
        ? _schools.first
        : const School(
            id: 'ALL',
            udiseCode: '27250000000',
            nameEn: 'All Schools',
            nameMr: 'सर्व शाळा',
            district: 'Pune',
            blockTaluka: 'Haveli',
            cluster: 'Haveli Cluster',
            type: 'Composite',
            totalStudents: 4892,
            totalTeachers: 312,
            headmasterName: 'District Administration',
          ),
  );

  void setSelectedSchool(String id) {
    _selectedSchoolId = id;
    notifyListeners();
  }

  int get totalSchoolsCount => _schools.isNotEmpty ? _schools.length : 12;
  int get totalStudentsOverall => 4892;
  int get totalTeachersOverall => 312;
  int get pendingFormsCount => _forms.where((f) => f.status == 'Pending').length + 14;

  int get totalStudentsCount => _students.length;
  int get presentStudentsCount => _students.where((s) => s.isPresentToday).length;
  int get absentStudentsCount => _students.where((s) => !s.isPresentToday).length;
  int get aadhaarMismatchesCount => _students.where((s) => s.hasMismatch).length;
  int get pendingTasksCount => _tasks.where((t) => !t.isCompleted).length;

  Future<void> init() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docDir.path, 'gurusahayak_v1.db');

      _db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE students (
              id TEXT PRIMARY KEY,
              grNumber TEXT,
              rollNumber TEXT,
              nameInSchool TEXT,
              nameInAadhaar TEXT,
              aadhaarNo TEXT,
              apaarId TEXT,
              penNumber TEXT,
              dob TEXT,
              gender TEXT,
              standard TEXT,
              section TEXT,
              parentName TEXT,
              parentPhone TEXT,
              bankAccount TEXT,
              ifscCode TEXT,
              isAadhaarVerified INTEGER,
              hasMismatch INTEGER,
              apaarConsentSigned INTEGER,
              isPresentToday INTEGER
            )
          ''');

          await db.execute('''
            CREATE TABLE circular_tasks (
              id TEXT PRIMARY KEY,
              grNumber TEXT,
              title TEXT,
              summary TEXT,
              issuedBy TEXT,
              deadline TEXT,
              priority TEXT,
              checklist TEXT,
              isCompleted INTEGER,
              proofRemarks TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE school_assets (
              id TEXT PRIMARY KEY,
              name TEXT,
              category TEXT,
              quantity INTEGER,
              condition TEXT,
              fundingScheme TEXT,
              location TEXT,
              purchaseYear TEXT,
              remarks TEXT
            )
          ''');
        },
      );

      await _loadFromDbOrSeed();
    } catch (e) {
      // Fallback in-memory seed if platform sqlite is unavailable
      _seedDefaultData();
    }
  }

  Future<void> _loadFromDbOrSeed() async {
    if (_db == null) {
      _seedDefaultData();
      return;
    }

    final studentRows = await _db!.query('students');
    if (studentRows.isEmpty) {
      _seedDefaultData();
      await _persistAllSeedData();
    } else {
      _students = studentRows.map((r) => Student.fromMap(r)).toList();
      final taskRows = await _db!.query('circular_tasks');
      _tasks = taskRows.map((r) => CircularTask.fromMap(r)).toList();
      final assetRows = await _db!.query('school_assets');
      _assets = assetRows.map((r) => SchoolAsset.fromMap(r)).toList();
      _seedFormsAndMdm();
    }
    notifyListeners();
  }

  Future<void> _persistAllSeedData() async {
    if (_db == null) return;
    for (final s in _students) {
      await _db!.insert('students', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final t in _tasks) {
      await _db!.insert('circular_tasks', t.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    for (final a in _assets) {
      await _db!.insert('school_assets', a.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  void _seedDefaultData() {
    _schools = [
      const School(
        id: 'SCH_01',
        udiseCode: '27250100101',
        nameEn: 'ZP High School, Pune',
        nameMr: 'जि. प. हायस्कूल, पुणे',
        district: 'Pune',
        blockTaluka: 'Pune City',
        cluster: 'Central Pune',
        type: 'Secondary',
        totalStudents: 620,
        totalTeachers: 32,
        headmasterName: 'Sunita Deshmukh',
      ),
      const School(
        id: 'SCH_02',
        udiseCode: '27250100102',
        nameEn: 'ZP Primary School, Kothrud',
        nameMr: 'जि. प. प्राथमिक शाळा, कोथरूड',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Kothrud Central',
        type: 'Primary',
        totalStudents: 410,
        totalTeachers: 24,
        headmasterName: 'R. K. Kulkarni',
      ),
      const School(
        id: 'SCH_03',
        udiseCode: '27250100103',
        nameEn: 'ZP Upper Primary School, Haveli',
        nameMr: 'जि. प. उच्च प्राथमिक शाळा, हवेली',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Haveli Rural',
        type: 'Upper Primary',
        totalStudents: 480,
        totalTeachers: 28,
        headmasterName: 'M. S. Patil',
      ),
      const School(
        id: 'SCH_04',
        udiseCode: '27250100104',
        nameEn: 'ZP Model School, Hadapsar',
        nameMr: 'जि. प. आदर्श शाळा, हडपसर',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Hadapsar East',
        type: 'Higher Secondary',
        totalStudents: 530,
        totalTeachers: 30,
        headmasterName: 'P. N. Joshi',
      ),
      const School(
        id: 'SCH_05',
        udiseCode: '27250100105',
        nameEn: 'ZP High School, Shivajinagar',
        nameMr: 'जि. प. हायस्कूल, शिवाजीनगर',
        district: 'Pune',
        blockTaluka: 'Pune City',
        cluster: 'Shivajinagar North',
        type: 'Secondary',
        totalStudents: 450,
        totalTeachers: 26,
        headmasterName: 'A. B. Shinde',
      ),
      const School(
        id: 'SCH_06',
        udiseCode: '27250100106',
        nameEn: 'ZP Primary School, Baner',
        nameMr: 'जि. प. प्राथमिक शाळा, बाणेर',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Baner West',
        type: 'Primary',
        totalStudents: 380,
        totalTeachers: 22,
        headmasterName: 'V. R. Pawar',
      ),
      const School(
        id: 'SCH_07',
        udiseCode: '27250100107',
        nameEn: 'ZP School, Aundh Central',
        nameMr: 'जि. प. शाळा, औंध मध्यवर्ती',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Aundh',
        type: 'Primary',
        totalStudents: 340,
        totalTeachers: 20,
        headmasterName: 'G. D. More',
      ),
      const School(
        id: 'SCH_08',
        udiseCode: '27250100108',
        nameEn: 'ZP Primary School, Warje',
        nameMr: 'जि. प. प्राथमिक शाळा, वारजे',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Warje Malwadi',
        type: 'Primary',
        totalStudents: 420,
        totalTeachers: 25,
        headmasterName: 'S. K. Kale',
      ),
      const School(
        id: 'SCH_09',
        udiseCode: '27250100109',
        nameEn: 'ZP Secondary School, Sinhagad',
        nameMr: 'जि. प. माध्यमिक शाळा, सिंहगड',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Sinhagad Ghat',
        type: 'Secondary',
        totalStudents: 390,
        totalTeachers: 24,
        headmasterName: 'N. T. Jadhav',
      ),
      const School(
        id: 'SCH_10',
        udiseCode: '27250100110',
        nameEn: 'ZP Primary School, Dhayari',
        nameMr: 'जि. प. प्राथमिक शाळा, धायरी',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Dhayari',
        type: 'Primary',
        totalStudents: 290,
        totalTeachers: 18,
        headmasterName: 'T. M. Gaikwad',
      ),
      const School(
        id: 'SCH_11',
        udiseCode: '27250100111',
        nameEn: 'ZP School, Katraj',
        nameMr: 'जि. प. शाळा, कात्रज',
        district: 'Pune',
        blockTaluka: 'Haveli',
        cluster: 'Katraj South',
        type: 'Primary',
        totalStudents: 310,
        totalTeachers: 21,
        headmasterName: 'H. V. Kadam',
      ),
      const School(
        id: 'SCH_12',
        udiseCode: '27250100112',
        nameEn: 'ZP Girls High School, Pune',
        nameMr: 'जि. प. कन्या हायस्कूल, पुणे',
        district: 'Pune',
        blockTaluka: 'Pune City',
        cluster: 'Central Pune',
        type: 'Secondary',
        totalStudents: 272,
        totalTeachers: 22,
        headmasterName: 'K. S. Deshmukh',
      ),
    ];

    _teachers = [
      const Teacher(
        id: 'TCH_01',
        employeeId: 'MH2018091',
        name: 'S. Patil',
        subject: 'Marathi',
        gradesAssigned: '5-10',
        phone: '9876543210',
        email: 'spatil@gurusahayak.gov.in',
        schoolId: 'SCH_01',
        status: 'Active',
        designation: 'Senior Teacher',
      ),
      const Teacher(
        id: 'TCH_02',
        employeeId: 'MH2019042',
        name: 'R. Kulkarni',
        subject: 'English',
        gradesAssigned: '5-10',
        phone: '9823456789',
        email: 'rkulkarni@gurusahayak.gov.in',
        schoolId: 'SCH_01',
        status: 'Active',
        designation: 'Assistant Teacher',
      ),
      const Teacher(
        id: 'TCH_03',
        employeeId: 'MH2020113',
        name: 'V. Deshmukh',
        subject: 'Science',
        gradesAssigned: '6-10',
        phone: '9765432109',
        email: 'vdeshmukh@gurusahayak.gov.in',
        schoolId: 'SCH_01',
        status: 'Active',
        designation: 'Science Specialist',
      ),
      const Teacher(
        id: 'TCH_04',
        employeeId: 'MH2017084',
        name: 'P. More',
        subject: 'Mathematics',
        gradesAssigned: '8-10',
        phone: '9878904321',
        email: 'pmore@gurusahayak.gov.in',
        schoolId: 'SCH_01',
        status: 'Active',
        designation: 'TGT Math',
      ),
      const Teacher(
        id: 'TCH_05',
        employeeId: 'MH2021055',
        name: 'A. Gaikwad',
        subject: 'Social Science',
        gradesAssigned: '6-10',
        phone: '9854321098',
        email: 'agaikwad@gurusahayak.gov.in',
        schoolId: 'SCH_01',
        status: 'Active',
        designation: 'Assistant Teacher',
      ),
      const Teacher(
        id: 'TCH_06',
        employeeId: 'MH2022036',
        name: 'S. Kale',
        subject: 'Hindi',
        gradesAssigned: '6-8',
        phone: '9876523479',
        email: 'skale@gurusahayak.gov.in',
        schoolId: 'SCH_02',
        status: 'Active',
        designation: 'Language Teacher',
      ),
      const Teacher(
        id: 'TCH_07',
        employeeId: 'MH2023017',
        name: 'N. Joshi',
        subject: 'Computer',
        gradesAssigned: '5-10',
        phone: '9764321098',
        email: 'njoshi@gurusahayak.gov.in',
        schoolId: 'SCH_02',
        status: 'Active',
        designation: 'ICT Instructor',
      ),
      const Teacher(
        id: 'TCH_08',
        employeeId: 'MH2019088',
        name: 'D. Pawar',
        subject: 'Physical Edu.',
        gradesAssigned: '5-10',
        phone: '9823985467',
        email: 'dpawar@gurusahayak.gov.in',
        schoolId: 'SCH_03',
        status: 'Active',
        designation: 'Sports Instructor',
      ),
    ];

    _students = [
      Student(
        id: 'STD_101',
        grNumber: '1452',
        rollNumber: '01',
        nameInSchool: 'Patil Aarav Ramesh',
        nameInAadhaar: 'Aarav R Patil',
        aadhaarNo: '7845 1209 3321',
        apaarId: 'APAAR98234101',
        penNumber: 'PEN272501001',
        dob: '2016-05-14',
        gender: 'M',
        standard: '4',
        section: 'A',
        parentName: 'Ramesh Patil',
        parentPhone: '9822334455',
        bankAccount: '30458891230',
        ifscCode: 'SBIN0001423',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_102',
        grNumber: '1453',
        rollNumber: '02',
        nameInSchool: 'Deshmukh Ananya Suresh',
        nameInAadhaar: 'Ananya S Deshmukh',
        aadhaarNo: '6541 9908 1234',
        apaarId: 'APAAR98234102',
        penNumber: 'PEN272501002',
        dob: '2016-08-21',
        gender: 'F',
        standard: '4',
        section: 'A',
        parentName: 'Suresh Deshmukh',
        parentPhone: '9422118877',
        bankAccount: '44019283741',
        ifscCode: 'MAHB0000412',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_103',
        grNumber: '1454',
        rollNumber: '03',
        nameInSchool: 'Jadhav Rohan Sandeep',
        nameInAadhaar: 'Rohan S Jadav', // Intentional spelling mismatch to demonstrate alert
        aadhaarNo: '8876 2341 5567',
        apaarId: 'Pending',
        penNumber: 'PEN272501003',
        dob: '2016-02-11',
        gender: 'M',
        standard: '4',
        section: 'A',
        parentName: 'Sandeep Jadhav',
        parentPhone: '9923887766',
        bankAccount: '20394817263',
        ifscCode: 'BARB0KOTHRU',
        isAadhaarVerified: false,
        hasMismatch: true, // Triggers discrepancy badge
        apaarConsentSigned: false,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_104',
        grNumber: '1455',
        rollNumber: '04',
        nameInSchool: 'Kadam Priya Nitin',
        nameInAadhaar: 'Priya N Kadam',
        aadhaarNo: '9921 4455 6677',
        apaarId: 'APAAR98234104',
        penNumber: 'PEN272501004',
        dob: '2016-11-03',
        gender: 'F',
        standard: '4',
        section: 'A',
        parentName: 'Nitin Kadam',
        parentPhone: '9890112233',
        bankAccount: '55610293847',
        ifscCode: 'SBIN0001423',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: false,
      ),
      Student(
        id: 'STD_105',
        grNumber: '1456',
        rollNumber: '05',
        nameInSchool: 'Shinde Omkar Vilas',
        nameInAadhaar: 'Omkar V Shinde',
        aadhaarNo: '3344 7788 1122',
        apaarId: 'APAAR98234105',
        penNumber: 'PEN272501005',
        dob: '2016-07-19',
        gender: 'M',
        standard: '4',
        section: 'A',
        parentName: 'Vilas Shinde',
        parentPhone: '9423556677',
        bankAccount: '11029384756',
        ifscCode: 'PUNB0123400',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_106',
        grNumber: '1457',
        rollNumber: '06',
        nameInSchool: 'Chavan Tanvi Ganesh',
        nameInAadhaar: 'Tanvi G Chavan',
        aadhaarNo: '4455 8899 0011',
        apaarId: 'APAAR98234106',
        penNumber: 'PEN272501006',
        dob: '2016-09-30',
        gender: 'F',
        standard: '4',
        section: 'A',
        parentName: 'Ganesh Chavan',
        parentPhone: '9860223344',
        bankAccount: '99887766554',
        ifscCode: 'MAHB0000412',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_201',
        grNumber: '1458',
        rollNumber: '101',
        nameInSchool: 'Aditi Sharma',
        nameInAadhaar: 'Aditi Sharma',
        aadhaarNo: '9845 2210 1122',
        apaarId: 'APAAR98234201',
        penNumber: 'PEN272501201',
        dob: '2010-04-10',
        gender: 'F',
        standard: '10',
        section: 'A',
        parentName: 'Ramesh Sharma',
        parentPhone: '9822110011',
        bankAccount: '10293847561',
        ifscCode: 'SBIN0001423',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_202',
        grNumber: '1459',
        rollNumber: '102',
        nameInSchool: 'Rohit Kumar',
        nameInAadhaar: 'Rohit Kumar',
        aadhaarNo: '7766 5544 3322',
        apaarId: 'APAAR98234202',
        penNumber: 'PEN272501202',
        dob: '2010-06-15',
        gender: 'M',
        standard: '10',
        section: 'A',
        parentName: 'Sunil Kumar',
        parentPhone: '9822334411',
        bankAccount: '29384756102',
        ifscCode: 'SBIN0001423',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_203',
        grNumber: '1460',
        rollNumber: '103',
        nameInSchool: 'Sneha Patil',
        nameInAadhaar: 'Sneha Patil',
        aadhaarNo: '8877 6655 4433',
        apaarId: 'APAAR98234203',
        penNumber: 'PEN272501203',
        dob: '2010-09-20',
        gender: 'F',
        standard: '10',
        section: 'B',
        parentName: 'Sanjay Patil',
        parentPhone: '9822445522',
        bankAccount: '38475610293',
        ifscCode: 'MAHB0000412',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_204',
        grNumber: '1461',
        rollNumber: '104',
        nameInSchool: 'Sagar More',
        nameInAadhaar: 'Sagar More',
        aadhaarNo: '5544 3322 1100',
        apaarId: 'APAAR98234204',
        penNumber: 'PEN272501204',
        dob: '2011-03-12',
        gender: 'M',
        standard: '9',
        section: 'A',
        parentName: 'Prakash More',
        parentPhone: '9822556633',
        bankAccount: '47561029384',
        ifscCode: 'MAHB0000412',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_205',
        grNumber: '1462',
        rollNumber: '105',
        nameInSchool: 'Pooja Desai',
        nameInAadhaar: 'Pooja Desai',
        aadhaarNo: '4433 2211 0099',
        apaarId: 'APAAR98234205',
        penNumber: 'PEN272501205',
        dob: '2011-08-08',
        gender: 'F',
        standard: '9',
        section: 'B',
        parentName: 'Vijay Desai',
        parentPhone: '9822667744',
        bankAccount: '56102938475',
        ifscCode: 'BARB0KOTHRU',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_206',
        grNumber: '1463',
        rollNumber: '106',
        nameInSchool: 'Akash Jadhav',
        nameInAadhaar: 'Akash Jadhav',
        aadhaarNo: '3322 1100 9988',
        apaarId: 'APAAR98234206',
        penNumber: 'PEN272501206',
        dob: '2012-01-25',
        gender: 'M',
        standard: '8',
        section: 'A',
        parentName: 'Dilip Jadhav',
        parentPhone: '9822778855',
        bankAccount: '61029384756',
        ifscCode: 'BARB0KOTHRU',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_207',
        grNumber: '1464',
        rollNumber: '107',
        nameInSchool: 'Neha Wagh',
        nameInAadhaar: 'Neha Wagh',
        aadhaarNo: '2211 0099 8877',
        apaarId: 'APAAR98234207',
        penNumber: 'PEN272501207',
        dob: '2012-05-30',
        gender: 'F',
        standard: '8',
        section: 'A',
        parentName: 'Ashok Wagh',
        parentPhone: '9822889966',
        bankAccount: '71029384756',
        ifscCode: 'PUNB0123400',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
      Student(
        id: 'STD_208',
        grNumber: '1465',
        rollNumber: '108',
        nameInSchool: 'Omkar Shinde',
        nameInAadhaar: 'Omkar Shinde',
        aadhaarNo: '1100 9988 7766',
        apaarId: 'APAAR98234208',
        penNumber: 'PEN272501208',
        dob: '2012-11-14',
        gender: 'M',
        standard: '8',
        section: 'B',
        parentName: 'Kailash Shinde',
        parentPhone: '9822990077',
        bankAccount: '81029384756',
        ifscCode: 'PUNB0123400',
        isAadhaarVerified: true,
        hasMismatch: false,
        apaarConsentSigned: true,
        isPresentToday: true,
      ),
    ];

    _tasks = [
      CircularTask(
        id: 'TSK_M1',
        grNumber: 'TASK-2025-01',
        title: 'Mid Term Report',
        summary: 'Compile and verify mid-term examination performance reports for grades 5-10.',
        issuedBy: 'BEO Haveli Block Office',
        deadline: '15-04-2025',
        priority: 'high',
        assignedTo: 'R. Kulkarni',
        status: 'Pending',
        isCompleted: false,
        checklist: ['Compile score cards', 'Cross check with register', 'Get HM approval'],
      ),
      CircularTask(
        id: 'TSK_M2',
        grNumber: 'TASK-2025-02',
        title: 'Scholarship Form',
        summary: 'Verify minority and merit scholarship applications for eligible students.',
        issuedBy: 'District Education Office',
        deadline: '12-04-2025',
        priority: 'medium',
        assignedTo: 'S. Patil',
        status: 'In Progress',
        isCompleted: false,
        checklist: ['Check Aadhaar seeding', 'Collect parent income proof'],
      ),
      CircularTask(
        id: 'TSK_M3',
        grNumber: 'TASK-2025-03',
        title: 'Attendance Report',
        summary: 'Submit monthly consolidated student & staff attendance sheet.',
        issuedBy: 'Headmaster',
        deadline: '10-04-2025',
        priority: 'normal',
        assignedTo: 'V. Deshmukh',
        status: 'Completed',
        isCompleted: true,
        checklist: ['Audit biometric entries', 'Mark long absent students'],
      ),
      CircularTask(
        id: 'TSK_M4',
        grNumber: 'TASK-2025-04',
        title: 'Result Entry',
        summary: 'Digital record entry of terminal assessment on SARAL portal.',
        issuedBy: 'State Assessment Cell',
        deadline: '20-04-2025',
        priority: 'medium',
        assignedTo: 'P. More',
        status: 'Pending',
        isCompleted: false,
        checklist: ['Enter subject marks', 'Verify grade boundaries'],
      ),
      CircularTask(
        id: 'TSK_M5',
        grNumber: 'TASK-2025-05',
        title: 'School Inspection',
        summary: 'Annual infrastructure and learning outcome verification visit.',
        issuedBy: 'District Education Office',
        deadline: '25-04-2025',
        priority: 'high',
        assignedTo: 'A. Gaikwad',
        status: 'Pending',
        isCompleted: false,
        checklist: ['Safety audit', 'Classroom cleanliness', 'Register verification'],
      ),
      CircularTask(
        id: 'TSK_1',
        grNumber: 'GR-PRE-2026/CR-45',
        title: 'APAAR One Nation Student ID Consent Drive',
        summary: 'Collect signed parental consent slips for all Class 1-4 students and complete Aadhaar seeding before district audit.',
        issuedBy: 'Director of Primary Education, Maharashtra',
        deadline: '15 Oct 2026',
        priority: 'urgent',
        checklist: [
          'Distribute vernacular Marathi consent slips to parents',
          'Collect signed slip and verify Aadhaar spelling',
          'Resolve Aadhaar vs GR name mismatches',
          'Mark consent verified in GuruSahayak Vault',
        ],
        isCompleted: false,
      ),
      CircularTask(
        id: 'TSK_2',
        grNumber: 'MDM-CIRCULAR-2026/89',
        title: 'PM-POSHAN Quarterly Nutrition & Stock Audit',
        summary: 'Submit verified physical balance of rice, pulses, and oil stock in store. Ensure eggs/banana served twice weekly.',
        issuedBy: 'BEO Haveli Block Office',
        deadline: '10 Oct 2026',
        priority: 'high',
        checklist: [
          'Audit physical rice bag weight against balance register',
          'Inspect expiry date of fortified cooking oil',
          'Log weekly egg distribution headcount',
        ],
        isCompleted: true,
        proofRemarks: 'Physical weighment completed. 120kg Rice and 45kg Dal verified.',
      ),
      CircularTask(
        id: 'TSK_3',
        grNumber: 'NIPUN-FLN-TEST-03',
        title: 'NIPUN Bharat Baseline Literacy & Numeracy Entry',
        summary: 'Conduct oral reading fluency (ORF) and 2-digit addition tests for Grade 3 & 4. Record scores on portal.',
        issuedBy: 'Kendra Pramukh Kothrud',
        deadline: '20 Oct 2026',
        priority: 'normal',
        checklist: [
          'Conduct 1-on-1 reading assessment (30 words/min benchmark)',
          'Assess 2-digit subtraction with borrowing',
          'Submit score roster to Kendra Pramukh',
        ],
        isCompleted: false,
      ),
      CircularTask(
        id: 'TSK_4',
        grNumber: 'DBT-UNIFORM-2026',
        title: 'DBT Bank Account Verification for Free Uniforms',
        summary: 'Verify bank account numbers and active Aadhaar seeding of all SC/ST/BPL girl students for ₹600 allowance.',
        issuedBy: 'Social Welfare Department',
        deadline: '25 Oct 2026',
        priority: 'high',
        checklist: [
          'Verify bank passbook IFSC codes for merged bank branches',
          'Ensure account is in student or joint mother-student name',
        ],
        isCompleted: false,
      ),
    ];

    _assets = [
      SchoolAsset(
        id: 'AST_1',
        name: 'Smart Classroom 55" 4K Interactive TV',
        category: 'Electronics',
        quantity: 2,
        condition: AssetCondition.working,
        fundingScheme: 'CSR Grant (Tech Mahindra)',
        location: 'Class 4-A & Science Room',
        purchaseYear: '2024',
        remarks: 'HDMI cables and Android TV functional.',
      ),
      SchoolAsset(
        id: 'AST_2',
        name: 'Drinking Water Commercial RO Filter (50 LPH)',
        category: 'Sanitation / Water',
        quantity: 1,
        condition: AssetCondition.minorIssue,
        fundingScheme: 'Zilla Parishad District Fund',
        location: 'Main Corridor',
        purchaseYear: '2023',
        remarks: 'Sediment candle filter needs periodic replacement. Water flowing normally.',
      ),
      SchoolAsset(
        id: 'AST_3',
        name: 'Dual Wooden Student Desks & Benches',
        category: 'Furniture',
        quantity: 40,
        condition: AssetCondition.working,
        fundingScheme: 'Samagra Shiksha Abhiyan',
        location: 'Classrooms 1, 2, 3, 4',
        purchaseYear: '2023',
        remarks: '36 in perfect condition, 4 need bolt tightening.',
      ),
      SchoolAsset(
        id: 'AST_4',
        name: 'Rooftop 3kW Solar Power Inverter Unit',
        category: 'Electronics',
        quantity: 1,
        condition: AssetCondition.damaged,
        fundingScheme: 'State Green Energy Mission',
        location: 'School Terrace',
        purchaseYear: '2022',
        remarks: 'Inverter battery bank exhausted; needs battery replacement request to BEO.',
      ),
      SchoolAsset(
        id: 'AST_5',
        name: 'Primary Sports & Physical Education Kit',
        category: 'Sports & Lab',
        quantity: 1,
        condition: AssetCondition.working,
        fundingScheme: 'Samagra Shiksha Grant',
        location: 'Headmaster Room',
        purchaseYear: '2025',
        remarks: 'Carrom board, football, volleyball, skipping ropes.',
      ),
      SchoolAsset(
        id: 'AST_6',
        name: 'Girls Sanitation Block Water Pump (1 HP)',
        category: 'Sanitation / Water',
        quantity: 1,
        condition: AssetCondition.working,
        fundingScheme: 'Swachh Bharat Swachh Vidyalaya',
        location: 'Overhead Tank',
        purchaseYear: '2023',
        remarks: 'Functional with automated float switch.',
      ),
    ];

    _seedFormsAndMdm();
  }

  void _seedFormsAndMdm() {
    _forms = [
      DynamicForm(
        id: 'FRM_M1',
        title: 'Scholarship Form 2025-26',
        description: 'Student scholarship application & verification for state pre-matric grant.',
        createdBy: 'Social Welfare Department',
        deadline: '15-04-2025',
        status: 'Pending',
        isSubmitted: false,
        questions: [
          FormQuestion(id: 'Q1', label: 'Student Bank Account Aadhaar seeded?', type: FormFieldType.boolean),
          FormQuestion(id: 'Q2', label: 'Annual parental income certificate attached?', type: FormFieldType.boolean),
        ],
      ),
      DynamicForm(
        id: 'FRM_M2',
        title: 'Teacher Data Form',
        description: 'Teacher information and qualification update for state teacher database.',
        createdBy: 'State Education Board',
        deadline: '20-04-2025',
        status: 'Submitted',
        isSubmitted: true,
        questions: [
          FormQuestion(id: 'Q1', label: 'TET/CTET qualification completed?', type: FormFieldType.boolean),
          FormQuestion(id: 'Q2', label: 'Years of service in ZP school', type: FormFieldType.number),
        ],
      ),
      DynamicForm(
        id: 'FRM_M3',
        title: 'School Infrastructure',
        description: 'Building details, playground area, and smart classroom readiness.',
        createdBy: 'Samagra Shiksha Abhiyan',
        deadline: '25-04-2025',
        status: 'Approved',
        isSubmitted: true,
        questions: [
          FormQuestion(id: 'Q1', label: 'Pucca building certified by PWD?', type: FormFieldType.boolean),
          FormQuestion(id: 'Q2', label: 'Separate functional girls toilet available?', type: FormFieldType.boolean),
        ],
      ),
      DynamicForm(
        id: 'FRM_M4',
        title: 'Minority Certificate',
        description: 'Student certificate validation for pre-matric scholarship.',
        createdBy: 'Minority Affairs Cell',
        deadline: '30-04-2025',
        status: 'Pending',
        isSubmitted: false,
        questions: [
          FormQuestion(id: 'Q1', label: 'Valid community certificate produced?', type: FormFieldType.boolean),
        ],
      ),
      DynamicForm(
        id: 'FRM_M5',
        title: 'Caste Certificate',
        description: 'Caste certificate validation for reserved category admission tracking.',
        createdBy: 'District Caste Scrutiny Committee',
        deadline: '05-05-2025',
        status: 'Rejected',
        isSubmitted: true,
        questions: [
          FormQuestion(id: 'Q1', label: 'Digital barcode verified on certificate?', type: FormFieldType.boolean),
        ],
      ),
      DynamicForm(
        id: 'FRM_101',
        title: 'Clean Drinking Water & Sanitation Survey 2026',
        description: 'Mandatory district-level audit for summer water availability and functional handwashing points.',
        createdBy: 'BEO Haveli Block Office',
        deadline: '12 Oct 2026',
        questions: [
          FormQuestion(
            id: 'Q1',
            label: 'Does school have 24x7 running tap water for toilets?',
            type: FormFieldType.boolean,
          ),
          FormQuestion(
            id: 'Q2',
            label: 'Total number of functional student handwashing taps',
            type: FormFieldType.number,
          ),
          FormQuestion(
            id: 'Q3',
            label: 'Primary source of drinking water in school premises',
            type: FormFieldType.dropdown,
            options: ['Gram Panchayat Pipeline', 'Borewell with RO Filter', 'Water Tanker Supply', 'Open Well'],
          ),
        ],
      ),
      DynamicForm(
        id: 'FRM_102',
        title: 'Student Travel Distance & Bicycle Scheme Survey',
        description: 'Identify rural students commuting greater than 2 km to sanction free bicycle travel grant.',
        createdBy: 'Kendra Pramukh Kothrud',
        deadline: '18 Oct 2026',
        questions: [
          FormQuestion(
            id: 'BQ1',
            label: 'Number of girls commuting from over 2 km distance',
            type: FormFieldType.number,
          ),
          FormQuestion(
            id: 'BQ2',
            label: 'Public transport / bus connectivity available to village?',
            type: FormFieldType.boolean,
          ),
        ],
      ),
    ];

    // Pre-calculate today's MDM status based on current attendance
    final presentCount = _students.where((s) => s.isPresentToday).length;
    _todayMdm = MdmRecord.calculateForDay(
      date: DateTime.now().toIso8601String().split('T')[0],
      primaryCount: presentCount,
      upperPrimaryCount: 0,
      menu: 'Khichdi with Moong Dal & Boiled Eggs/Bananas',
      eggsFruitCount: presentCount,
    );
  }

  // --- Student Actions ---
  void toggleStudentAttendance(String studentId) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      _students[idx].isPresentToday = !_students[idx].isPresentToday;
      _updateTodayMdm();
      if (_db != null) {
        _db!.update(
          'students',
          {'isPresentToday': _students[idx].isPresentToday ? 1 : 0},
          where: 'id = ?',
          whereArgs: [studentId],
        );
      }
      notifyListeners();
    }
  }

  void markAllAttendance(bool present) {
    for (var s in _students) {
      s.isPresentToday = present;
      if (_db != null) {
        _db!.update('students', {'isPresentToday': present ? 1 : 0}, where: 'id = ?', whereArgs: [s.id]);
      }
    }
    _updateTodayMdm();
    notifyListeners();
  }

  void addStudent(Student student) {
    _students.add(student);
    if (_db != null) {
      _db!.insert('students', student.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    _updateTodayMdm();
    notifyListeners();
  }

  void updateStudent(Student student) {
    final idx = _students.indexWhere((s) => s.id == student.id);
    if (idx != -1) {
      _students[idx] = student;
      if (_db != null) {
        _db!.update('students', student.toMap(), where: 'id = ?', whereArgs: [student.id]);
      }
      _updateTodayMdm();
      notifyListeners();
    }
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    if (_db != null) {
      _db!.delete('students', where: 'id = ?', whereArgs: [studentId]);
    }
    _updateTodayMdm();
    notifyListeners();
  }

  void resolveMismatch(String studentId, String correctedAadhaarName) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      _students[idx] = _students[idx].copyWith(
        nameInAadhaar: correctedAadhaarName,
        hasMismatch: false,
        isAadhaarVerified: true,
      );
      if (_db != null) {
        _db!.update('students', _students[idx].toMap(), where: 'id = ?', whereArgs: [studentId]);
      }
      notifyListeners();
    }
  }

  // --- Task Actions ---
  void toggleTaskCompletion(String taskId, {String? proofRemarks}) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isCompleted = !_tasks[idx].isCompleted;
      if (proofRemarks != null) _tasks[idx].proofRemarks = proofRemarks;
      if (_db != null) {
        _db!.update('circular_tasks', _tasks[idx].toMap(), where: 'id = ?', whereArgs: [taskId]);
      }
      notifyListeners();
    }
  }

  void addCircularTask(CircularTask task) {
    _tasks.insert(0, task);
    if (_db != null) {
      _db!.insert('circular_tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    notifyListeners();
  }

  // --- Asset Actions ---
  void addAsset(SchoolAsset asset) {
    _assets.add(asset);
    if (_db != null) {
      _db!.insert('school_assets', asset.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    notifyListeners();
  }

  void updateAssetCondition(String assetId, AssetCondition condition, String remarks) {
    final idx = _assets.indexWhere((a) => a.id == assetId);
    if (idx != -1) {
      final updated = SchoolAsset(
        id: _assets[idx].id,
        name: _assets[idx].name,
        category: _assets[idx].category,
        quantity: _assets[idx].quantity,
        condition: condition,
        fundingScheme: _assets[idx].fundingScheme,
        location: _assets[idx].location,
        purchaseYear: _assets[idx].purchaseYear,
        remarks: remarks,
      );
      _assets[idx] = updated;
      if (_db != null) {
        _db!.update('school_assets', updated.toMap(), where: 'id = ?', whereArgs: [assetId]);
      }
      notifyListeners();
    }
  }

  // --- Dynamic Form Actions ---
  void addDynamicForm(DynamicForm form) {
    _forms.insert(0, form);
    notifyListeners();
  }

  void submitFormResponse(String formId, Map<String, String> responses) {
    final idx = _forms.indexWhere((f) => f.id == formId);
    if (idx != -1) {
      _forms[idx].isSubmitted = true;
      _forms[idx].responses = responses;
      notifyListeners();
    }
  }

  // --- MDM Recalculation ---
  void _updateTodayMdm() {
    final presentCount = _students.where((s) => s.isPresentToday).length;
    _todayMdm = MdmRecord.calculateForDay(
      date: DateTime.now().toIso8601String().split('T')[0],
      primaryCount: presentCount,
      upperPrimaryCount: 0,
      menu: 'Khichdi with Moong Dal & Boiled Eggs/Bananas',
      eggsFruitCount: presentCount,
    );
  }

  // --- Teacher Actions ---
  void addTeacher(Teacher teacher) {
    _teachers.add(teacher);
    notifyListeners();
  }

  void updateTeacher(Teacher teacher) {
    final idx = _teachers.indexWhere((t) => t.id == teacher.id);
    if (idx != -1) {
      _teachers[idx] = teacher;
      notifyListeners();
    }
  }

  void deleteTeacher(String teacherId) {
    _teachers.removeWhere((t) => t.id == teacherId);
    notifyListeners();
  }

  // --- Multi-School Filtering Getters ---
  List<Teacher> get filteredTeachers {
    if (_selectedSchoolId == 'ALL') {
      return _teachers;
    }
    return _teachers.where((t) => t.schoolId == _selectedSchoolId).toList();
  }

  List<Student> get filteredStudents {
    if (_selectedSchoolId == 'ALL') {
      return _students;
    }
    return _students;
  }

  // --- Form Status Actions ---
  void updateFormStatus(String formId, String newStatus) {
    final idx = _forms.indexWhere((f) => f.id == formId);
    if (idx != -1) {
      _forms[idx].status = newStatus;
      if (newStatus == 'Approved' || newStatus == 'Submitted' || newStatus == 'Rejected') {
        _forms[idx].isSubmitted = true;
      }
      notifyListeners();
    }
  }

  // --- Task Assignment Actions ---
  void assignTask(CircularTask task) {
    _tasks.insert(0, task);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, String newStatus) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].status = newStatus;
      _tasks[idx].isCompleted = newStatus == 'Completed';
      notifyListeners();
    }
  }
}
