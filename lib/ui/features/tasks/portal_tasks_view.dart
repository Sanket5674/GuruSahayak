import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/circular_task.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';
import 'circular_detail_sheet.dart';

class PortalTasksView extends StatefulWidget {
  const PortalTasksView({super.key});

  @override
  State<PortalTasksView> createState() => _PortalTasksViewState();
}

class _PortalTasksViewState extends State<PortalTasksView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All Tasks', 'My Tasks', 'Submitted', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleService>(context);
    final db = Provider.of<LocalDatabaseService>(context);

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
                locale.navTasks,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.t('Tasks & Approvals', 'दैनंदिन कामे व मंजुरी'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAssignTaskDialog(context, db, locale),
                icon: const Icon(Icons.assignment_add, size: 18),
                label: Text(locale.t('+ Assign Task', '+ काम वाटप करा')),
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

          // Tab Navigation Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primaryNavy,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorColor: AppColors.primaryNavy,
              indicatorWeight: 3,
              tabs: _tabs.map((tab) {
                String localized;
                switch (tab) {
                  case 'All Tasks':
                    localized = locale.t('All Tasks', 'सर्व कामे');
                    break;
                  case 'My Tasks':
                    localized = locale.t('My Tasks', 'माझी कामे');
                    break;
                  case 'Submitted':
                    localized = locale.statusSubmitted;
                    break;
                  case 'Completed':
                    localized = locale.statusCompleted;
                    break;
                  default:
                    localized = tab;
                }
                return Tab(text: localized);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Tab View Table Container
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final currentTab = _tabs[_tabController.index];
              final allTasks = db.tasks;

              List<CircularTask> filtered;
              if (currentTab == 'All Tasks') {
                filtered = allTasks;
              } else if (currentTab == 'My Tasks') {
                filtered = allTasks.where((t) => t.assignedTo != 'All Staff').toList();
              } else if (currentTab == 'Submitted') {
                filtered = allTasks.where((t) => t.status == 'In Progress' || t.isCompleted).toList();
              } else {
                filtered = allTasks.where((t) => t.isCompleted || t.status == 'Completed').toList();
              }

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 800),
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
                            DataColumn(label: Text(locale.t('Task Title', 'कामाचे शीर्षक'))),
                            DataColumn(label: Text(locale.t('Assigned To', 'कोणाला सोपवले'))),
                            DataColumn(label: Text(locale.t('Due Date', 'मुदत तारीख'))),
                            DataColumn(label: Text(locale.t('Status', 'स्थिती'))),
                            DataColumn(label: Text(locale.t('Actions', 'कृती'))),
                          ],
                          rows: List.generate(filtered.length, (index) {
                            final task = filtered[index];
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(
                                  Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 15, color: AppColors.textMuted),
                                      const SizedBox(width: 5),
                                      Text(task.assignedTo),
                                    ],
                                  ),
                                ),
                                DataCell(Text(task.deadline)),
                                DataCell(_buildTaskStatusBadge(task, locale)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primaryNavyLight),
                                        tooltip: locale.t('View Checklist', 'तपशील पहा'),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) => CircularDetailSheet(task: task),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                          size: 18,
                                          color: task.isCompleted ? AppColors.successGreen : AppColors.textMuted,
                                        ),
                                        tooltip: locale.t('Toggle Completed', 'पूर्ण चिन्हांकित करा'),
                                        onPressed: () {
                                          db.toggleTaskCompletion(task.id);
                                        },
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.t('Showing 1 - ${filtered.length} of 12', '१ - ${filtered.length} एकूण १२ पैकी'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const Text('Page 1 of 3', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatusBadge(CircularTask task, LocaleService locale) {
    Color bg;
    Color fg;
    String label;

    if (task.isCompleted || task.status.toLowerCase() == 'completed') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF16A34A);
      label = locale.statusCompleted;
    } else if (task.status.toLowerCase() == 'in progress') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF2563EB);
      label = locale.statusInProgress;
    } else {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
      label = locale.statusPending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  void _showAssignTaskDialog(BuildContext context, LocalDatabaseService db, LocaleService locale) {
    final titleCtrl = TextEditingController();
    final summaryCtrl = TextEditingController();
    final deadlineCtrl = TextEditingController(text: '30-04-2025');
    String selectedTeacher = db.teachers.isNotEmpty ? db.teachers.first.name : 'All Staff';
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(locale.t('Assign New Task', 'नवीन काम सोपवा'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(labelText: locale.t('Task Title', 'कामाचे शीर्षक'), hintText: 'e.g. Science Fair Preparation'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: summaryCtrl,
                    decoration: InputDecoration(labelText: locale.t('Instructions / Summary', 'सूचना व तपशील')),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedTeacher,
                    decoration: InputDecoration(labelText: locale.t('Assign To Teacher', 'शिक्षक निवडा')),
                    items: [
                      const DropdownMenuItem(value: 'All Staff', child: Text('All Staff (सर्व शिक्षक)')),
                      ...db.teachers.map((t) => DropdownMenuItem(value: t.name, child: Text('${t.name} (${t.subject})'))),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedTeacher = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: deadlineCtrl,
                    decoration: InputDecoration(labelText: locale.t('Deadline', 'मुदत तारीख')),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.cancel)),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isNotEmpty) {
                  final newTask = CircularTask(
                    id: 'TSK_${DateTime.now().millisecondsSinceEpoch}',
                    grNumber: 'TASK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    title: titleCtrl.text.trim(),
                    summary: summaryCtrl.text.trim().isEmpty ? 'Complete assigned task before deadline.' : summaryCtrl.text.trim(),
                    issuedBy: 'Portal Administrator',
                    deadline: deadlineCtrl.text.trim(),
                    assignedTo: selectedTeacher,
                    priority: priority,
                    checklist: ['Review guidelines', 'Submit proof to Headmaster'],
                  );
                  db.assignTask(newTask);
                  Navigator.of(ctx).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavyLight, foregroundColor: Colors.white),
              child: Text(locale.save),
            ),
          ],
        ),
      ),
    );
  }
}
