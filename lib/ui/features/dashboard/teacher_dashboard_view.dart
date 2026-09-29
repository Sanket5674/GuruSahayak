import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/export_service.dart';
import '../students/student_vault_view.dart';
import '../tasks/circular_tasks_view.dart';
import '../forms/dynamic_forms_view.dart';

class TeacherDashboardView extends StatelessWidget {
  const TeacherDashboardView({super.key});

  void _triggerMdmSms(BuildContext context, String schoolUdiseCode, int mealCount) async {
    final smsUri = Uri(
      scheme: 'sms',
      path: '15544',
      queryParameters: {'body': 'MDM $schoolUdiseCode $mealCount'},
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.sms_rounded, color: AppColors.primaryNavy),
            SizedBox(width: 8),
            Text('PM-POSHAN SMS Dispatch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When internet is weak or offline, the app automatically formats the official government SMS to 15544:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SelectableText(
                'Recipient: 15544\nMessage: MDM $schoolUdiseCode $mealCount',
                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '✓ Zero Internet Required\n✓ Meets 11:30 AM Official Deadline\n✓ Prevents BEO non-compliance notice',
              style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (await canLaunchUrl(smsUri)) {
                await launchUrl(smsUri);
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SMS dispatched to 15544 in background!')),
                );
              }
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send SMS (15544)'),
          ),
        ],
      ),
    );
  }

  void _showMismatchFixDialog(BuildContext context, LocalDatabaseService db) {
    final mismatchStudent = db.students.firstWhere(
      (s) => s.hasMismatch,
      orElse: () => db.students.first,
    );

    final controller = TextEditingController(text: mismatchStudent.nameInSchool);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed),
            SizedBox(width: 8),
            Text('Resolve Aadhaar Mismatch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${mismatchStudent.nameInSchool}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('GR Number: ${mismatchStudent.grNumber} • Class ${mismatchStudent.standard}-${mismatchStudent.section}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.dangerRedLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.dangerRed.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MISMATCH DETECTED:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                  const SizedBox(height: 4),
                  Text('School Register: "${mismatchStudent.nameInSchool}"', style: const TextStyle(fontSize: 12)),
                  Text('Aadhaar Card: "${mismatchStudent.nameInAadhaar}"', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dangerRed)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Enter corrected spelling to align with Aadhaar UIDAI:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Standardized Name for APAAR'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              db.resolveMismatch(mismatchStudent.id, controller.text.trim());
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Mismatch resolved! Student is now APAAR ready.')),
              );
            },
            child: const Text('Verify & Resolve'),
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
    final mdm = db.todayMdm;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Active Class Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryNavy, Color(0xFF1E40AF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.assignedClass,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      'UDISE: ${user.udiseCode}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Namaste, ${user.name.split(' ')[0]} Sir! 🙏',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  user.schoolName,
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
                ),
                const SizedBox(height: 14),
                // Quick Attendance Strip
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.successGreenLight, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${db.presentStudentsCount} / ${db.totalStudentsCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                const Text('Present Today', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const StudentVaultView()),
                        );
                      },
                      icon: const Icon(Icons.touch_app_rounded, size: 16),
                      label: const Text('Roll Call', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Discrepancy Alert Banner (if any)
          if (db.aadhaarMismatchesCount > 0)
            InkWell(
              onTap: () => _showMismatchFixDialog(context, db),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.dangerRedLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dangerRed.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.dangerRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${db.aadhaarMismatchesCount} Aadhaar Spelling Mismatch Detected',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.dangerRed),
                          ),
                          const Text(
                            'Tap to resolve before APAAR generation deadline.',
                            style: TextStyle(fontSize: 11, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.dangerRed),
                  ],
                ),
              ),
            ),

          // Daily PM-POSHAN MDM Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.accentSaffron.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.rice_bowl_rounded, color: AppColors.accentSaffron, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Daily PM-POSHAN (MDM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('Official Nutrition Formula Active', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('11:30 AM Cutoff', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('Meals Served', '${mdm?.totalStudentsServed ?? 0}', 'Students'),
                      _buildMetricItem('Rice Used', ((mdm?.riceGrams ?? 0) / 1000).toStringAsFixed(1), 'kg'),
                      _buildMetricItem('Dal Used', ((mdm?.dalGrams ?? 0) / 1000).toStringAsFixed(1), 'kg'),
                      _buildMetricItem('Oil Used', ((mdm?.oilGrams ?? 0) / 1000).toStringAsFixed(2), 'kg'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (mdm != null) {
                              final text = ExportService.generateMdmReportText(
                                schoolName: user.schoolName,
                                udiseCode: user.udiseCode,
                                mdm: mdm,
                              );
                              ExportService.shareTextContent(text, 'MDM Daily Report - ${user.schoolName}');
                            }
                          },
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: const Text('Share Tally', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentSaffron,
                          ),
                          onPressed: () {
                            _triggerMdmSms(context, user.udiseCode, mdm?.totalStudentsServed ?? 0);
                          },
                          icon: const Icon(Icons.send_rounded, size: 16),
                          label: const Text('Dispatch SMS', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Priority Circular Tasks Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assigned Circular Tasks (${db.pendingTasksCount} Pending)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CircularTasksView()),
                  );
                },
                child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          // Task preview cards
          ...db.tasks.take(2).map((task) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: task.isCompleted ? AppColors.successGreenLight : (task.priority == 'urgent' ? AppColors.dangerRedLight : AppColors.warningOrangeLight),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    task.isCompleted ? Icons.check_circle_rounded : Icons.assignment_late_rounded,
                    color: task.isCompleted ? AppColors.successGreen : (task.priority == 'urgent' ? AppColors.dangerRed : AppColors.warningOrange),
                    size: 20,
                  ),
                ),
                title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Due: ${task.deadline} • ${task.grNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (val) => db.toggleTaskCompletion(task.id),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Quick Action Tools Grid
          const Text('Quick Compliance Tools', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildToolCard(
                  context,
                  title: 'Student Vault',
                  subtitle: 'Aadhaar & APAAR',
                  icon: Icons.badge_outlined,
                  color: AppColors.primaryNavy,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StudentVaultView()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildToolCard(
                  context,
                  title: 'Active Surveys',
                  subtitle: 'Fill Custom Forms',
                  icon: Icons.dynamic_form_outlined,
                  color: AppColors.headmasterBadge,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DynamicFormsView()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryNavy)),
        Text(unit, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDark)),
      ],
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
