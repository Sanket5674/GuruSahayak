import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ui/core/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/locale_service.dart';
import 'data/services/local_database_service.dart';
import 'ui/features/auth/login_screen.dart';
import 'ui/features/portal/portal_shell.dart';

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
  final localeService = LocaleService();
  final localDb = LocalDatabaseService();
  await localDb.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<LocaleService>.value(value: localeService),
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
    final locale = Provider.of<LocaleService>(context);

    return MaterialApp(
      title: locale.portalTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const PortalShell() : const LoginScreen();
        },
      ),
    );
  }
}
