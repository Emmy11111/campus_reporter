import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/staff_shell.dart';
import 'screens/shell/student_shell.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const CampusReporterApp());
}

class CampusReporterApp extends StatelessWidget {
  const CampusReporterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<IncidentService>(create: (_) => IncidentService()),
        Provider<StorageService>(create: (_) => StorageService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          lazy: false,
          create: (context) =>
              IncidentProvider(context.read<IncidentService>()),
          update: (context, auth, incidents) {
            incidents!.bind(auth.user);
            return incidents;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Campus Reporter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case AuthStatus.unauthenticated:
        return const LoginScreen();
      case AuthStatus.authenticated:
        return auth.user!.isStaff ? const StaffShell() : const StudentShell();
    }
  }
}