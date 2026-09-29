import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/ocr_parser_service.dart';
import '../../../data/models/circular_task.dart';
import '../forms/dynamic_forms_view.dart';
import '../forms/create_form_dialog.dart';

class OfficerDashboardView extends StatelessWidget {
  const OfficerDashboardView({super.key});

  void _showCircularUploadDialog(BuildContext context, LocalDatabaseService db) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.accentSaffron),
            SizedBox(width: 8),
            Text('AI Circular & GR Parser', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload or photograph a Government Resolution (GR) PDF. GuruSahayak AI will extract deadlines, directives, and checklist items automatically:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
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
                  const Text('AI PREVIEW SAMPLE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  const Text('GR-PRE-2026/CR-92', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryNavy)),
                  const Text('Subject: Balvatika & Grade 1 Student Digital Registration Verification', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Deadline: 28 Oct 2026 • Target: All Primary Schools', style: TextStyle(fontSize: 11, color: AppColors.dangerRed)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
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
                const SnackBar(content: Text('✓ GR parsed by AI and broadcast to all 24 schools in cluster!')),
              );
            },
            icon: const Icon(Icons.campaign_rounded, size: 16),
            label: const Text('Parse & Broadcast'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<LocalDatabaseService>(context);
    final user = auth.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Officer Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB45309), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentSaffron.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Education Officer (गटशिक्षणाधिकारी)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Text(user.blockTaluka, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${user.schoolName} • ${user.district}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildHeaderMetric('24', 'Cluster Schools'),
                    _buildHeaderDivider(),
                    _buildHeaderMetric('3,420', 'Total Students'),
                    _buildHeaderDivider(),
                    _buildHeaderMetric('91.6%', 'MDM Reported'),
                    _buildHeaderDivider(),
                    _buildHeaderMetric('2', 'Pending Calls'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compliance & Daily MDM Reporting Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cluster MDM Reporting (Today)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.successGreenLight, borderRadius: BorderRadius.circular(10)),
                        child: const Text('22 / 24 Done', style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 22 / 24,
                      minHeight: 6,
                      backgroundColor: AppColors.cardBorder,
                      color: AppColors.successGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Non-reporting schools alert
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrangeLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warningOrange.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('2 SCHOOLS PENDING REPORT (CUTOFF 11:30 AM):', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.warningOrange)),
                        const SizedBox(height: 6),
                        _buildPendingSchoolItem('Z.P. School Shivane', 'Headmaster: M. Shinde', '+91 98221 44550'),
                        const Divider(height: 12),
                        _buildPendingSchoolItem('Z.P. School Uttamnagar', 'Headmaster: P. Gholap', '+91 94220 11223'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions for Officers
          const Text('Administrative Command Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
          const SizedBox(height: 10),

          // Action 1: Circular Broadcast Studio
          InkWell(
            onTap: () => _showCircularUploadDialog(context, db),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.accentSaffron.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.campaign_rounded, color: AppColors.accentSaffron, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Broadcast New Circular (GR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('AI parses PDF directives & creates tasks for all schools.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Action 2: Dynamic Form Builder
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const CreateFormDialog(),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryNavy.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.dynamic_form_rounded, color: AppColors.primaryNavy, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dynamic Form Builder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Dispatch ad-hoc field surveys to teachers in 60 seconds.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Action 3: View Active Surveys & Exports
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DynamicFormsView()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.headmasterBadge.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.file_download_outlined, color: AppColors.headmasterBadge, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Survey Responses & CSV Export', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Download consolidated Excel reports for BEO audit.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetric(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 9.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Container(height: 20, width: 1, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildPendingSchoolItem(String school, String hm, String phone) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(school, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            Text('$hm • $phone', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Row(
            children: [
              Icon(Icons.phone_rounded, size: 12, color: AppColors.primaryNavy),
              SizedBox(width: 4),
              Text('Call HM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
            ],
          ),
        ),
      ],
    );
  }
}
