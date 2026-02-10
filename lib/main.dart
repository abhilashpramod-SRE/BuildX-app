import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'repositories/buildx_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/role_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/backend_service.dart';
import 'services/offline_sync_service.dart';
import 'services/pdf_service.dart';
import 'viewmodels/app_view_model.dart';

void main() {
  final syncService = OfflineSyncService();
  final backend = FirebaseBackendService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppViewModel(
        auth: AuthService(),
        repository: BuildXRepository(backend: backend, syncService: syncService),
        pdfService: PdfService(),
      ),
      child: const BuildXApp(),
    ),
  );
}

class BuildXApp extends StatelessWidget {
  const BuildXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildX',
      debugShowCheckedModeBanner: false,
      theme: BuildXTheme.light,
      home: Consumer<AppViewModel>(
        builder: (_, vm, __) {
          if (vm.currentUser == null) {
            return const LoginScreen();
          }
          return const RoleDashboardScreen();
        },
      ),
    );
  }
}
