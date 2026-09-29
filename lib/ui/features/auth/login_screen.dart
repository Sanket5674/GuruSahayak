import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.teacher;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loginAsDemo(UserRole role) {
    final auth = Provider.of<AuthService>(context, listen: false);
    auth.switchRole(role);
    // Reactive Consumer in main.dart will automatically switch to MainNavigationShell
  }

  void _loginWithForm() {
    final phone = _phoneController.text.trim();
    final name = _nameController.text.trim().isEmpty ? 'Govt Educator' : _nameController.text.trim();

    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.dangerRed,
          content: Text('कृपया १० अंकी वैध मोबाईल नंबर प्रविष्ट करा (Enter 10-digit mobile number)'),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    auth.loginWithPhone(phone, name, _selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Government Tricolor Top Accent Strip
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.saffronOrange,
                          Colors.white,
                          AppColors.successGreen,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // App Logo & Official Branding Header
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryNavy, Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryNavy.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Center(
                    child: Text(
                      'गुरुसहायक',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryNavy,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const Center(
                    child: Text(
                      'GuruSahayak • प्राथमिक शाळा एकात्मिक प्रणाली',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentSaffron,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Unified Offline OS for Govt Primary Schools (ZP / Municipal)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Modern Card Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tab Selector
                        Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            labelColor: AppColors.primaryNavy,
                            unselectedLabelColor: AppColors.textMuted,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.flash_on_rounded, size: 18),
                                text: '१-क्लिक डेमो प्रवेश',
                              ),
                              Tab(
                                icon: Icon(Icons.phone_android_rounded, size: 18),
                                text: 'मोबाईल लॉगिन',
                              ),
                            ],
                          ),
                        ),

                        // Tab Content
                        SizedBox(
                          height: 330,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // Tab 1: 1-Click Demo Roles
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildRoleCard(
                                      title: 'वर्गशिक्षक (Class Teacher)',
                                      subtitle: 'सुरेश पाटील • इयत्ता ४-थी अ • १-टॅप हजेरी व पोषण आहार गणित',
                                      icon: Icons.person_rounded,
                                      accentColor: AppColors.successGreen,
                                      badge: 'Teacher',
                                      role: UserRole.teacher,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildRoleCard(
                                      title: 'मुख्याध्यापक (Headmaster / Admin)',
                                      subtitle: 'सुनिता देशमुख • शाळा साधन संपत्ती व पोषण आहार साठा ऑडिट',
                                      icon: Icons.admin_panel_settings_rounded,
                                      accentColor: AppColors.saffronOrange,
                                      badge: 'Admin',
                                      role: UserRole.headmaster,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildRoleCard(
                                      title: 'शिक्षणाधिकारी (BEO / Officer)',
                                      subtitle: 'डॉ. आनंद कुलकर्णी • हवेली तालुका २४ शाळा व सर्वेक्षण निर्मिती',
                                      icon: Icons.account_balance_rounded,
                                      accentColor: AppColors.primaryNavy,
                                      badge: 'SuperAdmin',
                                      role: UserRole.officer,
                                    ),
                                  ],
                                ),
                              ),

                              // Tab 2: Mobile Number Form
                              SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'मोबाईल नंबर (Mobile Number)',
                                        hintText: '१० अंकी मोबाईल नंबर टाका',
                                        prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'शिक्षकाचे नाव (Full Name)',
                                        hintText: 'उदा. रमेश पाटील',
                                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<UserRole>(
                                      value: _selectedRole,
                                      decoration: const InputDecoration(
                                        labelText: 'पद / हुद्दा (Designation)',
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
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _loginWithForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryNavy,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                                      label: const Text('प्रवेश करा (Enter Portal)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Offline Guarantee Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.successGreen),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '१००% सुरक्षित व इंटरनेटशिवाय चालणारे (Offline SQLite)',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textDark, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badge,
    required UserRole role,
  }) {
    return InkWell(
      onTap: () => _loginAsDemo(role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }
}
