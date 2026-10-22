import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/dynamic_form.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';
import 'fill_form_sheet.dart';
import 'create_form_dialog.dart';

class PortalFormsView extends StatefulWidget {
  const PortalFormsView({super.key});

  @override
  State<PortalFormsView> createState() => _PortalFormsViewState();
}

class _PortalFormsViewState extends State<PortalFormsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All Forms', 'Submitted', 'Pending', 'Approved', 'Rejected'];

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
                locale.navForms,
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
                locale.t('Government Forms & Submissions', 'शासकीय अर्ज व फॉर्म'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showNewFormDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(locale.t('+ New Form', '+ नवीन फॉर्म')),
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
                String localizedTab;
                switch (tab) {
                  case 'All Forms':
                    localizedTab = locale.t('All Forms', 'सर्व फॉर्म');
                    break;
                  case 'Submitted':
                    localizedTab = locale.statusSubmitted;
                    break;
                  case 'Pending':
                    localizedTab = locale.statusPending;
                    break;
                  case 'Approved':
                    localizedTab = locale.statusApproved;
                    break;
                  case 'Rejected':
                    localizedTab = locale.statusRejected;
                    break;
                  default:
                    localizedTab = tab;
                }
                return Tab(text: localizedTab);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Tab View Content Container
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final currentTab = _tabs[_tabController.index];
              final allForms = db.forms;

              List<DynamicForm> filtered;
              if (currentTab == 'All Forms') {
                filtered = allForms;
              } else if (currentTab == 'Submitted') {
                filtered = allForms.where((f) => f.status == 'Submitted' || f.isSubmitted).toList();
              } else if (currentTab == 'Pending') {
                filtered = allForms.where((f) => f.status == 'Pending' && !f.isSubmitted).toList();
              } else if (currentTab == 'Approved') {
                filtered = allForms.where((f) => f.status == 'Approved').toList();
              } else {
                filtered = allForms.where((f) => f.status == 'Rejected').toList();
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
                            DataColumn(label: Text(locale.t('Form Name', 'फॉर्मचे नाव'))),
                            DataColumn(label: Text(locale.t('Description', 'वर्णन'))),
                            DataColumn(label: Text(locale.t('Last Date', 'शेवटची तारीख'))),
                            DataColumn(label: Text(locale.t('Status', 'स्थिती'))),
                            DataColumn(label: Text(locale.t('Action', 'कृती'))),
                          ],
                          rows: List.generate(filtered.length, (index) {
                            final form = filtered[index];
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(
                                  Text(form.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                DataCell(
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 240),
                                    child: Text(
                                      form.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                                DataCell(Text(form.deadline)),
                                DataCell(_buildStatusBadge(form.status, locale)),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primaryNavyLight),
                                    tooltip: locale.t('View & Review Form', 'फॉर्म पहा व मंजूर करा'),
                                    onPressed: () => _showFormActionDialog(context, form, db, locale),
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
                            locale.t('Showing 1 - ${filtered.length} of 17', '१ - ${filtered.length} एकूण १७ पैकी'),
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          const Text('Page 1 of 4', style: TextStyle(fontSize: 11, color: AppColors.textLight)),
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

  Widget _buildStatusBadge(String status, LocaleService locale) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = locale.statusApproved;
        break;
      case 'submitted':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        label = locale.statusSubmitted;
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = locale.statusRejected;
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = locale.statusPending;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  void _showFormActionDialog(BuildContext context, DynamicForm form, LocalDatabaseService db, LocaleService locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in_outlined, color: AppColors.primaryNavyLight),
            const SizedBox(width: 8),
            Expanded(child: Text(form.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(form.description, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Deadline: ${form.deadline}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  _buildStatusBadge(form.status, locale),
                ],
              ),
              const Divider(height: 24),
              Text(
                locale.t('Questions Checklist', 'प्रश्नावली यादी'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              ...form.questions.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                    const SizedBox(width: 6),
                    Expanded(child: Text(q.label, style: const TextStyle(fontSize: 12))),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(locale.t('Close', 'बंद करा')),
          ),
          if (form.status == 'Pending') ...[
            OutlinedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (bCtx) => FillFormSheet(form: form),
                );
              },
              child: Text(locale.submitForm),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              db.updateFormStatus(form.id, 'Approved');
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.successGreen,
                  content: Text(locale.t('Form Approved Successfully!', 'फॉर्म मंजूर करण्यात आला!')),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
            child: Text(locale.approve),
          ),
          ElevatedButton(
            onPressed: () {
              db.updateFormStatus(form.id, 'Rejected');
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, foregroundColor: Colors.white),
            child: Text(locale.reject),
          ),
        ],
      ),
    );
  }

  void _showNewFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const CreateFormDialog(),
    );
  }
}
