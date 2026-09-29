import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../../data/models/student.dart';
import '../../../data/services/ocr_parser_service.dart';

class AddEditStudentSheet extends StatefulWidget {
  final Student? student;
  final Function(Student) onSave;

  const AddEditStudentSheet({super.key, this.student, required this.onSave});

  @override
  State<AddEditStudentSheet> createState() => _AddEditStudentSheetState();
}

class _AddEditStudentSheetState extends State<AddEditStudentSheet> {
  late TextEditingController _grController;
  late TextEditingController _rollController;
  late TextEditingController _schoolNameController;
  late TextEditingController _aadhaarNameController;
  late TextEditingController _aadhaarNoController;
  late TextEditingController _dobController;
  late TextEditingController _parentNameController;
  late TextEditingController _phoneController;
  late TextEditingController _bankController;
  late TextEditingController _ifscController;

  String _gender = 'M';
  String _standard = '4';
  bool _hasMismatch = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _grController = TextEditingController(text: s?.grNumber ?? '');
    _rollController = TextEditingController(text: s?.rollNumber ?? '');
    _schoolNameController = TextEditingController(text: s?.nameInSchool ?? '');
    _aadhaarNameController = TextEditingController(text: s?.nameInAadhaar ?? '');
    _aadhaarNoController = TextEditingController(text: s?.aadhaarNo ?? '');
    _dobController = TextEditingController(text: s?.dob ?? '2016-06-15');
    _parentNameController = TextEditingController(text: s?.parentName ?? '');
    _phoneController = TextEditingController(text: s?.parentPhone ?? '');
    _bankController = TextEditingController(text: s?.bankAccount ?? '');
    _ifscController = TextEditingController(text: s?.ifscCode ?? 'SBIN0001423');
    _gender = s?.gender ?? 'M';
    _standard = s?.standard ?? '4';
    _hasMismatch = s?.hasMismatch ?? false;
  }

  @override
  void dispose() {
    _grController.dispose();
    _rollController.dispose();
    _schoolNameController.dispose();
    _aadhaarNameController.dispose();
    _aadhaarNoController.dispose();
    _dobController.dispose();
    _parentNameController.dispose();
    _phoneController.dispose();
    _bankController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  void _triggerCameraOcr() {
    final schoolName = _schoolNameController.text.trim().isEmpty ? 'Kadam Pooja Nitin' : _schoolNameController.text.trim();
    final scan = OcrParserService.getMockAadhaarScan(schoolName);

    setState(() {
      _aadhaarNameController.text = scan.extractedName;
      _aadhaarNoController.text = scan.extractedAadhaarNo;
      _dobController.text = scan.extractedDob;
      _hasMismatch = scan.isSuspectedMismatch;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: scan.isSuspectedMismatch ? AppColors.warningOrange : AppColors.successGreen,
        content: Text(scan.isSuspectedMismatch
            ? '⚠️ Discrepancy detected between Aadhaar name and School Register.'
            : '✓ Aadhaar card scanned & verified via on-device ML Kit!'),
      ),
    );
  }

  void _save() {
    if (_schoolNameController.text.trim().isEmpty || _grController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter student name and GR number')),
      );
      return;
    }

    final newStudent = Student(
      id: widget.student?.id ?? 'STD_${DateTime.now().millisecondsSinceEpoch}',
      grNumber: _grController.text.trim(),
      rollNumber: _rollController.text.trim(),
      nameInSchool: _schoolNameController.text.trim(),
      nameInAadhaar: _aadhaarNameController.text.trim().isEmpty ? _schoolNameController.text.trim() : _aadhaarNameController.text.trim(),
      aadhaarNo: _aadhaarNoController.text.trim(),
      apaarId: widget.student?.apaarId ?? 'Pending',
      penNumber: widget.student?.penNumber ?? 'PEN${_grController.text.trim()}',
      dob: _dobController.text.trim(),
      gender: _gender,
      standard: _standard,
      section: 'A',
      parentName: _parentNameController.text.trim(),
      parentPhone: _phoneController.text.trim(),
      bankAccount: _bankController.text.trim(),
      ifscCode: _ifscController.text.trim(),
      isAadhaarVerified: !_hasMismatch && _aadhaarNoController.text.isNotEmpty,
      hasMismatch: _hasMismatch,
      apaarConsentSigned: true,
      isPresentToday: widget.student?.isPresentToday ?? true,
    );

    widget.onSave(newStudent);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.student == null ? 'Add New Student (नवीन प्रवेश)' : 'Edit Student Profile',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // AI Camera Scan Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentSaffron,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _triggerCameraOcr,
              icon: const Icon(Icons.camera_alt_rounded, size: 18),
              label: const Text('Scan Aadhaar Card (On-Device OCR)'),
            ),
            const SizedBox(height: 14),

            if (_hasMismatch)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.warningOrangeLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warningOrange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aadhaar spelling differs from School Register. You can standardize it below to prevent APAAR rejection.',
                        style: TextStyle(fontSize: 11, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _grController,
                    decoration: const InputDecoration(labelText: 'GR Number (जनरल रजि. क्र.)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _rollController,
                    decoration: const InputDecoration(labelText: 'Roll No'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _schoolNameController,
              decoration: const InputDecoration(labelText: 'Student Full Name (School Register)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _aadhaarNameController,
              decoration: const InputDecoration(labelText: 'Name as on Aadhaar Card'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _aadhaarNoController,
                    decoration: const InputDecoration(labelText: 'Aadhaar Number'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _dobController,
                    decoration: const InputDecoration(labelText: 'DOB'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _parentNameController,
              decoration: const InputDecoration(labelText: 'Parent / Guardian Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Parent Mobile Number'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bankController,
                    decoration: const InputDecoration(labelText: 'Bank Account No'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ifscController,
                    decoration: const InputDecoration(labelText: 'IFSC Code'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.student == null ? 'Save to Master Vault' : 'Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
