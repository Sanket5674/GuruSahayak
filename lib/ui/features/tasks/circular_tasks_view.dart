import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/circular_task.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/ocr_parser_service.dart';
import 'circular_detail_sheet.dart';

class CircularTasksView extends StatefulWidget {
  const CircularTasksView({super.key});

  @override
  State<CircularTasksView> createState() => _CircularTasksViewState();
}

class _CircularTasksViewState extends State<CircularTasksView> {
  String _filter = 'all'; // 'all', 'pending', 'completed'

  void _openTaskDetails(BuildContext context, CircularTask task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CircularDetailSheet(task: task),
    );
  }

  void _scanAndBroadcastCircular(BuildContext context) {
    final db = Provider.of<LocalDatabaseService>(context, listen: false);
    final parsed = OcrParserService.parseCircular('');
    db.addCircularTask(CircularTask(
      id: 'TSK_${DateTime.now().millisecondsSinceEpoch}',
      grNumber: parsed.grNumber,
      title: parsed.title,
      summary: parsed.summary,
      issuedBy: 'BEO Haveli Block Office',
      deadline: parsed.deadline,
      priority: parsed.priority,
      checklist: parsed.checklist,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ GR parsed by AI and added to school task register!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabaseService>(context);
    final auth = Provider.of<AuthService>(context);

    final filtered = db.tasks.where((t) {
      if (_filter == 'pending') return !t.isCompleted;
      if (_filter == 'completed') return t.isCompleted;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Circulars & Tasks'),
        actions: [
          if (auth.isOfficer || auth.isHeadmaster)
            IconButton(
              icon: const Icon(Icons.auto_awesome_rounded),
              tooltip: 'Parse New Circular (AI)',
              onPressed: () => _scanAndBroadcastCircular(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('All Tasks (${db.tasks.length})', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending (${db.pendingTasksCount})', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Completed (${db.tasks.length - db.pendingTasksCount})', 'completed'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No tasks in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => _openTaskDetails(context, t),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: t.priority == 'urgent' ? AppColors.dangerRedLight : AppColors.warningOrangeLight,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        t.priority.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: t.priority == 'urgent' ? AppColors.dangerRed : AppColors.warningOrange,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Due: ${t.deadline}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: t.isCompleted ? AppColors.successGreen : AppColors.dangerRed,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                const SizedBox(height: 4),
                                Text(
                                  t.summary,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.assignment_outlined, size: 14, color: AppColors.textLight),
                                    const SizedBox(width: 4),
                                    Text('${t.checklist.length} Action Points', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                                    const Spacer(),
                                    Icon(
                                      t.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: t.isCompleted ? AppColors.successGreen : AppColors.textLight,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      t.isCompleted ? 'Complied' : 'Pending',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: t.isCompleted ? AppColors.successGreen : AppColors.warningOrange,
                                      ),
                                    ),
                                  ],
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
      floatingActionButton: (auth.isOfficer || auth.isHeadmaster)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.accentSaffron,
              onPressed: () => _scanAndBroadcastCircular(context),
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              label: const Text('Parse GR Circular', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primaryNavy : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
