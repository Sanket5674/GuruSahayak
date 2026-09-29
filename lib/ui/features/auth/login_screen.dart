import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/auth_service.dart';
import '../dashboard/main_navigation_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.teacher;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _loginAsDemo(UserRole role) {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.switchRole(role);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  void _loginWithForm() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim().isEmpty ? 'Govt Educator' : _nameController.text.trim();

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    auth.loginWithPhone(phone, name, _selectedRole);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // App Brand Header
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNavy.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'GuruSahayak',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'गुरुसहायक • प्राथमिक शिक्षण कार्यप्रणाली',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentSaffron,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'All-in-One Offline OS for Government Primary Schools',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // 1-Click Instant Evaluation Demo Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flash_on_rounded, color: AppColors.accentSaffron, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '1-Click Demo Evaluation',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose a role to experience its dedicated workflow immediately:',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    _buildDemoRoleButton(
                      title: 'Class Teacher (वर्गशिक्षक)',
                      subtitle: 'Suresh Patil • 1-Tap MDM & Student Vault',
                      icon: Icons.person_rounded,
                      color: AppColors.teacherBadge,
                      role: UserRole.teacher,
                    ),
                    const SizedBox(height: 8),
                    _buildDemoRoleButton(
                      title: 'Headmaster (मुख्याध्यापक)',
                      subtitle: 'Sunita Deshmukh • School Assets & MDM Stock',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.headmasterBadge,
                      role: UserRole.headmaster,
                    ),
                    const SizedBox(height: 8),
                    _buildDemoRoleButton(
                      title: 'Cluster / BEO Officer (शिक्षणाधिकारी)',
                      subtitle: 'Dr. Anand Kulkarni • 24 Schools & Survey Builder',
                      icon: Icons.account_balance_rounded,
                      color: AppColors.officerBadge,
                      role: UserRole.officer,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.cardBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OR LOGIN WITH MOBILE', style: TextStyle(fontSize: 11, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                  ),
                  const Expanded(child: Divider(color: AppColors.cardBorder)),
                ],
              ),
              const SizedBox(height: 18),

              // Mobile Phone Entry
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number (मोबाईल नंबर)',
                  hintText: 'Enter 10-digit registered number',
                  prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Educator Name (नाव)',
                  hintText: 'e.g. Ramesh Patil',
                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Designation / Role (पद)',
                  prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                ),
                items: UserRole.values.map((r) {
                  return DropdownMenuItem(
                    value: r,
                    child: Text(r.displayName, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRole = val);
                },
              ),
              const SizedBox(height: 18),

              ElevatedButton.icon(
                onPressed: _loginWithForm,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Proceed to School Portal'),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '🔒 100% Offline Capable • Local Encrypted Storage',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required UserRole role,
  }) {
    return InkWell(
      onTap: () => _loginAsDemo(role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
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
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
