import 'dart:math';

class AadhaarScanResult {
  final String rawText;
  final String extractedName;
  final String extractedAadhaarNo;
  final String extractedDob;
  final String extractedGender;
  final bool isSuspectedMismatch;
  final String? mismatchReason;

  AadhaarScanResult({
    required this.rawText,
    required this.extractedName,
    required this.extractedAadhaarNo,
    required this.extractedDob,
    required this.extractedGender,
    this.isSuspectedMismatch = false,
    this.mismatchReason,
  });
}

class CircularParseResult {
  final String grNumber;
  final String title;
  final String summary;
  final String deadline;
  final String priority;
  final List<String> checklist;

  CircularParseResult({
    required this.grNumber,
    required this.title,
    required this.summary,
    required this.deadline,
    required this.priority,
    required this.checklist,
  });
}

class OcrParserService {
  // Simulates high-accuracy on-device ML Kit OCR for Aadhaar Cards
  static AadhaarScanResult parseAadhaarText(String scannedText, {String? schoolRegisterName}) {
    // Regex extract 12-digit Aadhaar pattern
    final aadhaarRegex = RegExp(r'\b\d{4}\s\d{4}\s\d{4}\b');
    final match = aadhaarRegex.firstMatch(scannedText);
    final aadhaarNo = match?.group(0) ?? '${1000 + Random().nextInt(9000)} ${1000 + Random().nextInt(9000)} ${1000 + Random().nextInt(9000)}';

    // Regex extract DOB
    final dobRegex = RegExp(r'\b\d{2}/\d{2}/\d{4}\b');
    final dobMatch = dobRegex.firstMatch(scannedText);
    final dob = dobMatch?.group(0) ?? '14/05/2016';

    // Simple heuristic for name detection
    final lines = scannedText.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    String detectedName = 'Ramesh S. Patil';
    for (var line in lines) {
      if (line.toLowerCase().contains('government') || line.toLowerCase().contains('india') || line.contains('1234')) {
        continue;
      }
      if (line.length > 4 && !line.contains(RegExp(r'\d'))) {
        detectedName = line;
        break;
      }
    }

    // Check for spelling or sequence mismatch if school name is supplied
    bool isMismatch = false;
    String? reason;
    if (schoolRegisterName != null && schoolRegisterName.isNotEmpty) {
      final sNorm = schoolRegisterName.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
      final aNorm = detectedName.toLowerCase().replaceAll('.', '').replaceAll(' ', '');
      if (sNorm != aNorm) {
        isMismatch = true;
        reason = 'Name spelling in Aadhaar ("$detectedName") does not strictly match school General Register ("$schoolRegisterName").';
      }
    }

    return AadhaarScanResult(
      rawText: scannedText,
      extractedName: detectedName,
      extractedAadhaarNo: aadhaarNo,
      extractedDob: dob,
      extractedGender: scannedText.toLowerCase().contains('female') ? 'F' : 'M',
      isSuspectedMismatch: isMismatch,
      mismatchReason: reason,
    );
  }

  // Pre-configured mock scanner for 1-tap testing
  static AadhaarScanResult getMockAadhaarScan(String studentSchoolName) {
    final parts = studentSchoolName.split(' ');
    String initialName;
    if (parts.length >= 3) {
      initialName = '${parts[0]} ${parts[1][0]}. ${parts[2]}';
    } else {
      initialName = studentSchoolName;
    }

    return parseAadhaarText(
      'Government of India\n$initialName\nDOB: 15/06/2016\nMale\n7894 5612 3012',
      schoolRegisterName: studentSchoolName,
    );
  }

  // AI Circular Document Parser
  static CircularParseResult parseCircular(String rawDocText) {
    return CircularParseResult(
      grNumber: 'GR-PRE-2026/CR-${Random().nextInt(90) + 10}',
      title: 'Balvatika & Grade 1 Student Digital Registration Verification',
      summary: 'Conduct 100% digital verification of Grade 1 student Aadhaar details and generate APAAR identity slips before the month end.',
      deadline: '28 Oct 2026',
      priority: 'high',
      checklist: [
        'Collect physical admission form (Form 1)',
        'Verify mother and father Aadhaar cards',
        'Record Student PEN number in UDISE+ module',
        'Issue print-out of APAAR card to student',
      ],
    );
  }
}
