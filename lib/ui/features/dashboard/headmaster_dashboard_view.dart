import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/models/school_asset.dart';
import '../assets/asset_manager_view.dart';
import '../tasks/circular_tasks_view.dart';

class HeadmasterDashboardView extends StatelessWidget {
  const HeadmasterDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final db = Provider.of<LocalDatabaseService>(context);
    final user = auth.currentUser;

    final damagedAssets = db.assets.where((a) => a.condition == AssetCondition.damaged).length;
    final minorIssueAssets = db.assets.where((a) => a.condition == AssetCondition.minorIssue).length;
    final workingAssets = db.assets.where((a) => a.condition == AssetCondition.working).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headmaster Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.headmasterBadge, Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.headmasterBadge.withOpacity(0.3),
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
                      child: const Text('School Administrator (मुख्याध्यापक)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    Text('UDISE: ${user.udiseCode}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.schoolName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('${user.clusterName} • ${user.blockTaluka}, ${user.district}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildHeaderMetric('142', 'Total Enrolled'),
                    _buildHeaderDivider(),
                    _buildHeaderMetric('136', 'Present Today'),
                    _buildHeaderDivider(),
                    _buildHeaderMetric('95.7%', 'Attendance'),
                    _buildHeaderDivider(),
                    _buildHeaderMetric('6', 'Staff Teachers'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // MDM Grain Stock & Ration Ledger Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.inventory_2_rounded, color: AppColors.accentSaffron, size: 20),
                          SizedBox(width: 8),
                          Text('MDM Grain Stock & Ration Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreenLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Stock Sufficient', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(child: _buildStockMeter('Rice (तांदूळ)', 120, 200, 'kg', '11 days left')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStockMeter('Dal (मूग डाळ)', 45, 80, 'kg', '14 days left')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildStockMeter('Oil (तेल)', 18, 30, 'Ltr', '16 days left')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✓ Formal grain replenishment indent submitted to Haveli Block godown!')),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 16),
                      label: const Text('Request Monthly Grain Quota from BEO'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // School Assets & Infrastructure Audit
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.domain_verification_rounded, color: AppColors.primaryNavy, size: 20),
                          SizedBox(width: 8),
                          Text('School Infrastructure & Assets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AssetManagerView()),
                          );
                        },
                        child: const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildAssetPill('Functional', workingAssets, AppColors.successGreen, AppColors.successGreenLight),
                      const SizedBox(width: 8),
                      _buildAssetPill('Needs Repair', minorIssueAssets, AppColors.warningOrange, AppColors.warningOrangeLight),
                      const SizedBox(width: 8),
                      _buildAssetPill('Damaged', damagedAssets, AppColors.dangerRed, AppColors.dangerRedLight),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (damagedAssets > 0)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRedLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_rounded, color: AppColors.dangerRed, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Rooftop 3kW Solar Power Inverter marked Damaged. Action required.',
                              style: TextStyle(fontSize: 11, color: AppColors.dangerRed, fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AssetManagerView()),
                              );
                            },
                            child: const Text('View', style: TextStyle(fontSize: 11, color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Staff Circular Tasks Compliance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Staff Task Delegations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CircularTasksView()),
                          );
                        },
                        child: const Text('View Tasks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildStaffTaskRow('Class 4 (Suresh Patil)', 'APAAR Parent Consent', '32 / 40 Verified (80%)', 0.8),
                  const SizedBox(height: 10),
                  _buildStaffTaskRow('Class 3 (Deepak Kulkarni)', 'NIPUN FLN Reading Entry', 'All Completed (100%)', 1.0),
                  const SizedBox(height: 10),
                  _buildStaffTaskRow('Class 2 (Pooja Shinde)', 'Free Uniform DBT Bank Check', '18 / 24 Verified (75%)', 0.75),
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
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 9.5), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Container(height: 20, width: 1, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildStockMeter(String label, double current, double max, String unit, String remark) {
    final progress = current / max;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${current.toInt()} $unit', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.cardBorder,
              color: progress < 0.3 ? AppColors.dangerRed : AppColors.successGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(remark, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildAssetPill(String label, int count, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffTaskRow(String teacher, String task, String progressText, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(teacher, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
            Text(progressText, style: TextStyle(fontSize: 10.5, color: val == 1.0 ? AppColors.successGreen : AppColors.warningOrange, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(task, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: val,
            minHeight: 4,
            backgroundColor: AppColors.cardBorder,
            color: val == 1.0 ? AppColors.successGreen : AppColors.accentSaffron,
          ),
        ),
      ],
    );
  }
}
