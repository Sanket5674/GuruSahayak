import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';
import 'portal_dashboard_view.dart';
import '../teachers/teacher_management_view.dart';
import '../students/portal_student_management_view.dart';
import '../forms/portal_forms_view.dart';
import '../tasks/portal_tasks_view.dart';
import '../reports/portal_reports_view.dart';
import '../tasks/circular_tasks_view.dart';
import '../assets/asset_manager_view.dart';
import '../students/student_vault_view.dart';
import '../forms/dynamic_forms_view.dart';

class _PortalNavDestination {
  final String id;
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;
  final int? badgeCount;

  const _PortalNavDestination({
    required this.id,
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.page,
    this.badgeCount,
  });
}

class PortalShell extends StatefulWidget {
  const PortalShell({super.key});

  @override
  State<PortalShell> createState() => _PortalShellState();
}

class _PortalShellState extends State<PortalShell> {
  int _selectedNavIndex = 0;

  void _navigateToIndex(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  List<_PortalNavDestination> _getRoleDestinations(
    UserRole role,
    LocaleService locale,
    LocalDatabaseService db,
    AuthService auth,
  ) {
    switch (role) {
      case UserRole.teacher:
        return [
          _PortalNavDestination(
            id: 'dashboard',
            title: locale.navClassroomDashboard,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            page: PortalDashboardView(onNavigateToTab: _navigateToIndex),
          ),
          _PortalNavDestination(
            id: 'attendance',
            title: locale.navDailyAttendance,
            icon: Icons.how_to_reg_outlined,
            activeIcon: Icons.how_to_reg_rounded,
            page: const StudentVaultView(),
          ),
          _PortalNavDestination(
            id: 'students',
            title: locale.navMyStudents,
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            page: const PortalStudentManagementView(),
          ),
          _PortalNavDestination(
            id: 'tasks',
            title: locale.navMyTasks,
            icon: Icons.checklist_rtl_outlined,
            activeIcon: Icons.checklist_rtl_rounded,
            page: const CircularTasksView(),
            badgeCount: db.pendingTasksCount,
          ),
          _PortalNavDestination(
            id: 'surveys',
            title: locale.navClassSurveys,
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            page: const DynamicFormsView(),
          ),
        ];

      case UserRole.headmaster:
        return [
          _PortalNavDestination(
            id: 'dashboard',
            title: locale.navSchoolDashboard,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            page: PortalDashboardView(onNavigateToTab: _navigateToIndex),
          ),
          _PortalNavDestination(
            id: 'students',
            title: locale.navStudents,
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            page: const PortalStudentManagementView(),
          ),
          _PortalNavDestination(
            id: 'teachers',
            title: locale.navSchoolStaff,
            icon: Icons.badge_outlined,
            activeIcon: Icons.badge_rounded,
            page: const TeacherManagementView(),
          ),
          _PortalNavDestination(
            id: 'mdm',
            title: locale.navMdmLedger,
            icon: Icons.restaurant_outlined,
            activeIcon: Icons.restaurant_rounded,
            page: const PortalReportsView(),
          ),
          _PortalNavDestination(
            id: 'tasks',
            title: locale.navTasks,
            icon: Icons.checklist_rtl_outlined,
            activeIcon: Icons.checklist_rtl_rounded,
            page: const PortalTasksView(),
          ),
          _PortalNavDestination(
            id: 'assets',
            title: locale.navSchoolAssets,
            icon: Icons.domain_outlined,
            activeIcon: Icons.domain_rounded,
            page: const AssetManagerView(),
          ),
          _PortalNavDestination(
            id: 'forms',
            title: locale.navForms,
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            page: const PortalFormsView(),
          ),
          _PortalNavDestination(
            id: 'reports',
            title: locale.navSchoolReports,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            page: const PortalReportsView(),
          ),
        ];

      case UserRole.officer:
        return [
          _PortalNavDestination(
            id: 'dashboard',
            title: locale.navTalukaDashboard,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            page: PortalDashboardView(onNavigateToTab: _navigateToIndex),
          ),
          _PortalNavDestination(
            id: 'oversight',
            title: locale.navSchoolOversight,
            icon: Icons.account_balance_outlined,
            activeIcon: Icons.account_balance_rounded,
            page: const PortalReportsView(),
          ),
          _PortalNavDestination(
            id: 'approvals',
            title: locale.navApprovalsSanctions,
            icon: Icons.assignment_turned_in_outlined,
            activeIcon: Icons.assignment_turned_in_rounded,
            page: const PortalFormsView(),
            badgeCount: 5,
          ),
          _PortalNavDestination(
            id: 'reports',
            title: locale.navTalukaReports,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            page: const PortalReportsView(),
          ),
          _PortalNavDestination(
            id: 'directives',
            title: locale.navNotices,
            icon: Icons.feed_outlined,
            activeIcon: Icons.feed_rounded,
            page: const CircularTasksView(),
          ),
          _PortalNavDestination(
            id: 'teachers',
            title: locale.navTeacherDirectory,
            icon: Icons.badge_outlined,
            activeIcon: Icons.badge_rounded,
            page: const TeacherManagementView(),
          ),
        ];

      case UserRole.admin:
        return [
          _PortalNavDestination(
            id: 'dashboard',
            title: locale.navDashboard,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            page: PortalDashboardView(onNavigateToTab: _navigateToIndex),
          ),
          _PortalNavDestination(
            id: 'students',
            title: locale.navStudents,
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups_rounded,
            page: const PortalStudentManagementView(),
          ),
          _PortalNavDestination(
            id: 'teachers',
            title: locale.navTeachers,
            icon: Icons.badge_outlined,
            activeIcon: Icons.badge_rounded,
            page: const TeacherManagementView(),
          ),
          _PortalNavDestination(
            id: 'forms',
            title: locale.navForms,
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            page: const PortalFormsView(),
          ),
          _PortalNavDestination(
            id: 'tasks',
            title: locale.navTasks,
            icon: Icons.checklist_rtl_outlined,
            activeIcon: Icons.checklist_rtl_rounded,
            page: const PortalTasksView(),
          ),
          _PortalNavDestination(
            id: 'reports',
            title: locale.navReports,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart_rounded,
            page: const PortalReportsView(),
          ),
          _PortalNavDestination(
            id: 'notices',
            title: locale.navNotices,
            icon: Icons.feed_outlined,
            activeIcon: Icons.feed_rounded,
            page: const CircularTasksView(),
          ),
          _PortalNavDestination(
            id: 'assets',
            title: locale.navSchoolProfile,
            icon: Icons.domain_outlined,
            activeIcon: Icons.domain_rounded,
            page: const AssetManagerView(),
          ),
          _PortalNavDestination(
            id: 'settings',
            title: locale.navSettings,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            page: _buildSettingsView(context, locale, auth),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final locale = Provider.of<LocaleService>(context);
    final db = Provider.of<LocalDatabaseService>(context);
    final user = auth.currentUser;

    final isWideScreen = MediaQuery.of(context).size.width >= 900;
    final destinations = _getRoleDestinations(user.role, locale, db, auth);

    if (_selectedNavIndex >= destinations.length) {
      _selectedNavIndex = 0;
    }

    final activePage = destinations[_selectedNavIndex].page;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: isWideScreen ? null : Drawer(
        child: _buildSidebarContent(context, locale, auth, db, user, destinations, isDrawer: true),
      ),
      body: Row(
        children: [
          // Persistent Left Navigation Sidebar (Wide Screen)
          if (isWideScreen)
            SizedBox(
              width: 250,
              child: _buildSidebarContent(context, locale, auth, db, user, destinations, isDrawer: false),
            ),

          // Main Workspace Area
          Expanded(
            child: Column(
              children: [
                // Top Global Header Bar
                _buildTopHeaderBar(context, locale, auth, db, user, isWideScreen),

                // Content Page
                Expanded(
                  child: activePage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeaderBar(
    BuildContext context,
    LocaleService locale,
    AuthService auth,
    LocalDatabaseService db,
    UserProfile user,
    bool isWideScreen,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          if (!isWideScreen)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.primaryNavy),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),

          // Portal Breadcrumb / School Context based on Role
          Expanded(
            child: Row(
              children: [
                // For Admin and Officer: interactive Multi-School Switcher Dropdown
                if (user.role == UserRole.admin || user.role == UserRole.officer)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_city_rounded, size: 16, color: AppColors.primaryNavyLight),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: db.selectedSchoolId,
                            isDense: true,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'ALL',
                                child: Text(locale.t('All Schools (12 Schools)', 'सर्व शाळा (१२ शाळा)')),
                              ),
                              ...db.schools.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.localizedName(locale.isMarathi)),
                              )),
                            ],
                            onChanged: (newSchoolId) {
                              if (newSchoolId != null) {
                                db.setSelectedSchool(newSchoolId);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                // For Headmaster: locked school identity
                else if (user.role == UserRole.headmaster)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.school_rounded, size: 16, color: AppColors.primaryNavyLight),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${user.schoolName} (${user.udiseCode})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // For Teacher: locked classroom identity
                else
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryNavyLight.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.class_rounded, size: 16, color: AppColors.primaryNavyLight),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${user.schoolName} · ${user.assignedClass}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Language Switcher Pill (EN | मराठी)
          InkWell(
            onTap: () => locale.toggleLanguage(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EN',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: locale.isEnglish ? FontWeight.w900 : FontWeight.w500,
                      color: locale.isEnglish ? AppColors.primaryNavy : AppColors.textLight,
                    ),
                  ),
                  const Text(' | ', style: TextStyle(color: AppColors.textLight, fontSize: 11)),
                  Text(
                    'मराठी',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: locale.isMarathi ? FontWeight.w900 : FontWeight.w500,
                      color: locale.isMarathi ? AppColors.primaryNavy : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Notification Bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textDark, size: 22),
                tooltip: locale.t('Notifications', 'सूचना'),
                onPressed: () => _showNotificationSnackbar(context, locale),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.dangerRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),

          // User Profile & 1-Click Role Switch Chip
          InkWell(
            onTap: () => _showRoleSwitchSheet(context, auth, locale),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryNavyLight.withOpacity(0.15),
                    child: const Icon(Icons.person, size: 16, color: AppColors.primaryNavyLight),
                  ),
                  if (isWideScreen) ...[
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.name.split(' ').first,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        Text(
                          locale.isMarathi ? user.role.marathiName : user.role.shortName,
                          style: const TextStyle(fontSize: 10, color: AppColors.primaryNavyLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.dangerRed, size: 20),
            tooltip: locale.logout,
            onPressed: () => _confirmLogout(context, auth, locale),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context,
    LocaleService locale,
    AuthService auth,
    LocalDatabaseService db,
    UserProfile user,
    List<_PortalNavDestination> destinations,
    {required bool isDrawer}
  ) {
    return Container(
      color: const Color(0xFF0F172A), // Dark Navy matching mockup
      child: Column(
        children: [
          // Sidebar Branding Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locale.portalShortName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'शासकीय शाळा पोर्टल',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              itemCount: destinations.length,
              itemBuilder: (context, index) {
                final item = destinations[index];
                final isActive = _selectedNavIndex == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: InkWell(
                    onTap: () {
                      _navigateToIndex(index);
                      if (isDrawer) {
                        Navigator.of(context).pop();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? Colors.white : const Color(0xFF94A3B8),
                            size: 19,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isActive ? Colors.white : const Color(0xFFCBD5E1),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentSaffron,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${item.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom User Profile Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF1E293B),
                  child: const Icon(Icons.person, color: Color(0xFF94A3B8), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.split(' ').first,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        locale.t('District Education Office', 'जिल्हा शिक्षण विभाग'),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(BuildContext context, LocaleService locale, AuthService auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                locale.t('Home', 'मुख्य'),
                style: const TextStyle(fontSize: 12, color: AppColors.primaryNavyLight, fontWeight: FontWeight.bold),
              ),
              const Text('  >  ', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              Text(
                locale.navSettings,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            locale.t('Role-Based Access & Permissions Matrix', 'भूमिका-आधारित प्रवेश आणि परवानग्या तक्ता'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
          ),
          const SizedBox(height: 16),

          // Permissions Matrix Table matching reference infographic exactly!
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                columns: [
                  DataColumn(label: Text(locale.t('Feature / Module', 'सुविधा / घटक'))),
                  DataColumn(label: Text(locale.t('Admin', 'प्रशासक'))),
                  DataColumn(label: Text(locale.t('Headmaster', 'मुख्याध्यापक'))),
                  DataColumn(label: Text(locale.t('Teacher', 'वर्गशिक्षक'))),
                  DataColumn(label: Text(locale.t('Officer', 'गटशिक्षणाधिकारी'))),
                ],
                rows: [
                  _buildMatrixRow('View Dashboard', true, true, true, true),
                  _buildMatrixRow('Manage Schools', true, false, false, true),
                  _buildMatrixRow('Student Management', true, true, true, true),
                  _buildMatrixRow('Teacher Management', true, true, false, true),
                  _buildMatrixRow('Government Forms', true, true, true, true),
                  _buildMatrixRow('Task Management', true, true, true, true),
                  _buildMatrixRow('View Reports', true, true, false, true),
                  _buildMatrixRow('Manage Users & Roles', true, false, false, false),
                  _buildMatrixRow('System Settings', true, false, false, false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.check, size: 16, color: Color(0xFF16A34A)),
              const SizedBox(width: 4),
              Text(locale.t('= Allowed', '= परवानगी आहे'), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              const SizedBox(width: 16),
              const Icon(Icons.close, size: 16, color: Color(0xFFDC2626)),
              const SizedBox(width: 4),
              Text(locale.t('= Not Allowed', '= परवानगी नाही'), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  DataRow _buildMatrixRow(String feature, bool admin, bool hm, bool teacher, bool officer) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(_checkOrCross(admin)),
        DataCell(_checkOrCross(hm)),
        DataCell(_checkOrCross(teacher)),
        DataCell(_checkOrCross(officer)),
      ],
    );
  }

  Widget _checkOrCross(bool allowed) {
    return Icon(
      allowed ? Icons.check : Icons.close,
      size: 18,
      color: allowed ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
    );
  }

  void _showNotificationSnackbar(BuildContext context, LocaleService locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locale.t('3 New circulars received from Education Dept.', 'शिक्षण विभागाकडून ३ नवीन परिपत्रके प्राप्त झाली आहेत.')),
        backgroundColor: AppColors.primaryNavy,
      ),
    );
  }

  void _showRoleSwitchSheet(BuildContext context, AuthService auth, LocaleService locale) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.t('Switch Portal Role (1-Click Test)', 'भूमिका बदला (१-क्लिक चाचणी)'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),
            _buildRoleOption(ctx, auth, UserRole.admin, 'Admin (प्रशासक)', 'District Education Officer oversight', Icons.admin_panel_settings),
            _buildRoleOption(ctx, auth, UserRole.officer, 'Officer (गटशिक्षणाधिकारी)', 'Haveli Taluka (12 Schools)', Icons.local_police),
            _buildRoleOption(ctx, auth, UserRole.headmaster, 'Headmaster (मुख्याध्यापक)', 'Z.P. School Kothrud', Icons.school),
            _buildRoleOption(ctx, auth, UserRole.teacher, 'Teacher (वर्गशिक्षक)', 'Class 4-A Educator', Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(BuildContext ctx, AuthService auth, UserRole role, String title, String subtitle, IconData icon) {
    final isCurrent = auth.currentRole == role;
    return ListTile(
      leading: Icon(icon, color: isCurrent ? AppColors.primaryNavyLight : AppColors.textMuted),
      title: Text(title, style: TextStyle(fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      trailing: isCurrent ? const Icon(Icons.check_circle, color: AppColors.successGreen) : null,
      onTap: () {
        auth.switchRole(role);
        setState(() {
          _selectedNavIndex = 0;
        });
        Navigator.of(ctx).pop();
      },
    );
  }

  void _confirmLogout(BuildContext context, AuthService auth, LocaleService locale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.logout),
        content: Text(locale.t('Are you sure you want to log out of the portal?', 'आपण खात्रीने पोर्टलवरून बाहेर पडू इच्छिता का?')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              auth.logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerRed, foregroundColor: Colors.white),
            child: Text(locale.logout),
          ),
        ],
      ),
    );
  }
}
