import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';
import '../models/circular_task.dart';
import '../models/school_asset.dart';
import '../models/dynamic_form.dart';
import '../models/mdm_record.dart';

class LocalDatabaseService extends ChangeNotifier {
  Database? _db;

  List<Student> _students = [];
  List<CircularTask> _tasks = [];
  List<SchoolAsset> _assets = [];
  List<DynamicForm> _forms = [];
  MdmRecord? _todayMdm;

  List<Student> get students => _students;
  List<CircularTask> get tasks => _tasks;
  List<SchoolAsset> get assets => _assets;
  List<DynamicForm> get forms => _forms;
  MdmRecord? get todayMdm => _todayMdm;

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
    ];

    _tasks = [
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
}
