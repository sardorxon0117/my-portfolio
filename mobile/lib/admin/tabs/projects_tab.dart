import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/portfolio_repository.dart';
import '../../core/app_data.dart';
import '../../models/project.dart';
import '../admin_widgets.dart';
import 'project_editor_screen.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  List<Project>? _all;
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
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _openEditor([Project? project]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ProjectEditorScreen(project: project)),
    );
    if (saved == true) {
      _load();
      if (mounted) context.read<AppData>().load();
    }
  }

  Future<void> _delete(Project p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Loyihani o'chirish"),
        content: Text("'${p.slug}' rostdan ham o'chirilsinmi?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("O'chirish")),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<PortfolioRepository>().deleteProject(p.id);
      setState(() => _all!.removeWhere((x) => x.id == p.id));
      if (mounted) context.read<AppData>().load();
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _all?.where((p) {
      if (_term.isEmpty) return true;
      final title = (p.title['uz'] ?? '').toString().toLowerCase();
      return p.slug.toLowerCase().contains(_term) || title.contains(_term);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(controller: _searchCtrl, decoration: const InputDecoration(hintText: 'Loyihalarni qidirish...', prefixIcon: Icon(Icons.search_rounded))),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => _openEditor(), child: const Text('+ Yangi')),
            ],
          ),
        ),
        Expanded(
          child: filtered == null
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(child: Text('Hech narsa topilmadi.'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final p = filtered[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: p.imageUrl != null
                                    ? CachedNetworkImage(imageUrl: p.imageUrl!, fit: BoxFit.cover)
                                    : const Icon(Icons.storefront_rounded),
                              ),
                            ),
                            title: Text(p.title['uz'] ?? p.slug, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(p.slug + (p.featured ? ' · ⭐ bosh sahifada' : '')),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _openEditor(p)),
                                IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _delete(p)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
