import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth_provider.dart';
import 'tabs/content_tab.dart';
import 'tabs/stats_tab.dart';
import 'tabs/skills_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/social_tab.dart';
import 'tabs/reviews_tab.dart';
import 'tabs/messages_tab.dart';

/// Mirrors admin/index.html's sidebar-nav — one tab per admin section.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabLabels = ['Kontent', 'Statistika', "Ko'nikmalar", 'Loyihalar', 'Ijtimoiy', 'Sharhlar', 'Xabarlar'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin panel'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Chiqish',
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabLabels.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ContentTab(),
          StatsTab(),
          SkillsTab(),
          ProjectsTab(),
          SocialTab(),
          ReviewsTab(),
          MessagesTab(),
        ],
      ),
    );
  }
}
