import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/circular_task.dart';
import '../../../data/services/local_database_service.dart';

class CircularDetailSheet extends StatefulWidget {
  final CircularTask task;

  const CircularDetailSheet({super.key, required this.task});

  @override
  State<CircularDetailSheet> createState() => _CircularDetailSheetState();
}

class _CircularDetailSheetState extends State<CircularDetailSheet> {
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remarksController.text = widget.task.proofRemarks ?? '';
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabaseService>(context, listen: false);
    final task = widget.task;

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.priority == 'urgent' ? AppColors.dangerRedLight : AppColors.warningOrangeLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: task.priority == 'urgent' ? AppColors.dangerRed : AppColors.warningOrange,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${task.grNumber} • Issued by: ${task.issuedBy}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 12),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('GOVERNMENT DIRECTIVE SUMMARY:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                  const SizedBox(height: 4),
                  Text(task.summary, style: const TextStyle(fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event_rounded, size: 14, color: AppColors.dangerRed),
                      const SizedBox(width: 4),
                      Text('Compliance Deadline: ${task.deadline}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const Text('Action Checklist:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            ...task.checklist.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_box_outlined, size: 16, color: AppColors.primaryNavy),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),

            const SizedBox(height: 14),
            TextField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Proof of Completion / Submission Remarks',
                hintText: 'e.g. Verified 32/40 forms with physical parent signatures',
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: task.isCompleted ? AppColors.textMuted : AppColors.successGreen,
              ),
              onPressed: () {
                db.toggleTaskCompletion(task.id, proofRemarks: _remarksController.text.trim());
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(task.isCompleted ? 'Task marked in progress' : '✓ Task marked completed with compliance proof!')),
                );
              },
              icon: Icon(task.isCompleted ? Icons.undo_rounded : Icons.check_circle_rounded, size: 18),
              label: Text(task.isCompleted ? 'Mark Pending' : 'Submit as Completed'),
            ),
          ],
        ),
      ),
    );
  }
}
