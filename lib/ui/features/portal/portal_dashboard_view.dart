import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/student.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/locale_service.dart';
import '../../../data/services/local_database_service.dart';

class PortalDashboardView extends StatelessWidget {
  final Function(int targetIndex)? onNavigateToTab;

  const PortalDashboardView({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final locale = Provider.of<LocaleService>(context);
    final db = Provider.of<LocalDatabaseService>(context);
    final user = auth.currentUser;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1100;
    final isTablet = screenWidth >= 700 && screenWidth < 1100;

    switch (user.role) {
      case UserRole.teacher:
        return _buildTeacherDashboard(context, locale, db, user, isDesktop, isTablet);
      case UserRole.headmaster:
        return _buildHeadmasterDashboard(context, locale, db, user, isDesktop, isTablet);
      case UserRole.officer:
        return _buildOfficerDashboard(context, locale, db, user, isDesktop, isTablet);
      case UserRole.admin:
        return _buildAdminDashboard(context, locale, db, user, isDesktop, isTablet);
    }
  }

  // =========================================================================
  // 1. CLASS TEACHER DASHBOARD (वर्गशिक्षक - Class 4-A)
  // =========================================================================
  Widget _buildTeacherDashboard(
    BuildContext context,
    LocaleService locale,
    LocalDatabaseService db,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
  ) {
    final classStudents = db.students;
    final presentCount = db.presentStudentsCount;
    final totalCount = db.totalStudentsCount;
    final attendancePct = totalCount > 0 ? ((presentCount / totalCount) * 100).toStringAsFixed(1) : '0';

    final teacherKpis = [
      _KpiData(
        title: locale.classStrength,
        value: '42',
        subtitle: locale.t('Class 4-A Enrolled', 'इयत्ता ४-अ एकूण'),
        icon: Icons.groups_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _KpiData(
        title: locale.presentToday,
        value: '$presentCount / $totalCount',
        subtitle: '$attendancePct% ${locale.t('Attendance', 'उपस्थिती')}',
        icon: Icons.how_to_reg_rounded,
        color: AppColors.metricEmerald,
        bgColor: const Color(0xFFECFDF5),
      ),
      _KpiData(
        title: locale.aadhaarMismatches,
        value: '${db.aadhaarMismatchesCount}',
        subtitle: locale.t('Action Required', 'दुरुस्ती आवश्यक'),
        icon: Icons.warning_amber_rounded,
        color: AppColors.warningOrange,
        bgColor: const Color(0xFFFFF7ED),
      ),
      _KpiData(
        title: locale.assignedDirectives,
        value: '${db.pendingTasksCount}',
        subtitle: locale.t('Tasks Pending', 'प्रलंबित कामे'),
        icon: Icons.checklist_rtl_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Teacher Welcome Banner
          _buildRoleHeader(
            context,
            locale,
            greeting: locale.t(
              'Welcome back, ${user.name.split(' ').first}! Here is your Class 4-A workspace.',
              'नमस्कार, ${user.name.split(' ').first}! हा आपला वर्ग ४-अ डॅशबोर्ड आहे.',
            ),
            badgeTitle: 'Class 4-A · वर्ग ४-अ',
            badgeIcon: Icons.class_rounded,
            badgeColor: AppColors.primaryNavyLight,
          ),
          const SizedBox(height: 18),

          // 4 Teacher KPIs
          _buildKpiMetricsRow(teacherKpis, isDesktop, isTablet),
          const SizedBox(height: 24),

          // Main Layout
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left 65%: 1-Tap Classroom Attendance & Roll Call + Aadhaar Alerts
                Expanded(
                  flex: 65,
                  child: Column(
                    children: [
                      _buildClassroomAttendanceCard(context, locale, db, classStudents),
                      const SizedBox(height: 20),
                      _buildAadhaarDiscrepancyCard(context, locale, db),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right 35%: Teacher Quick Actions + Assigned Tasks
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      _buildTeacherQuickActions(context, locale),
                      const SizedBox(height: 20),
                      _buildTeacherAssignedTasks(context, locale, db),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildClassroomAttendanceCard(context, locale, db, classStudents),
            const SizedBox(height: 18),
            _buildTeacherQuickActions(context, locale),
            const SizedBox(height: 18),
            _buildAadhaarDiscrepancyCard(context, locale, db),
            const SizedBox(height: 18),
            _buildTeacherAssignedTasks(context, locale, db),
          ],
        ],
      ),
    );
  }

  Widget _buildClassroomAttendanceCard(
    BuildContext context,
    LocaleService locale,
    LocalDatabaseService db,
    List<Student> students,
  ) {
    final presentCount = db.presentStudentsCount;
    final totalCount = db.totalStudentsCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.how_to_reg_rounded, color: AppColors.primaryNavyLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.t('Class 4-A Live Attendance', 'वर्ग ४-अ दैनिक हजेरी'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        locale.t('$presentCount Present · ${totalCount - presentCount} Absent', '$presentCount हजर · ${totalCount - presentCount} गैरहजर'),
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => db.markAllAttendance(true),
                    icon: const Icon(Icons.check_circle_outline, size: 14),
                    label: Text(locale.markAllPresent, style: const TextStyle(fontSize: 11.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.successGreen,
                      side: const BorderSide(color: AppColors.successGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => db.markAllAttendance(false),
                    icon: const Icon(Icons.highlight_off, size: 14),
                    label: Text(locale.markAllAbsent, style: const TextStyle(fontSize: 11.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.dangerRed,
                      side: const BorderSide(color: AppColors.dangerRed),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Student Attendance Chips Grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: students.map((std) {
              final isPresent = std.isPresentToday;
              return InkWell(
                onTap: () => db.toggleStudentAttendance(std.id),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isPresent ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPresent ? AppColors.successGreen.withOpacity(0.4) : AppColors.dangerRed.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: isPresent ? AppColors.successGreen : AppColors.dangerRed,
                        child: Text(
                          std.rollNumber,
                          style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        std.nameInSchool.split(' ').take(2).join(' '),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPresent ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 15,
                        color: isPresent ? AppColors.successGreen : AppColors.dangerRed,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Live MDM Tally Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentSaffron.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.restaurant_rounded, color: AppColors.accentSaffron, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    locale.t(
                      'PM-POSHAN (MDM): $presentCount students served · ${(presentCount * 100 / 1000).toStringAsFixed(1)} kg Rice required today.',
                      'माध्यान्ह भोजन: $presentCount विद्यार्थी जेवले · आज ${(presentCount * 100 / 1000).toStringAsFixed(1)} किलो तांदूळ आवश्यक.',
                    ),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAadhaarDiscrepancyCard(BuildContext context, LocaleService locale, LocalDatabaseService db) {
    final mismatches = db.students.where((s) => s.hasMismatch).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: AppColors.warningOrange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.t('Aadhaar Mismatch Alert', 'आधार डेटा तफावत सूचना'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            locale.t('${mismatches.length} students have name spelling mismatches in Class 4-A', 'वर्ग ४-अ मधील ${mismatches.length} विद्यार्थ्यांच्या नावात तफावत आहे'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => onNavigateToTab?.call(2),
                icon: const Icon(Icons.edit_note, size: 16),
                label: Text(locale.t('Resolve in Vault', 'दुरुस्ती करा'), style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warningOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...mismatches.map((std) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(std.nameInSchool, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        'School: ${std.nameInSchool}  vs  Aadhaar: ${std.nameInAadhaar}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.dangerRed),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Mismatch', style: TextStyle(color: AppColors.dangerRed, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTeacherQuickActions(BuildContext context, LocaleService locale) {
    final actions = [
      _ActionTile(
        title: locale.markAttendance,
        icon: Icons.how_to_reg_rounded,
        color: AppColors.metricEmerald,
        bgColor: const Color(0xFFECFDF5),
        tabIndex: 1,
      ),
      _ActionTile(
        title: locale.resolveAadhaar,
        icon: Icons.fingerprint_rounded,
        color: AppColors.warningOrange,
        bgColor: const Color(0xFFFFF7ED),
        tabIndex: 2,
      ),
      _ActionTile(
        title: locale.navMyTasks,
        icon: Icons.assignment_turned_in_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
        tabIndex: 3,
      ),
      _ActionTile(
        title: locale.navClassSurveys,
        icon: Icons.poll_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
        tabIndex: 4,
      ),
    ];

    return _buildActionsContainer(context, locale, actions);
  }

  Widget _buildTeacherAssignedTasks(BuildContext context, LocaleService locale, LocalDatabaseService db) {
    final tasks = db.tasks.take(3).toList();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  locale.navMyTasks,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => onNavigateToTab?.call(3),
                child: Text(locale.viewAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavyLight)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tasks.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  t.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                  color: t.isCompleted ? AppColors.successGreen : AppColors.textLight,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Due: ${t.deadline}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: t.priority == 'high' ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    t.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: t.priority == 'high' ? AppColors.dangerRed : AppColors.accentSaffron,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. HEADMASTER DASHBOARD (मुख्याध्यापक - School Executive)
  // =========================================================================
  Widget _buildHeadmasterDashboard(
    BuildContext context,
    LocaleService locale,
    LocalDatabaseService db,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
  ) {
    final hmKpis = [
      _KpiData(
        title: locale.totalStudents,
        value: '420',
        subtitle: locale.t('All Classes (1 to 7)', 'सर्व वर्ग (१ ते ७)'),
        icon: Icons.groups_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _KpiData(
        title: locale.staffOnDuty,
        value: '24 / 25',
        subtitle: '96.0% ${locale.t('Staff Present', 'शिक्षक उपस्थित')}',
        icon: Icons.badge_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
      ),
      _KpiData(
        title: locale.schoolAttendance,
        value: '395 / 420',
        subtitle: '94.0% ${locale.t('Today\'s Average', 'आजची सरासरी')}',
        icon: Icons.how_to_reg_rounded,
        color: AppColors.metricEmerald,
        bgColor: const Color(0xFFECFDF5),
      ),
      _KpiData(
        title: locale.mdmStatus,
        value: '39.5 kg',
        subtitle: locale.t('Ration Calculated · Ready', 'धान्य मोजले · तयार'),
        icon: Icons.restaurant_rounded,
        color: AppColors.metricAmber,
        bgColor: const Color(0xFFFFFBEB),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HM Welcome Banner
          _buildRoleHeader(
            context,
            locale,
            greeting: locale.t(
              'Welcome, ${user.name.split(' ').first}! School Executive Overview.',
              'नमस्कार, ${user.name.split(' ').first}! शाळा मुख्य व्यवस्थापन कक्ष.',
            ),
            badgeTitle: '${user.schoolName} · Headmaster',
            badgeIcon: Icons.school_rounded,
            badgeColor: AppColors.primaryNavy,
          ),
          const SizedBox(height: 18),

          // 4 HM KPIs
          _buildKpiMetricsRow(hmKpis, isDesktop, isTablet),
          const SizedBox(height: 24),

          // Main Layout
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left 65%: MDM 15544 Dispatch Ledger + Teacher Duty Roster
                Expanded(
                  flex: 65,
                  child: Column(
                    children: [
                      _buildMdmDispatchCard(context, locale, user),
                      const SizedBox(height: 20),
                      _buildSchoolStaffRosterCard(context, locale, db),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right 35%: Headmaster Quick Actions + School Priorities
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      _buildHeadmasterQuickActions(context, locale),
                      const SizedBox(height: 20),
                      _buildSchoolPrioritiesCard(context, locale),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildMdmDispatchCard(context, locale, user),
            const SizedBox(height: 18),
            _buildHeadmasterQuickActions(context, locale),
            const SizedBox(height: 18),
            _buildSchoolStaffRosterCard(context, locale, db),
            const SizedBox(height: 18),
            _buildSchoolPrioritiesCard(context, locale),
          ],
        ],
      ),
    );
  }

  Widget _buildMdmDispatchCard(BuildContext context, LocaleService locale, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.sms_rounded, color: AppColors.accentSaffron, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.t('PM-POSHAN Daily 15544 Dispatch', 'माध्यान्ह भोजन दैनिक १५५४४ अहवाल'),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'School UDISE: ${user.udiseCode} · 395 Meals Served',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showMdmDispatchDialog(context, locale, user.udiseCode, 395),
                icon: const Icon(Icons.send_rounded, size: 14),
                label: Text(locale.dispatchMdmSms, style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily Ration Matrix
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRationPill('Rice (तांदूळ)', '39.5 kg', Icons.grass),
                _buildRationPill('Dal (डाळ)', '7.9 kg', Icons.soup_kitchen),
                _buildRationPill('Oil (तेल)', '1.97 kg', Icons.oil_barrel),
                _buildRationPill('Eggs/Fruit', '395 units', Icons.egg),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SMS Template: MDM ${user.udiseCode} 395 (Cutoff: 11:30 AM · Ready to dispatch)',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRationPill(String name, String qty, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryNavyLight),
        const SizedBox(height: 4),
        Text(qty, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textDark)),
        Text(name, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
      ],
    );
  }

  void _showMdmDispatchDialog(BuildContext context, LocaleService locale, String udise, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.sms_rounded, color: AppColors.primaryNavy),
            const SizedBox(width: 8),
            Text(locale.dispatchMdmSms, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(locale.t('Official PM-POSHAN SMS dispatch to Central IVR:', 'शासकीय माध्यान्ह भोजन एसएमएस:')),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SelectableText(
                'To: 15544\nMessage: MDM $udise $count',
                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(locale.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.successGreen,
                  content: Text('✓ PM-POSHAN SMS dispatched to 15544 successfully!'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
            child: Text(locale.t('Confirm & Send', 'पाठवा')),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolStaffRosterCard(BuildContext context, LocaleService locale, LocalDatabaseService db) {
    final staff = db.teachers.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.navSchoolStaff,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              InkWell(
                onTap: () => onNavigateToTab?.call(2),
                child: Text(locale.viewAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavyLight)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...staff.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryNavyLight.withOpacity(0.12),
                  child: Text(t.name.split(' ').first[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavyLight)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text('${t.designation} · ${t.subject}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: t.status == 'Active' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    t.status == 'Active' ? 'Present' : 'On Leave',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: t.status == 'Active' ? const Color(0xFF166534) : const Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHeadmasterQuickActions(BuildContext context, LocaleService locale) {
    final actions = [
      _ActionTile(
        title: locale.dispatchMdmSms,
        icon: Icons.sms_rounded,
        color: AppColors.successGreen,
        bgColor: const Color(0xFFECFDF5),
        tabIndex: 3,
      ),
      _ActionTile(
        title: locale.navSchoolStaff,
        icon: Icons.badge_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
        tabIndex: 2,
      ),
      _ActionTile(
        title: locale.submitBeoRequisition,
        icon: Icons.build_rounded,
        color: AppColors.warningOrange,
        bgColor: const Color(0xFFFFF7ED),
        tabIndex: 5,
      ),
      _ActionTile(
        title: locale.assignTask,
        icon: Icons.assignment_ind_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
        tabIndex: 4,
      ),
    ];

    return _buildActionsContainer(context, locale, actions);
  }

  Widget _buildSchoolPrioritiesCard(BuildContext context, LocaleService locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.t('Urgent School Priorities', 'महत्त्वाची प्रशासकीय कामे'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 14),
          _buildPriorityTile(
            'Roof Leakage Requisition',
            'Pending BEO Sanction (Room 3)',
            'Action Needed',
            AppColors.dangerRed,
          ),
          const SizedBox(height: 8),
          _buildPriorityTile(
            'UDISE+ Student Validation',
            'Due in 3 days (408/420 done)',
            '97% Complete',
            AppColors.successGreen,
          ),
          const SizedBox(height: 8),
          _buildPriorityTile(
            'APAAR Card Consent Forms',
            'Collect 12 missing signatures',
            'Pending',
            AppColors.accentSaffron,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTile(String title, String subtitle, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. EDUCATION OFFICER / BEO DASHBOARD (शिक्षणाधिकारी - Taluka Jurisdiction)
  // =========================================================================
  Widget _buildOfficerDashboard(
    BuildContext context,
    LocaleService locale,
    LocalDatabaseService db,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
  ) {
    final officerKpis = [
      _KpiData(
        title: locale.monitoredSchools,
        value: '12',
        subtitle: locale.t('Haveli Block Taluka', 'हवेली तालुका'),
        icon: Icons.account_balance_rounded,
        color: AppColors.metricEmerald,
        bgColor: const Color(0xFFECFDF5),
      ),
      _KpiData(
        title: locale.talukaAttendanceRate,
        value: '91.4%',
        subtitle: '4,470 / 4,892 ${locale.t('Students', 'विद्यार्थी')}',
        icon: Icons.trending_up_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _KpiData(
        title: locale.pendingSanctions,
        value: '5',
        subtitle: locale.t('Awaiting Signature', 'स्वाक्षरी प्रलंबित'),
        icon: Icons.assignment_late_rounded,
        color: AppColors.dangerRed,
        bgColor: const Color(0xFFFEF2F2),
      ),
      _KpiData(
        title: locale.mdmReportingCompliance,
        value: '11 / 12',
        subtitle: '91.6% ${locale.t('Schools Reported', 'शाळांनी पाठवले')}',
        icon: Icons.verified_rounded,
        color: AppColors.metricAmber,
        bgColor: const Color(0xFFFFFBEB),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Officer Welcome Banner
          _buildRoleHeader(
            context,
            locale,
            greeting: locale.t(
              'Welcome, Dr. Anand Kulkarni! Haveli Taluka Administrative Dashboard.',
              'नमस्कार, Dr. Anand Kulkarni! हवेली तालुका शाळा तपासणी व नियंत्रण.',
            ),
            badgeTitle: 'Haveli Block · हवेली तालुका',
            badgeIcon: Icons.account_balance_rounded,
            badgeColor: AppColors.accentSaffron,
          ),
          const SizedBox(height: 18),

          // 4 Officer KPIs
          _buildKpiMetricsRow(officerKpis, isDesktop, isTablet),
          const SizedBox(height: 24),

          // Main Layout
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left 65%: School Inspection Ledger + Pending Sanctions Queue
                Expanded(
                  flex: 65,
                  child: Column(
                    children: [
                      _buildTalukaSchoolsInspectionLedger(context, locale, db),
                      const SizedBox(height: 20),
                      _buildPendingSanctionsQueue(context, locale, db),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right 35%: Officer Quick Actions + Compliance Alerts
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      _buildOfficerQuickActions(context, locale),
                      const SizedBox(height: 20),
                      _buildOfficerComplianceAlerts(context, locale),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildTalukaSchoolsInspectionLedger(context, locale, db),
            const SizedBox(height: 18),
            _buildOfficerQuickActions(context, locale),
            const SizedBox(height: 18),
            _buildPendingSanctionsQueue(context, locale, db),
            const SizedBox(height: 18),
            _buildOfficerComplianceAlerts(context, locale),
          ],
        ],
      ),
    );
  }

  Widget _buildTalukaSchoolsInspectionLedger(BuildContext context, LocaleService locale, LocalDatabaseService db) {
    final schools = db.schools.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.navSchoolOversight,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              InkWell(
                onTap: () => onNavigateToTab?.call(1),
                child: Text(locale.viewAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavyLight)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 40,
              dataRowMinHeight: 46,
              dataRowMaxHeight: 52,
              columns: [
                DataColumn(label: Text(locale.t('School Name', 'शाळेचे नाव'), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(locale.t('UDISE', 'युडायस'), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(locale.t('Attendance', 'हजेरी'), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(locale.t('MDM 15544', 'भोजन SMS'), style: const TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text(locale.t('Action', 'कृती'), style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: schools.map((s) {
                return DataRow(cells: [
                  DataCell(Text(s.localizedName(locale.isMarathi), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5))),
                  DataCell(Text(s.udiseCode, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('94.2%', style: TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataCell(
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 14, color: AppColors.successGreen),
                        SizedBox(width: 4),
                        Text('Done', style: TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  DataCell(
                    OutlinedButton(
                      onPressed: () => onNavigateToTab?.call(1),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(locale.inspectSchoolAction, style: const TextStyle(fontSize: 11)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSanctionsQueue(BuildContext context, LocaleService locale, LocalDatabaseService db) {
    final pendingForms = db.forms.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.t('Requisitions Awaiting Sanction', 'मंजुरी प्रलंबित मागणी अर्ज'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              InkWell(
                onTap: () => onNavigateToTab?.call(2),
                child: Text(locale.viewAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryNavyLight)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...pendingForms.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                      Text('By: ${f.createdBy} · Status: ${f.status}', style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => db.updateFormStatus(f.id, 'Approved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(locale.approve, style: const TextStyle(fontSize: 11)),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: () => db.updateFormStatus(f.id, 'Rejected'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerRed,
                    side: const BorderSide(color: AppColors.dangerRed),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: Text(locale.reject, style: const TextStyle(fontSize: 11)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildOfficerQuickActions(BuildContext context, LocaleService locale) {
    final actions = [
      _ActionTile(
        title: locale.issueCircularDirective,
        icon: Icons.campaign_rounded,
        color: AppColors.primaryNavyLight,
        bgColor: const Color(0xFFEFF6FF),
        tabIndex: 4,
      ),
      _ActionTile(
        title: locale.navApprovalsSanctions,
        icon: Icons.verified_user_rounded,
        color: AppColors.successGreen,
        bgColor: const Color(0xFFECFDF5),
        tabIndex: 2,
      ),
      _ActionTile(
        title: locale.inspectSchoolAction,
        icon: Icons.checklist_rounded,
        color: AppColors.accentSaffron,
        bgColor: const Color(0xFFFFFBEB),
        tabIndex: 1,
      ),
      _ActionTile(
        title: locale.downloadTalukaCsv,
        icon: Icons.file_download_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
        tabIndex: 3,
      ),
    ];

    return _buildActionsContainer(context, locale, actions);
  }

  Widget _buildOfficerComplianceAlerts(BuildContext context, LocaleService locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.t('Taluka Compliance Alerts', 'तालुका नियम पूर्तता सूचना'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 14),
          _buildPriorityTile(
            'MDM Non-Reporting (Past 11:30 AM)',
            'ZP Girls School Wadgaon has not sent SMS',
            'Action Required',
            AppColors.dangerRed,
          ),
          const SizedBox(height: 8),
          _buildPriorityTile(
            'Annual UDISE+ Audit',
            '3 schools pending certification',
            'Due Tomorrow',
            AppColors.warningOrange,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. SYSTEM ADMINISTRATOR DASHBOARD (प्रशासक - Central Command Center)
  // =========================================================================
  Widget _buildAdminDashboard(
    BuildContext context,
    LocaleService locale,
    LocalDatabaseService db,
    UserProfile user,
    bool isDesktop,
    bool isTablet,
  ) {
    final adminKpis = [
      _KpiData(
        title: locale.totalSchools,
        value: '${db.totalSchoolsCount}',
        subtitle: locale.t('Active & Syncing', 'सक्रिय व जोडलेल्या'),
        icon: Icons.domain_rounded,
        color: AppColors.metricEmerald,
        bgColor: const Color(0xFFECFDF5),
      ),
      _KpiData(
        title: locale.totalStudents,
        value: '4,892',
        subtitle: locale.t('District Student Database', 'जिल्हा विद्यार्थी डेटा'),
        icon: Icons.groups_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
      ),
      _KpiData(
        title: locale.totalTeachers,
        value: '312',
        subtitle: locale.t('Sanctioned Staff', 'मंजूर शिक्षक पदे'),
        icon: Icons.badge_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
      ),
      _KpiData(
        title: locale.pendingForms,
        value: '18',
        subtitle: locale.t('Pending System Audit', 'प्रणाली तपासणी'),
        icon: Icons.assignment_rounded,
        color: AppColors.metricAmber,
        bgColor: const Color(0xFFFFFBEB),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Welcome Banner
          _buildRoleHeader(
            context,
            locale,
            greeting: locale.t(
              'Welcome, Administrator! Central Government School Management Command Center.',
              'नमस्कार, प्रशासक! शासकीय शाळा व्यवस्थापन प्रणाली व मुख्य नियंत्रण कक्ष.',
            ),
            badgeTitle: 'Administrator · प्रशासक',
            badgeIcon: Icons.admin_panel_settings_rounded,
            badgeColor: AppColors.primaryNavy,
          ),
          const SizedBox(height: 18),

          // 4 Admin KPIs
          _buildKpiMetricsRow(adminKpis, isDesktop, isTablet),
          const SizedBox(height: 24),

          // Main Layout
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left 65%: Enrollment Chart + System Health Matrix
                Expanded(
                  flex: 65,
                  child: Column(
                    children: [
                      _buildEnrollmentChartCard(context, locale),
                      const SizedBox(height: 20),
                      _buildSystemHealthCard(context, locale),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right 35%: Admin Quick Actions + Recent Audit Log
                Expanded(
                  flex: 35,
                  child: Column(
                    children: [
                      _buildAdminQuickActions(context, locale),
                      const SizedBox(height: 20),
                      _buildAdminAuditLogCard(context, locale),
                    ],
                  ),
                ),
              ],
            )
          else ...[
            _buildEnrollmentChartCard(context, locale),
            const SizedBox(height: 18),
            _buildAdminQuickActions(context, locale),
            const SizedBox(height: 18),
            _buildSystemHealthCard(context, locale),
            const SizedBox(height: 18),
            _buildAdminAuditLogCard(context, locale),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemHealthCard(BuildContext context, LocaleService locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.systemSyncStatus,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 14),
          _buildHealthRow('SQLite Local Storage Engine', 'gurusahayak_v1.db (Healthy)', true),
          const Divider(height: 16),
          _buildHealthRow('UDISE+ Data Compliance', '2026 Government Schema Certified', true),
          const Divider(height: 16),
          _buildHealthRow('Offline Sync Queue', '0 Pending Records · 100% Synced', true),
          const Divider(height: 16),
          _buildHealthRow('Active User Roles', '1 Admin · 4 Officers · 12 HMs · 312 Teachers', true),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String title, String subtitle, bool isHealthy) {
    return Row(
      children: [
        Icon(isHealthy ? Icons.check_circle_rounded : Icons.warning_rounded, color: isHealthy ? AppColors.successGreen : AppColors.dangerRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
              Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isHealthy ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(isHealthy ? 'Operational' : 'Attention', style: TextStyle(color: isHealthy ? const Color(0xFF166534) : AppColors.dangerRed, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildAdminQuickActions(BuildContext context, LocaleService locale) {
    final actions = [
      _ActionTile(
        title: locale.addStudent,
        icon: Icons.person_add_rounded,
        color: AppColors.metricEmerald,
        bgColor: const Color(0xFFECFDF5),
        tabIndex: 1,
      ),
      _ActionTile(
        title: locale.addTeacher,
        icon: Icons.badge_rounded,
        color: AppColors.metricBlue,
        bgColor: const Color(0xFFEFF6FF),
        tabIndex: 2,
      ),
      _ActionTile(
        title: locale.navSettings,
        icon: Icons.tune_rounded,
        color: AppColors.metricPurple,
        bgColor: const Color(0xFFF5F3FF),
        tabIndex: 8,
      ),
      _ActionTile(
        title: locale.navReports,
        icon: Icons.analytics_rounded,
        color: AppColors.accentSaffron,
        bgColor: const Color(0xFFFFFBEB),
        tabIndex: 5,
      ),
    ];

    return _buildActionsContainer(context, locale, actions);
  }

  Widget _buildAdminAuditLogCard(BuildContext context, LocaleService locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.recentActivities,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 14),
          _buildAuditItem('UDISE+ Batch Export generated', 'Haveli Taluka (12 Schools)', '10m ago', Icons.file_download, AppColors.metricBlue),
          _buildAuditItem('New Teacher Account registered', 'M. Shinde (Mathematics)', '45m ago', Icons.person_add, AppColors.metricEmerald),
          _buildAuditItem('System Survey Form Published', 'ICT Infrastructure Audit', '2h ago', Icons.description, AppColors.metricPurple),
        ],
      ),
    );
  }

  Widget _buildAuditItem(String title, String subtitle, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10.5, color: AppColors.textLight)),
        ],
      ),
    );
  }

  // =========================================================================
  // COMMON HELPER WIDGETS
  // =========================================================================
  Widget _buildRoleHeader(
    BuildContext context,
    LocaleService locale, {
    required String greeting,
    required String badgeTitle,
    required IconData badgeIcon,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            greeting,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textMuted),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: badgeColor.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(badgeIcon, size: 15, color: badgeColor),
              const SizedBox(width: 6),
              Text(
                badgeTitle,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKpiMetricsRow(List<_KpiData> cards, bool isDesktop, bool isTablet) {
    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _buildSingleKpiCard(c),
          ),
        )).toList(),
      );
    } else if (isTablet) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: cards.map((c) => _buildSingleKpiCard(c)).toList(),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: cards.map((c) => _buildSingleKpiCard(c)).toList(),
      );
    }
  }

  Widget _buildSingleKpiCard(_KpiData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data.subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    data.subtitle!,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: data.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsContainer(BuildContext context, LocaleService locale, List<_ActionTile> actions) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.quickActions, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: actions.map((act) => InkWell(
              onTap: () => onNavigateToTab?.call(act.tabIndex),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: act.bgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: act.color.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(act.icon, color: act.color, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      act.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: act.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentChartCard(BuildContext context, LocaleService locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Text(
                locale.studentEnrollment,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendIndicator('Boys', locale.boys, const Color(0xFF2563EB)),
                  const SizedBox(width: 14),
                  _buildLegendIndicator('Girls', locale.girls, const Color(0xFFEC4899)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('2,000', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text('1,500', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text('1,000', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text('500', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      Text('0', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildMonthBarPair('Jan', locale.t('Jan', 'जाने'), 780, 620),
                      _buildMonthBarPair('Feb', locale.t('Feb', 'फेब्रु'), 920, 780),
                      _buildMonthBarPair('Mar', locale.t('Mar', 'मार्च'), 1080, 940),
                      _buildMonthBarPair('Apr', locale.t('Apr', 'एप्रिल'), 1340, 1180),
                      _buildMonthBarPair('May', locale.t('May', 'मे'), 1450, 1260),
                      _buildMonthBarPair('Jun', locale.t('Jun', 'जून'), 1620, 1480),
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

  Widget _buildLegendIndicator(String en, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildMonthBarPair(String enMonth, String localizedMonth, int boysCount, int girlsCount) {
    const double maxHeight = 160.0;
    const double maxVal = 2000.0;

    final double boysHeight = (boysCount / maxVal) * maxHeight;
    final double girlsHeight = (girlsCount / maxVal) * maxHeight;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 12,
              height: boysHeight,
              decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 4),
            Container(
              width: 12,
              height: girlsHeight,
              decoration: BoxDecoration(color: const Color(0xFFEC4899), borderRadius: BorderRadius.circular(3)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(localizedMonth, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      ],
    );
  }
}

class _KpiData {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _KpiData({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class _ActionTile {
  final String title;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final int tabIndex;

  _ActionTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.tabIndex,
  });
}
