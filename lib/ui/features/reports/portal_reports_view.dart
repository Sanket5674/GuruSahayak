import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/export_service.dart';

class PortalReportsView extends StatelessWidget {
  const PortalReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleService>(context);
    final db = Provider.of<LocalDatabaseService>(context);

    final mdm = db.todayMdm;

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
                locale.navReports,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Header
          Text(
            locale.t('Reports & Analytics (अहवाल आणि विश्लेषण)', 'शासकीय अहवाल आणि विश्लेषण'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // 3 Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildReportCard(
                  title: locale.t('Consolidated Compliance', 'एकत्रित अनुपालन'),
                  value: '94.2%',
                  subtitle: locale.t('12 Schools reporting today', '१२ शाळांचे आजचे अहवाल प्राप्त'),
                  color: AppColors.metricEmerald,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildReportCard(
                  title: locale.t('MDM Meals Served', 'शालेय पोषण आहार वाटप'),
                  value: '${mdm?.totalStudentsServed ?? db.presentStudentsCount}',
                  subtitle: locale.t('Primary students served today', 'प्राथमिक विद्यार्थी लाभार्थ्यांची संख्या'),
                  color: AppColors.metricBlue,
                  icon: Icons.restaurant_menu,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildReportCard(
                  title: locale.t('Aadhaar Seeding Rate', 'आधार जोडणी प्रमाण'),
                  value: '98.6%',
                  subtitle: locale.t('Aadhaar verified with APAAR', 'अपार आयडीसह आधार प्रमाणीकरण'),
                  color: AppColors.metricPurple,
                  icon: Icons.fingerprint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // MDM Ration Calculation Ledger
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.t('PM-POSHAN (MDM) Daily Ration Consumption Ledger', 'शालेय पोषण आहार (MDM) दैनिक धान्य खतावणी'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (mdm != null) {
                          final text = ExportService.generateMdmReportText(
                            schoolName: db.selectedSchool?.nameEn ?? 'ZP High School',
                            udiseCode: db.selectedSchool?.udiseCode ?? '27250100101',
                            mdm: mdm,
                          );
                          _showExportDialog(context, 'MDM Daily Report', text);
                        }
                      },
                      icon: const Icon(Icons.share, size: 16),
                      label: Text(locale.t('Dispatch 15544 SMS', '१५५४४ एसएमएस प्रेषण')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildRationPill('Rice (तांदूळ)', '${((mdm?.riceGrams ?? 0) / 1000).toStringAsFixed(2)} kg', const Color(0xFFEFF6FF)),
                    const SizedBox(width: 12),
                    _buildRationPill('Pulses / Dal (डाळ)', '${((mdm?.dalGrams ?? 0) / 1000).toStringAsFixed(2)} kg', const Color(0xFFECFDF5)),
                    const SizedBox(width: 12),
                    _buildRationPill('Edible Oil (खाद्यतेल)', '${((mdm?.oilGrams ?? 0) / 1000).toStringAsFixed(2)} kg', const Color(0xFFFFFBEB)),
                    const SizedBox(width: 12),
                    _buildRationPill('Eggs / Fruits (अंडी/केळी)', '${mdm?.eggsFruitCount ?? 0} units', const Color(0xFFF5F3FF)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Multi-School Infrastructure Summary Table
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.t('Cluster Schools Performance & Audit Status', 'केंद्र शाळा कामगिरी व तपासणी स्थिती'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                    columns: [
                      const DataColumn(label: Text('UDISE')),
                      DataColumn(label: Text(locale.t('School Name', 'शाळेचे नाव'))),
                      DataColumn(label: Text(locale.t('Total Students', 'विद्यार्थी'))),
                      DataColumn(label: Text(locale.t('Staff', 'शिक्षक'))),
                      DataColumn(label: Text(locale.t('Headmaster', 'मुख्याध्यापक'))),
                      DataColumn(label: Text(locale.t('Audit Status', 'तपासणी स्थिती'))),
                    ],
                    rows: db.schools.map((s) => DataRow(
                      cells: [
                        DataCell(Text(s.udiseCode, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(s.localizedName(locale.isMarathi))),
                        DataCell(Text('${s.totalStudents}')),
                        DataCell(Text('${s.totalTeachers}')),
                        DataCell(Text(s.headmasterName)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                          ),
                        ),
                      ],
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildRationPill(String title, String qty, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(qty, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(child: Text(content, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}
