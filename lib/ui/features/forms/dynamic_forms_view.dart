import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/dynamic_form.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/export_service.dart';
import 'fill_form_sheet.dart';
import 'create_form_dialog.dart';

class DynamicFormsView extends StatelessWidget {
  const DynamicFormsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<LocalDatabaseService>(context);
    final forms = db.forms;

    final isOfficerOrAdmin = auth.currentUser.role == UserRole.officer ||
        auth.currentUser.role == UserRole.headmaster;

    final submittedCount = forms.where((f) => f.isSubmitted).length;
    final pendingCount = forms.length - submittedCount;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.assignment_outlined, color: AppColors.primaryNavy, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'शासकीय तात्पुरती सर्वेक्षणे',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Ad-Hoc Government Field Surveys & Reports',
                              style: TextStyle(fontSize: 12, color: AppColors.textMedium),
                            ),
                          ],
                        ),
                      ),
                      if (isOfficerOrAdmin)
                        ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const CreateFormDialog(),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Survey', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryNavy.withOpacity(0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Required', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                              const SizedBox(height: 2),
                              Text('${forms.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Submitted', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                              const SizedBox(height: 2),
                              Text('$submittedCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: pendingCount > 0 ? AppColors.warningAmber.withOpacity(0.1) : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: pendingCount > 0 ? AppColors.warningAmber.withOpacity(0.3) : AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Pending Action', style: TextStyle(fontSize: 11, color: AppColors.textMedium)),
                              const SizedBox(height: 2),
                              Text('$pendingCount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pendingCount > 0 ? AppColors.warningAmber : AppColors.textMedium)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final form = forms[index];
                  return _buildFormCard(context, form, isOfficerOrAdmin);
                },
                childCount: forms.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, DynamicForm form, bool isOfficerOrAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: form.isSubmitted ? AppColors.successGreen.withOpacity(0.3) : AppColors.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              form.id,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Due: ${form.deadline}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMedium, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        form.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: form.isSubmitted ? AppColors.successGreen.withOpacity(0.12) : AppColors.warningAmber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        form.isSubmitted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                        size: 14,
                        color: form.isSubmitted ? AppColors.successGreen : AppColors.warningAmber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        form.isSubmitted ? 'Submitted' : 'Pending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: form.isSubmitted ? AppColors.successGreen : AppColors.warningAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              form.description,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMedium, height: 1.3),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_outlined, size: 14, color: AppColors.textMedium),
                  const SizedBox(width: 6),
                  Text(
                    'Authority: ${form.createdBy}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMedium),
                  ),
                  const Spacer(),
                  Text(
                    '${form.questions.length} questions',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                  ),
                ],
              ),
            ),
            if (form.isSubmitted && form.responses.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saved Responses (ऑफ़लाइन सुरक्षित):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                    const SizedBox(height: 4),
                    ...form.questions.take(2).map((q) {
                      final val = form.responses[q.id] ?? '—';
                      return Text('• ${q.label}: $val', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textDark));
                    }),
                    if (form.questions.length > 2)
                      Text('+${form.questions.length - 2} more answers recorded', style: const TextStyle(fontSize: 10.5, color: AppColors.textMedium, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => FillFormSheet(form: form),
                      );
                    },
                    icon: Icon(form.isSubmitted ? Icons.edit_note_rounded : Icons.rate_review_outlined, size: 18),
                    label: Text(
                      form.isSubmitted ? 'Edit Response' : 'Fill Survey (प्रश्नावली भरा)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: form.isSubmitted ? AppColors.cardBorder : AppColors.primaryNavy,
                      foregroundColor: form.isSubmitted ? AppColors.textDark : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (form.isSubmitted) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      final buffer = StringBuffer();
                      buffer.writeln('SURVEY REPORT: ${form.title}');
                      buffer.writeln('Issued By: ${form.createdBy}');
                      buffer.writeln('Deadline: ${form.deadline}');
                      buffer.writeln('----------------------------------------');
                      for (var q in form.questions) {
                        buffer.writeln('${q.label}: ${form.responses[q.id] ?? "N/A"}');
                      }
                      buffer.writeln('----------------------------------------');
                      buffer.writeln('Generated via GuruSahayak Mobile App');
                      ExportService.shareTextContent(buffer.toString(), 'Survey Response - ${form.title}');
                    },
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Share', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
