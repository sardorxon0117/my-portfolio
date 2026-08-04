import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'core/i18n.dart';

/// Bottom-nav scaffold wrapping Home / Loyihalar / Aloqa / Admin, per the
/// approved plan ("navda admin panel qismi bo'lsin").
class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = ['/', '/projects', '/contact', '/admin'];

  int _indexForLocation(String location) {
    final i = _tabs.indexWhere((t) => location == t || (t != '/' && location.startsWith(t)));
    return i == -1 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i]),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: locale.t('nav_home')),
          BottomNavigationBarItem(icon: const Icon(Icons.apps_rounded), label: locale.t('nav_projects')),
          BottomNavigationBarItem(icon: const Icon(Icons.mail_rounded), label: locale.t('nav_contact')),
          BottomNavigationBarItem(icon: const Icon(Icons.admin_panel_settings_rounded), label: locale.t('admin_nav')),
        ],
      ),
    );
  }
}
