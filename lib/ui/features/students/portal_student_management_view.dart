import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/student.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/export_service.dart';
import 'add_edit_student_sheet.dart';

class PortalStudentManagementView extends StatefulWidget {
  const PortalStudentManagementView({super.key});

  @override
  State<PortalStudentManagementView> createState() => _PortalStudentManagementViewState();
}

class _PortalStudentManagementViewState extends State<PortalStudentManagementView> {
  final _searchController = TextEditingController();
  String _selectedSchoolFilter = 'All Schools';
  String _selectedClassFilter = 'All Classes';
  int _currentPage = 1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleService>(context);
    final db = Provider.of<LocalDatabaseService>(context);

    final allStudents = db.students;

    // Filter logic
    final query = _searchController.text.trim().toLowerCase();
    final filteredStudents = allStudents.where((s) {
      final matchesSearch = query.isEmpty ||
          s.nameInSchool.toLowerCase().contains(query) ||
          s.rollNumber.contains(query) ||
          s.grNumber.contains(query) ||
          s.standard.contains(query);

      final matchesClass = _selectedClassFilter == 'All Classes' ||
          _selectedClassFilter == locale.t('All Classes', 'सर्व वर्ग') ||
          s.standard == _selectedClassFilter;

      return matchesSearch && matchesClass;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text(
                locale.t('Home', 'मुख्य'),
                style: const TextStyle(fontSize: 12, color: AppColors.primaryNavyLight, fontWeight: FontWeight.bold),
              ),
              const Text('  >  ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              Text(
                locale.navStudents,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header: Title & Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.t('Students', 'विद्यार्थी'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _exportUdiseCsv(context, db, locale),
                    icon: const Icon(Icons.file_download_outlined, size: 16),
                    label: Text(locale.t('Export CSV', 'CSV निर्यात')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryNavy,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentDialog(context, db),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(locale.addStudent),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavyLight,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Controls Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 720;
                if (isWide) {
                  return Row(
                    children: [
                      // Search Bar
                      Expanded(
                        flex: 5,
                        child: _buildSearchField(locale),
                      ),
                      const SizedBox(width: 12),
                      // School Filter Dropdown
                      Expanded(
                        flex: 3,
                        child: _buildSchoolFilter(db, locale),
                      ),
                      const SizedBox(width: 12),
                      // Class Filter Dropdown
                      Expanded(
                        flex: 3,
                        child: _buildClassFilter(locale),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildSearchField(locale),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildSchoolFilter(db, locale)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildClassFilter(locale)),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 16),

          // Data Table Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scrollable Data Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 840),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: AppColors.textDark,
                      ),
                      dataTextStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      columnSpacing: 22,
                      horizontalMargin: 20,
                      columns: [
                        const DataColumn(label: Text('#')),
                        DataColumn(label: Text(locale.t('Name', 'नाव'))),
                        DataColumn(label: Text(locale.t('Roll No', 'हजेरी क्र.'))),
                        DataColumn(label: Text(locale.t('Class', 'इयत्ता'))),
                        DataColumn(label: Text(locale.t('Section', 'तुकडी'))),
                        DataColumn(label: Text(locale.t('Gender', 'लिंग'))),
                        DataColumn(label: Text(locale.t('Status', 'स्थिती'))),
                        DataColumn(label: Text(locale.t('Actions', 'कृती'))),
                      ],
                      rows: List.generate(filteredStudents.length, (index) {
                        final student = filteredStudents[index];
                        final isFemale = student.gender.toUpperCase() == 'F' || student.gender.toLowerCase() == 'female';

                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: (isFemale ? const Color(0xFFEC4899) : const Color(0xFF2563EB)).withOpacity(0.12),
                                    child: Text(
                                      student.nameInSchool.isNotEmpty ? student.nameInSchool[0] : 'S',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isFemale ? const Color(0xFFEC4899) : const Color(0xFF2563EB),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        student.nameInSchool,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      if (student.hasMismatch)
                                        const Text(
                                          '⚠️ Aadhaar Name Mismatch',
                                          style: TextStyle(fontSize: 10, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(student.rollNumber)),
                            DataCell(Text(student.standard)),
                            DataCell(Text(student.section)),
                            DataCell(Text(isFemale ? locale.t('Female', 'स्त्री') : locale.t('Male', 'पुरुष'))),
                            DataCell(
                              student.hasMismatch
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDD5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        locale.t('Mismatch', 'तफावत'),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warningOrange),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        locale.statusActive,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                      ),
                                    ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, size: 17, color: AppColors.primaryNavyLight),
                                    tooltip: locale.t('View', 'पहा'),
                                    onPressed: () => _showStudentDetails(context, student, locale, db),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.textMuted),
                                    tooltip: locale.t('Edit', 'संपादित करा'),
                                    onPressed: () => _editStudent(context, db, student),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.dangerRed),
                                    tooltip: locale.t('Delete', 'हटवा'),
                                    onPressed: () => _deleteStudent(context, db, student, locale),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),

                const Divider(height: 1, color: AppColors.cardBorder),

                // Pagination Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale.t(
                          'Showing 1 - ${filteredStudents.length} of 482',
                          '१ - ${filteredStudents.length} एकूण ४८२ पैकी',
                        ),
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      Row(
                        children: [
                          _buildPageButton(
                            label: '<',
                            isActive: false,
                            onTap: () {
                              if (_currentPage > 1) setState(() => _currentPage--);
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildPageButton(label: '1', isActive: _currentPage == 1, onTap: () => setState(() => _currentPage = 1)),
                          const SizedBox(width: 4),
                          _buildPageButton(label: '2', isActive: _currentPage == 2, onTap: () => setState(() => _currentPage = 2)),
                          const SizedBox(width: 4),
                          _buildPageButton(label: '3', isActive: _currentPage == 3, onTap: () => setState(() => _currentPage = 3)),
                          const SizedBox(width: 4),
                          _buildPageButton(label: '4', isActive: _currentPage == 4, onTap: () => setState(() => _currentPage = 4)),
                          const SizedBox(width: 4),
                          _buildPageButton(
                            label: '>',
                            isActive: false,
                            onTap: () {
                              if (_currentPage < 4) setState(() => _currentPage++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(LocaleService locale) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: locale.t('Search by name, roll no, class...', 'नाव, हजेरी क्र., वर्गाने शोधा...'),
        hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textLight),
        prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildSchoolFilter(LocalDatabaseService db, LocaleService locale) {
    final items = [
      DropdownMenuItem(
        value: 'All Schools',
        child: Text(locale.t('All Schools', 'सर्व शाळा'), style: const TextStyle(fontSize: 12.5)),
      ),
      ...db.schools.map((s) => DropdownMenuItem(
        value: s.id,
        child: Text(s.localizedName(locale.isMarathi), style: const TextStyle(fontSize: 12.5)),
      )),
    ];

    return DropdownButtonFormField<String>(
      value: _selectedSchoolFilter,
      items: items,
      onChanged: (val) {
        if (val != null) setState(() => _selectedSchoolFilter = val);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildClassFilter(LocaleService locale) {
    final classes = ['All Classes', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

    return DropdownButtonFormField<String>(
      value: _selectedClassFilter,
      items: classes.map((c) => DropdownMenuItem(
        value: c,
        child: Text(
          c == 'All Classes' ? locale.t('All Classes', 'सर्व वर्ग') : 'Class $c',
          style: const TextStyle(fontSize: 12.5),
        ),
      )).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedClassFilter = val);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
    );
  }

  Widget _buildPageButton({required String label, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryNavyLight : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isActive ? AppColors.primaryNavyLight : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context, LocalDatabaseService db) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditStudentSheet(
        onSave: (newStudent) {
          db.addStudent(newStudent);
        },
      ),
    );
  }

  void _editStudent(BuildContext context, LocalDatabaseService db, Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditStudentSheet(
        student: student,
        onSave: (updated) {
          db.updateStudent(updated);
        },
      ),
    );
  }

  void _showStudentDetails(BuildContext context, Student student, LocaleService locale, LocalDatabaseService db) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.school_outlined, color: AppColors.primaryNavyLight),
            const SizedBox(width: 8),
            Text(student.nameInSchool, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('GR Number', student.grNumber),
            _buildDetailRow('Roll Number', student.rollNumber),
            _buildDetailRow('Standard & Section', 'Class ${student.standard}-${student.section}'),
            _buildDetailRow('Name in Aadhaar', student.nameInAadhaar),
            _buildDetailRow('Aadhaar Number', student.aadhaarNo),
            _buildDetailRow('APAAR ID', student.apaarId),
            _buildDetailRow('Parent Name', student.parentName),
            _buildDetailRow('Parent Phone', student.parentPhone),
            _buildDetailRow('Bank A/C', student.bankAccount),
            _buildDetailRow('IFSC Code', student.ifscCode),
            if (student.hasMismatch) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.dangerRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locale.t(
                          'Aadhaar spelling mismatch detected! Fix spelling to verify student.',
                          'आधार स्पेलिंग तफावत आढळली! कृपया स्पेलिंग दुरुस्त करा.',
                        ),
                        style: const TextStyle(fontSize: 11.5, color: AppColors.dangerRed, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        db.resolveMismatch(student.id, student.nameInSchool);
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
                      child: const Text('Resolve'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.t('Close', 'बंद करा'))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textDark))),
        ],
      ),
    );
  }

  void _deleteStudent(BuildContext context, LocalDatabaseService db, Student student, LocaleService locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.t('Delete Student?', 'विद्यार्थी हटवायचा का?')),
        content: Text(locale.t('Delete ${student.nameInSchool} from register?', '${student.nameInSchool} यांना पटावरून काढायचे का?')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.cancel)),
          ElevatedButton(
            onPressed: () {
              db.deleteStudent(student.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, foregroundColor: Colors.white),
            child: Text(locale.t('Delete', 'हटवा')),
          ),
        ],
      ),
    );
  }

  void _exportUdiseCsv(BuildContext context, LocalDatabaseService db, LocaleService locale) {
    final csvContent = ExportService.generateUdiseCsv(db.students);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.t('UDISE+ CSV Generated', 'UDISE+ CSV तयार झाला')),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(locale.t(
                'Successfully generated government standard UDISE+ compliant CSV file with ${db.students.length} student records.',
                'शासकीय मानकांनुसार ${db.students.length} विद्यार्थ्यांचा UDISE+ CSV तयार करण्यात आला.',
              )),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    csvContent,
                    style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(locale.t('Done', 'पूर्ण')),
          ),
        ],
      ),
    );
  }
}
