import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/auth_storage.dart';
import 'core/auth_provider.dart';
import 'core/portfolio_repository.dart';
import 'core/i18n.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'core/app_data.dart';
import 'router.dart';

void main() {
  final authStorage = AuthStorage();
  final apiClient = ApiClient(authStorage);
  final repo = PortfolioRepository(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<PortfolioRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..load()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authStorage, repo)..bootstrap()),
        ChangeNotifierProvider(create: (_) => AppData(repo)..load()),
      ],
      child: const PortfolioApp(),
    ),
  );
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: 'Sardorxon Valiyev',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.mode,
      routerConfig: appRouter,
    );
  }
}
