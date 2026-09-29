import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ui/core/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/local_database_service.dart';
import 'ui/features/auth/login_screen.dart';
import 'ui/features/dashboard/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final authService = AuthService();
  final localDb = LocalDatabaseService();
  await localDb.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<LocalDatabaseService>.value(value: localDb),
      ],
      child: const GuruSahayakApp(),
    ),
  );
}

class GuruSahayakApp extends StatelessWidget {
  const GuruSahayakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'गुरुसहायक | GuruSahayak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const MainNavigationShell() : const LoginScreen();
        },
      ),
    );
  }
}
