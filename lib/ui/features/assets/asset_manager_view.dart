import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/school_asset.dart';
import '../../../data/services/local_database_service.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/export_service.dart';
import 'add_asset_dialog.dart';

class AssetManagerView extends StatefulWidget {
  const AssetManagerView({super.key});

  @override
  State<AssetManagerView> createState() => _AssetManagerViewState();
}

class _AssetManagerViewState extends State<AssetManagerView> {
  String _categoryFilter = 'All';

  void _generateRepairLetter(BuildContext context, SchoolAsset asset, String schoolName, String udise) {
    final letterText = '''
To,
The Block Education Officer (BEO),
Haveli Block Education Office, Pune.

Subject: Formal Requisition for Inspection & Repair of School Asset
School: $schoolName (UDISE: $udise)

Respected Sir/Madam,
This is to bring to your urgent notice that the following school infrastructure asset has been inspected and found in DAMAGED / NEED-REPAIR condition:

- Asset Name: ${asset.name}
- Category: ${asset.category}
- Quantity: ${asset.quantity}
- Location: ${asset.location}
- Funding Scheme: ${asset.fundingScheme} (Year: ${asset.purchaseYear})
- Reported Issue: ${asset.remarks.isEmpty ? "Requires immediate technical service or replacement." : asset.remarks}

Kindly sanction technical repair or warranty replacement under Samagra Shiksha school maintenance grant at the earliest.

Yours faithfully,
Headmaster / Mukhyadhyapak,
$schoolName
''';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description_rounded, color: AppColors.primaryNavy),
            SizedBox(width: 8),
            Text('Official Requisition Letter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Generated official government letter ready to share via WhatsApp or Email:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: SelectableText(letterText, style: const TextStyle(fontSize: 11, height: 1.35)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ExportService.shareTextContent(letterText, 'Repair Requisition - ${asset.name}');
            },
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share to BEO Office'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<LocalDatabaseService>(context);
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    final categories = ['All', 'Furniture', 'Electronics', 'Sanitation / Water', 'Sports & Lab'];

    final filtered = db.assets.where((a) {
      if (_categoryFilter == 'All') return true;
      return a.category.toLowerCase().contains(_categoryFilter.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Assets & Infrastructure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Asset Inventory CSV',
            onPressed: () {
              final csv = ExportService.generateAssetsCsv(db.assets);
              ExportService.shareTextContent(csv, 'School_Assets_Audit.csv');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _categoryFilter == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textDark)),
                      selected: isSelected,
                      selectedColor: AppColors.primaryNavy,
                      backgroundColor: AppColors.backgroundLight,
                      onSelected: (val) => setState(() => _categoryFilter = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No assets in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final a = filtered[index];
                      Color statusColor;
                      Color statusBg;
                      IconData statusIcon;

                      switch (a.condition) {
                        case AssetCondition.working:
                          statusColor = AppColors.successGreen;
                          statusBg = AppColors.successGreenLight;
                          statusIcon = Icons.check_circle_rounded;
                          break;
                        case AssetCondition.minorIssue:
                          statusColor = AppColors.warningOrange;
                          statusBg = AppColors.warningOrangeLight;
                          statusIcon = Icons.report_problem_rounded;
                          break;
                        case AssetCondition.damaged:
                          statusColor = AppColors.dangerRed;
                          statusBg = AppColors.dangerRedLight;
                          statusIcon = Icons.cancel_rounded;
                          break;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                                    child: Icon(statusIcon, color: statusColor, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                                        Text('${a.category} • Qty: ${a.quantity} • Year: ${a.purchaseYear}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        Text('Fund: ${a.fundingScheme} • Loc: ${a.location}', style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                                    child: Text(
                                      a.condition.name.toUpperCase(),
                                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                              if (a.remarks.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(a.remarks, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
                                    ],
                                  ),
                                ),
                              ],
                              if (a.condition != AssetCondition.working) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.dangerRed,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    onPressed: () => _generateRepairLetter(context, a, user.schoolName, user.udiseCode),
                                    icon: const Icon(Icons.mail_outline_rounded, size: 15),
                                    label: const Text('Generate Formal BEO Repair Letter', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryNavy,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddAssetDialog(onAdd: (newAsset) => db.addAsset(newAsset)),
          );
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Asset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
