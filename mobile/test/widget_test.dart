import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:sv_portfolio/core/api_client.dart';
import 'package:sv_portfolio/core/auth_storage.dart';
import 'package:sv_portfolio/core/auth_provider.dart';
import 'package:sv_portfolio/core/portfolio_repository.dart';
import 'package:sv_portfolio/core/i18n.dart';
import 'package:sv_portfolio/core/theme_provider.dart';
import 'package:sv_portfolio/core/app_data.dart';
import 'package:sv_portfolio/main.dart';

void main() {
  testWidgets('App builds without throwing', (WidgetTester tester) async {
    final authStorage = AuthStorage();
    final repo = PortfolioRepository(ApiClient(authStorage));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PortfolioRepository>.value(value: repo),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider(authStorage, repo)),
          ChangeNotifierProvider(create: (_) => AppData(repo)),
        ],
        child: const PortfolioApp(),
      ),
    );

    // A single pump (not pumpAndSettle) — the real network calls won't
    // resolve in a widget test, but the app should render its loading state.
    await tester.pump();
    expect(find.byType(PortfolioApp), findsOneWidget);
  });
}
