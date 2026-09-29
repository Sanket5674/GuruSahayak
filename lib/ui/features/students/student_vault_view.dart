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
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header Card (Replaces redundant secondary AppBar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.cardBorder.withOpacity(0.8))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.people_alt_rounded, color: AppColors.primaryNavy, size: 22),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'विद्यार्थी मास्टर नोंदवही',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Student Master Vault • UDISE+, SARAL, APAAR & DBT',
                            style: TextStyle(fontSize: 11, color: AppColors.textMedium),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        final csv = ExportService.generateUdiseCsv(db.students);
                        ExportService.shareTextContent(csv, 'UDISE_Student_Roster.csv');
                      },
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Export CSV', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'विद्यार्थ्याचे नाव, हजेरी क्र. किंवा GR नंबर शोधा...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    fillColor: AppColors.backgroundLight,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),
                // Stats Badges & Mark All Button
                Row(
                  children: [
                    _buildStatChip('एकूण: ${db.totalStudentsCount}', AppColors.primaryNavy),
                    const SizedBox(width: 6),
                    _buildStatChip('हजर: ${db.presentStudentsCount}', AppColors.successGreen),
                    const SizedBox(width: 6),
                    if (db.aadhaarMismatchesCount > 0)
                      _buildStatChip('⚠️ ${db.aadhaarMismatchesCount} तफावत', AppColors.dangerRed),
                    const Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => db.markAllAttendance(true),
                      icon: const Icon(Icons.check_circle_outline, size: 15, color: AppColors.successGreen),
                      label: const Text('सर्व हजर करा', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Students Roster List
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(
                    child: Text('विद्यार्थी सापडले नाहीत (No students found)'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final s = filteredStudents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: s.hasMismatch ? AppColors.warningOrange : AppColors.cardBorder,
                            width: s.hasMismatch ? 1.5 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _openAddStudentSheet(context, student: s),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Student Initials Avatar
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: s.hasMismatch
                                        ? AppColors.warningOrange.withOpacity(0.12)
                                        : AppColors.primaryNavy.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      s.rollNumber,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: s.hasMismatch ? AppColors.warningOrange : AppColors.primaryNavy,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Student Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.nameInSchool,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'GR: ${s.grNumber} • Class ${s.standard}-${s.section} • DOB: ${s.dob}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                                      ),
                                      Text(
                                        'Aadhaar: ${s.aadhaarNo}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          if (s.hasMismatch)
                                            _buildBadge('⚠️ नाव तफावत (Mismatch)', AppColors.dangerRed, const Color(0xFFFEE2E2))
                                          else
                                            _buildBadge('✓ आधार पडताळणी', AppColors.successGreen, const Color(0xFFDCFCE7)),
                                          if (s.apaarConsentSigned)
                                            _buildBadge('APAAR: Valid', AppColors.primaryNavy, AppColors.backgroundLight),
                                          if (s.bankAccount.isNotEmpty)
                                            _buildBadge('DBT Bank: Linked', const Color(0xFF0F766E), const Color(0xFFCCFBF1)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Attendance Checkbox Action
                                InkWell(
                                  onTap: () => db.toggleStudentAttendance(s.id),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: s.isPresentToday
                                          ? AppColors.successGreen.withOpacity(0.12)
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      s.isPresentToday ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: s.isPresentToday ? AppColors.successGreen : Colors.grey.shade400,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'student_vault_fab',
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
