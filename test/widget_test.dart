import 'package:flutter_test/flutter_test.dart';
import 'package:gurusahayak/data/models/mdm_record.dart';
import 'package:gurusahayak/data/models/student.dart';
import 'package:gurusahayak/data/models/user_profile.dart';
import 'package:gurusahayak/data/models/dynamic_form.dart';
import 'package:gurusahayak/data/services/auth_service.dart';
import 'package:gurusahayak/data/services/ocr_parser_service.dart';
import 'package:gurusahayak/data/services/export_service.dart';

void main() {
  group('PM-POSHAN (MDM) Formula & SMS Engine Tests', () {
    test('Calculates exact ration weight for 40 primary students', () {
      final mdm = MdmRecord.calculateForDay(
        date: '2026-10-01',
        primaryCount: 40,
        upperPrimaryCount: 0,
        menu: 'Khichdi',
        eggsFruitCount: 40,
      );

      // Primary norms: 100g Rice, 20g Dal, 5g Oil
      expect(mdm.riceGrams, equals(4000.0)); // 4.0 kg
      expect(mdm.dalGrams, equals(800.0));   // 0.8 kg
      expect(mdm.oilGrams, equals(200.0));   // 0.2 kg
      expect(mdm.totalStudentsServed, equals(40));

      // Test Official SMS syntax to 15544
      final sms = mdm.toSmsMessage('27250100101');
      expect(sms, equals('MDM 27250100101 40'));
    });
  });

  group('Student Master Vault & Aadhaar Mismatch Detection', () {
    test('Detects name discrepancy between school register and Aadhaar card', () {
      final scanResult = OcrParserService.parseAadhaarText(
        'Government of India\nRohan S Jadav\nDOB: 11/02/2016\n8876 2341 5567',
        schoolRegisterName: 'Jadhav Rohan Sandeep',
      );
      // Intentional spelling discrepancy should trigger warning flag
      expect(scanResult.isSuspectedMismatch, isTrue);

      final cleanResult = OcrParserService.parseAadhaarText(
        'Government of India\nPatil Aarav Ramesh\nDOB: 14/05/2016\n4829 1029 3847',
        schoolRegisterName: 'Patil Aarav Ramesh',
      );
      // Matching names should not trigger discrepancy
      expect(cleanResult.isSuspectedMismatch, isFalse);
    });

    test('Generates standard compliant UDISE+ CSV export', () {
      final students = [
        Student(
          id: 'STD_1',
          grNumber: '1452',
          rollNumber: '01',
          nameInSchool: 'Patil Aarav Ramesh',
          nameInAadhaar: 'Aarav Ramesh Patil',
          aadhaarNo: '4829 1029 3847',
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
      ];

      final csv = ExportService.generateUdiseCsv(students);
      expect(csv.contains('GR Number'), isTrue);
      expect(csv.contains('Patil Aarav Ramesh'), isTrue);
      expect(csv.contains('APAAR98234101'), isTrue);
    });
  });

  group('Hierarchy & Multi-Role Switching Engine', () {
    test('Switches between Teacher, Headmaster, and Officer roles seamlessly', () {
      final auth = AuthService();
      expect(auth.currentRole, equals(UserRole.teacher));
      expect(auth.isTeacher, isTrue);

      // Switch to Headmaster
      auth.switchRole(UserRole.headmaster);
      expect(auth.currentRole, equals(UserRole.headmaster));
      expect(auth.isHeadmaster, isTrue);
      expect(auth.currentUser.name, contains('Sunita Deshmukh'));

      // Switch to Education Officer
      auth.switchRole(UserRole.officer);
      expect(auth.currentRole, equals(UserRole.officer));
      expect(auth.isOfficer, isTrue);
      expect(auth.currentUser.name, contains('Dr. Anand Kulkarni'));
    });
  });

  group('Dynamic Form & Field Surveys', () {
    test('Serializes questions and handles field survey responses', () {
      final question = FormQuestion(
        id: 'Q1',
        label: 'Tap water available in toilets?',
        type: FormFieldType.boolean,
      );

      final map = question.toMap();
      expect(map['id'], equals('Q1'));
      expect(map['type'], equals('boolean'));

      final restored = FormQuestion.fromMap(map);
      expect(restored.label, equals(question.label));
      expect(restored.type, equals(FormFieldType.boolean));
    });
  });
}
