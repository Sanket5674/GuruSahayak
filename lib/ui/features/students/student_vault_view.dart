import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/student.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/export_service.dart';
import 'add_edit_student_sheet.dart';

class StudentVaultView extends StatefulWidget {
  const StudentVaultView({super.key});

  @override
  State<StudentVaultView> createState() => _StudentVaultViewState();
}

class _StudentVaultViewState extends State<StudentVaultView> {
  String _searchQuery = '';

  void _openAddStudentSheet(BuildContext context, {Student? student}) {
    final db = Provider.of<LocalDatabaseService>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditStudentSheet(
        student: student,
        onSave: (s) {
          if (student == null) {
            db.addStudent(s);
          } else {
            db.updateStudent(s);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabaseService>(context);

    final filteredStudents = db.students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.nameInSchool.toLowerCase().contains(q) ||
          s.grNumber.toLowerCase().contains(q) ||
          s.rollNumber.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Student Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export UDISE+ CSV',
            onPressed: () {
              final csv = ExportService.generateUdiseCsv(db.students);
              ExportService.shareTextContent(csv, 'UDISE_Student_Roster.csv');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add Student',
            onPressed: () => _openAddStudentSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Quick Status Header
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by student name, roll number, or GR...',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatChip('Total: ${db.totalStudentsCount}', AppColors.primaryNavy),
                    const SizedBox(width: 8),
                    _buildStatChip('Present: ${db.presentStudentsCount}', AppColors.successGreen),
                    const SizedBox(width: 8),
                    if (db.aadhaarMismatchesCount > 0)
                      _buildStatChip('${db.aadhaarMismatchesCount} Mismatches', AppColors.dangerRed),
                    const Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => db.markAllAttendance(true),
                      icon: const Icon(Icons.select_all_rounded, size: 16),
                      label: const Text('All Present', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          // Students Roster List
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No students matching search criteria.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final s = filteredStudents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Roll number badge
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: s.isPresentToday ? AppColors.successGreenLight : AppColors.cardBorder,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      s.rollNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: s.isPresentToday ? AppColors.successGreen : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.nameInSchool,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                        ),
                                        Text(
                                          'GR: ${s.grNumber} • Class ${s.standard}-${s.section} • DOB: ${s.dob}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                        Text(
                                          'Aadhaar: ${s.aadhaarNo.isEmpty ? "Not Provided" : s.aadhaarNo}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Attendance Checkbox / Toggle
                                  IconButton(
                                    tooltip: s.isPresentToday ? 'Mark Absent' : 'Mark Present',
                                    icon: Icon(
                                      s.isPresentToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: s.isPresentToday ? AppColors.successGreen : AppColors.textLight,
                                      size: 26,
                                    ),
                                    onPressed: () => db.toggleStudentAttendance(s.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Compliance Status Chips
                              Wrap(
                                spacing: 6,
                                children: [
                                  if (s.hasMismatch)
                                    _buildBadge('Aadhaar Mismatch', AppColors.dangerRed, AppColors.dangerRedLight)
                                  else if (s.isAadhaarVerified)
                                    _buildBadge('Aadhaar Verified', AppColors.successGreen, AppColors.successGreenLight)
                                  else
                                    _buildBadge('Aadhaar Pending', AppColors.warningOrange, AppColors.warningOrangeLight),
                                  if (s.apaarConsentSigned)
                                    _buildBadge('APAAR Consent: Signed', AppColors.primaryNavy, AppColors.backgroundLight),
                                  if (s.bankAccount.isNotEmpty)
                                    _buildBadge('DBT Bank Linked', const Color(0xFF0F766E), const Color(0xFFCCFBF1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryNavy,
        onPressed: () => _openAddStudentSheet(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBadge(String text, Color textCol, Color bgCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgCol,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textCol.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textCol),
      ),
    );
  }
}
