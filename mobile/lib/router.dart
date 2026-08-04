import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import 'public/home_screen.dart';
import 'public/projects_screen.dart';
import 'public/contact_screen.dart';
import 'public/project_detail_screen.dart';
import 'public/description_screen.dart';
import 'admin/admin_entry_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
        GoRoute(path: '/projects', builder: (c, s) => const ProjectsScreen()),
        GoRoute(path: '/contact', builder: (c, s) => const ContactScreen()),
        GoRoute(path: '/admin', builder: (c, s) => const AdminEntryScreen()),
      ],
    ),
    GoRoute(
      path: '/project/:slug',
      builder: (c, s) => ProjectDetailScreen(slug: s.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/project/:slug/description',
      builder: (c, s) => DescriptionScreen(slug: s.pathParameters['slug']!),
    ),
  ],
);
