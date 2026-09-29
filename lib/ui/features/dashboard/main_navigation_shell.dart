import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/auth_service.dart';
import 'teacher_dashboard_view.dart';
import 'headmaster_dashboard_view.dart';
import 'officer_dashboard_view.dart';
import '../students/student_vault_view.dart';
import '../tasks/circular_tasks_view.dart';
import '../assets/asset_manager_view.dart';
import '../forms/dynamic_forms_view.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    // Pick active dashboard depending on role
    Widget activeDashboard;
    switch (user.role) {
      case UserRole.teacher:
        activeDashboard = const TeacherDashboardView();
        break;
      case UserRole.headmaster:
        activeDashboard = const HeadmasterDashboardView();
        break;
      case UserRole.officer:
        activeDashboard = const OfficerDashboardView();
        break;
    }

    final pages = [
      activeDashboard,
      const StudentVaultView(),
      const CircularTasksView(),
      const AssetManagerView(),
      const DynamicFormsView(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        elevation: 1,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.saffronOrange, AppColors.primaryNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Text(
                        'गुरुसहायक',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryNavy,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'GuruSahayak',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.roleDisplayName} • ${user.schoolOrJurisdiction}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 1-Click Role Switcher Chip
          InkWell(
            onTap: () => _showRoleSwitchSheet(context, auth),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleBgColor(user.role),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRoleBorderColor(user.role)),
              ),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 16, color: _getRoleTextColor(user.role)),
                  const SizedBox(width: 4),
                  Text(
                    _getShortRoleName(user.role),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getRoleTextColor(user.role),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textMedium, size: 20),
            tooltip: 'Sign Out',
            onPressed: () => auth.logout(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 3,
        indicatorColor: AppColors.primaryNavy.withOpacity(0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryNavy),
            label: 'डॅशबोर्ड',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primaryNavy),
            label: 'विद्यार्थी',
          ),
          NavigationDestination(
            icon: Icon(Icons.rule_folder_outlined),
            selectedIcon: Icon(Icons.rule_folder_rounded, color: AppColors.primaryNavy),
            label: 'शासन निर्णय',
          ),
          NavigationDestination(
            icon: Icon(Icons.domain_outlined),
            selectedIcon: Icon(Icons.domain_rounded, color: AppColors.primaryNavy),
            label: 'शाळा साधन',
          ),
          NavigationDestination(
            icon: Icon(Icons.dynamic_form_outlined),
            selectedIcon: Icon(Icons.dynamic_form_rounded, color: AppColors.primaryNavy),
            label: 'सर्वेक्षणे',
          ),
        ],
      ),
    );
  }

  void _showRoleSwitchSheet(BuildContext context, AuthService auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Switch Government School Hierarchy Role',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 4),
              const Text(
                'Experience GuruSahayak from all levels of the administrative ladder:',
                style: TextStyle(fontSize: 12, color: AppColors.textMedium),
              ),
              const SizedBox(height: 16),
              _buildRoleOption(
                title: 'वर्गशिक्षक (Teacher) - Shri. Anand Rao',
                subtitle: 'Class 4-A Teacher • 1-Tap Attendance, MDM Math & Offline SMS',
                role: UserRole.teacher,
                icon: Icons.person_rounded,
                color: AppColors.successGreen,
                isSelected: auth.currentUser.role == UserRole.teacher,
                onTap: () {
                  auth.switchRole(UserRole.teacher);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildRoleOption(
                title: 'मुख्याध्यापक (Headmaster / Admin) - Smt. Meenakshi Kulkarni',
                subtitle: 'ZP School Head • MDM Stock Audit, Asset Ledger & BEO Requisition',
                role: UserRole.headmaster,
                icon: Icons.admin_panel_settings_rounded,
                color: AppColors.saffronOrange,
                isSelected: auth.currentUser.role == UserRole.headmaster,
                onTap: () {
                  auth.switchRole(UserRole.headmaster);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildRoleOption(
                title: 'शिक्षण अधिकारी (BEO / Officer) - Shri. Vikram Deshmukh',
                subtitle: 'Haveli Block Office • 24 Cluster Schools, Circular Studio & Forms',
                role: UserRole.officer,
                icon: Icons.account_balance_rounded,
                color: AppColors.primaryNavy,
                isSelected: auth.currentUser.role == UserRole.officer,
                onTap: () {
                  auth.switchRole(UserRole.officer);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleOption({
    required String title,
    required String subtitle,
    required UserRole role,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Color _getRoleBgColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return AppColors.successGreen.withOpacity(0.1);
      case UserRole.headmaster:
        return AppColors.saffronOrange.withOpacity(0.12);
      case UserRole.officer:
        return AppColors.primaryNavy.withOpacity(0.1);
    }
  }

  Color _getRoleBorderColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return AppColors.successGreen.withOpacity(0.4);
      case UserRole.headmaster:
        return AppColors.saffronOrange.withOpacity(0.4);
      case UserRole.officer:
        return AppColors.primaryNavy.withOpacity(0.4);
    }
  }

  Color _getRoleTextColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return AppColors.successGreen;
      case UserRole.headmaster:
        return const Color(0xFFC75B00);
      case UserRole.officer:
        return AppColors.primaryNavy;
    }
  }

  String _getShortRoleName(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.headmaster:
        return 'Headmaster';
      case UserRole.officer:
        return 'BEO Officer';
    }
  }
}
