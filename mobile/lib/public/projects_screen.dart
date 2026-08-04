import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../core/portfolio_repository.dart';
import '../models/project.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project>? _all;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _term = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() => setState(() => _term = _searchCtrl.text.trim().toLowerCase()));
  }

  Future<void> _load() async {
    try {
      final projects = await context.read<PortfolioRepository>().getProjects();
      if (mounted) setState(() => _all = projects);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final filtered = _all?.where((p) {
      if (_term.isEmpty) return true;
      final title = (p.title[locale.locale] ?? p.title['uz'] ?? '').toString().toLowerCase();
      final tagline = (p.tagline[locale.locale] ?? p.tagline['uz'] ?? '').toString().toLowerCase();
      return title.contains(_term) || tagline.contains(_term) || p.slug.toLowerCase().contains(_term);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Text(locale.t('projects_heading'), style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 24)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: locale.t('search_placeholder'),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _error != null
              ? Center(child: Text(_error!))
              : filtered == null
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(child: Text('Hech narsa topilmadi.'))
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            return _GridProjectCard(project: p, locale: locale, onTap: () => context.push('/project/${p.slug}'));
                          },
                        ),
        ),
      ],
    );
  }
}

class _GridProjectCard extends StatelessWidget {
  final Project project;
  final LocaleProvider locale;
  final VoidCallback onTap;
  const _GridProjectCard({required this.project, required this.locale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Theme.of(context).cardColor),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: project.imageUrl != null
                  ? CachedNetworkImage(imageUrl: project.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(
                      decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.brown300, AppColors.brown700])),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                project.title[locale.locale] ?? project.title['uz'] ?? project.slug,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
