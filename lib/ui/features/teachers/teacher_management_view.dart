import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/teacher.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';

class TeacherManagementView extends StatefulWidget {
  const TeacherManagementView({super.key});

  @override
  State<TeacherManagementView> createState() => _TeacherManagementViewState();
}

class _TeacherManagementViewState extends State<TeacherManagementView> {
  final _searchController = TextEditingController();
  String _selectedSchoolFilter = 'All Schools';
  String _selectedSubjectFilter = 'All Subjects';
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

    final allTeachers = db.teachers;

    // Filter logic
    final query = _searchController.text.trim().toLowerCase();
    final filteredTeachers = allTeachers.where((t) {
      final matchesSearch = query.isEmpty ||
          t.name.toLowerCase().contains(query) ||
          t.subject.toLowerCase().contains(query) ||
          t.phone.contains(query);

      final matchesSchool = _selectedSchoolFilter == 'All Schools' ||
          _selectedSchoolFilter == locale.t('All Schools', 'सर्व शाळा') ||
          t.schoolId == _selectedSchoolFilter;

      final matchesSubject = _selectedSubjectFilter == 'All Subjects' ||
          _selectedSubjectFilter == locale.t('All Subjects', 'सर्व विषय') ||
          t.subject == _selectedSubjectFilter;

      return matchesSearch && matchesSchool && matchesSubject;
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
                locale.navTeachers,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header: Title & "+ Add Teacher" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.t('Teachers', 'शिक्षक'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTeacherDialog(context, db, locale),
                icon: const Icon(Icons.add, size: 18),
                label: Text(locale.addTeacher),
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
                      // Subject Filter Dropdown
                      Expanded(
                        flex: 3,
                        child: _buildSubjectFilter(locale),
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
                          Expanded(child: _buildSubjectFilter(locale)),
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
                    constraints: const BoxConstraints(minWidth: 780),
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
                      columnSpacing: 24,
                      horizontalMargin: 20,
                      columns: [
                        const DataColumn(label: Text('#')),
                        DataColumn(label: Text(locale.t('Name', 'नाव'))),
                        DataColumn(label: Text(locale.t('Subject', 'विषय'))),
                        DataColumn(label: Text(locale.t('Class', 'वर्ग'))),
                        DataColumn(label: Text(locale.t('Mobile', 'मोबाईल'))),
                        DataColumn(label: Text(locale.t('Status', 'स्थिती'))),
                        DataColumn(label: Text(locale.t('Actions', 'कृती'))),
                      ],
                      rows: List.generate(filteredTeachers.length, (index) {
                        final teacher = filteredTeachers[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: AppColors.primaryNavyLight.withOpacity(0.12),
                                    child: Text(
                                      teacher.name.isNotEmpty ? teacher.name[0] : 'T',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryNavyLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    teacher.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(teacher.subject)),
                            DataCell(Text(teacher.gradesAssigned)),
                            DataCell(Text(teacher.phone)),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  locale.statusActive,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF16A34A),
                                  ),
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
                                    onPressed: () => _showTeacherDetailsDialog(context, teacher, locale),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.textMuted),
                                    tooltip: locale.t('Edit', 'संपादित करा'),
                                    onPressed: () => _showEditTeacherDialog(context, db, teacher, locale),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 17, color: AppColors.dangerRed),
                                    tooltip: locale.t('Delete', 'हटवा'),
                                    onPressed: () => _confirmDeleteTeacher(context, db, teacher, locale),
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
                          'Showing 1 - ${filteredTeachers.length} of 64',
                          '१ - ${filteredTeachers.length} एकूण ६४ पैकी',
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
        hintText: locale.t('Search by name, subject, mobile...', 'नाव, विषय, मोबाईलने शोधा...'),
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

  Widget _buildSubjectFilter(LocaleService locale) {
    final subjects = ['All Subjects', 'Marathi', 'English', 'Science', 'Mathematics', 'Social Science', 'Hindi', 'Computer', 'Physical Edu.'];

    return DropdownButtonFormField<String>(
      value: _selectedSubjectFilter,
      items: subjects.map((sub) => DropdownMenuItem(
        value: sub,
        child: Text(
          sub == 'All Subjects' ? locale.t('All Subjects', 'सर्व विषय') : sub,
          style: const TextStyle(fontSize: 12.5),
        ),
      )).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedSubjectFilter = val);
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

  void _showAddTeacherDialog(BuildContext context, LocalDatabaseService db, LocaleService locale) {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController();
    final gradeCtrl = TextEditingController(text: '5-10');
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(locale.addTeacher, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: locale.t('Full Name', 'पूर्ण नाव'), hintText: 'e.g. R. S. Patil'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: subjectCtrl,
                  decoration: InputDecoration(labelText: locale.t('Subject', 'विषय'), hintText: 'e.g. Mathematics'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: gradeCtrl,
                  decoration: InputDecoration(labelText: locale.t('Grades / Class', 'इयत्ता / वर्ग'), hintText: 'e.g. 5-10'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: locale.t('Mobile Number', 'मोबाईल नंबर'), hintText: '10 digits'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: locale.t('Email ID', 'ईमेल'), hintText: 'name@school.gov.in'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(locale.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                final newTeacher = Teacher(
                  id: 'TCH_${DateTime.now().millisecondsSinceEpoch}',
                  employeeId: 'MH${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  name: nameCtrl.text.trim(),
                  subject: subjectCtrl.text.trim().isEmpty ? 'General' : subjectCtrl.text.trim(),
                  gradesAssigned: gradeCtrl.text.trim().isEmpty ? '5-10' : gradeCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty ? 'teacher@school.gov.in' : emailCtrl.text.trim(),
                  schoolId: db.selectedSchoolId == 'ALL' ? 'SCH_01' : db.selectedSchoolId,
                  status: 'Active',
                );
                db.addTeacher(newTeacher);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.successGreen,
                    content: Text(locale.t('Teacher added successfully!', 'शिक्षक यशस्वीरीत्या जोडला गेला!')),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavyLight,
              foregroundColor: Colors.white,
            ),
            child: Text(locale.save),
          ),
        ],
      ),
    );
  }

  void _showTeacherDetailsDialog(BuildContext context, Teacher teacher, LocaleService locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.badge_outlined, color: AppColors.primaryNavyLight),
            const SizedBox(width: 8),
            Text(teacher.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(locale.t('Employee ID', 'कर्मचारी क्रमांक'), teacher.employeeId),
            _buildDetailRow(locale.t('Subject', 'विषय'), teacher.subject),
            _buildDetailRow(locale.t('Assigned Classes', 'नेमलेले वर्ग'), teacher.gradesAssigned),
            _buildDetailRow(locale.t('Mobile', 'मोबाईल'), teacher.phone),
            _buildDetailRow(locale.t('Email', 'ईमेल'), teacher.email),
            _buildDetailRow(locale.t('Designation', 'पद'), teacher.designation),
            _buildDetailRow(locale.t('Status', 'स्थिती'), teacher.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(locale.t('Close', 'बंद करा')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  void _showEditTeacherDialog(BuildContext context, LocalDatabaseService db, Teacher teacher, LocaleService locale) {
    final nameCtrl = TextEditingController(text: teacher.name);
    final subjectCtrl = TextEditingController(text: teacher.subject);
    final phoneCtrl = TextEditingController(text: teacher.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(locale.t('Edit Teacher', 'शिक्षक संपादन करा')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: locale.t('Name', 'नाव'))),
            const SizedBox(height: 10),
            TextField(controller: subjectCtrl, decoration: InputDecoration(labelText: locale.t('Subject', 'विषय'))),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: locale.t('Mobile', 'मोबाईल'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.cancel)),
          ElevatedButton(
            onPressed: () {
              final updated = teacher.copyWith(
                name: nameCtrl.text.trim(),
                subject: subjectCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
              );
              db.updateTeacher(updated);
              Navigator.of(ctx).pop();
            },
            child: Text(locale.save),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTeacher(BuildContext context, LocalDatabaseService db, Teacher teacher, LocaleService locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(locale.t('Delete Teacher?', 'शिक्षक हटवायचा का?')),
        content: Text(locale.t(
          'Are you sure you want to delete ${teacher.name} from the portal staff roster?',
          'आपण खात्रीपूर्वक ${teacher.name} यांना पोर्टल शिक्षक यादीतून काढू इच्छिता का?',
        )),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.cancel)),
          ElevatedButton(
            onPressed: () {
              db.deleteTeacher(teacher.id);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, foregroundColor: Colors.white),
            child: Text(locale.t('Delete', 'हटवा')),
          ),
        ],
      ),
    );
  }
}
