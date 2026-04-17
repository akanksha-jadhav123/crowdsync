import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/app_data_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => AppDataProvider(apiService)),
      ],
      child: const CrowdSyncApp(),
    ),
  );
}

class CrowdSyncApp extends StatefulWidget {
  const CrowdSyncApp({super.key});

  @override
  State<CrowdSyncApp> createState() => _CrowdSyncAppState();
}

class _CrowdSyncAppState extends State<CrowdSyncApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    await context.read<AuthProvider>().loadSavedAuth();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrowdSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _initialized
          ? Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isAuthenticated) {
                  return const HomeShell();
                }
                return const LoginScreen();
              },
            )
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
