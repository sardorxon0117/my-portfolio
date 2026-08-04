import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/portfolio_repository.dart';
import '../../core/theme.dart';
import '../../models/project.dart';
import '../widgets/locale_fields_editor.dart';
import '../widgets/upload_picker.dart';
import '../admin_widgets.dart';

class ProjectEditorScreen extends StatefulWidget {
  final Project? project;
  const ProjectEditorScreen({super.key, this.project});

  @override
  State<ProjectEditorScreen> createState() => _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends State<ProjectEditorScreen> {
  final _fieldsKey = GlobalKey<LocaleFieldsEditorState>();
  late final TextEditingController _slugCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _linkCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _authorCtrl;
  late final TextEditingController _tagsCtrl;
  late final TextEditingController _featuredOrderCtrl;
  bool _featured = false;

  String? _bannerUrl;
  String? _logoUrl;
  String? _posterUrl;
  String? _videoUrl;
  late List<String> _screenshots;
  bool _saving = false;
  bool get _isNew => widget.project == null;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _slugCtrl = TextEditingController(text: p?.slug ?? '');
    _ratingCtrl = TextEditingController(text: (p?.rating ?? 5.0).toString());
    _linkCtrl = TextEditingController(text: p?.link ?? '#');
    _githubCtrl = TextEditingController(text: p?.githubLink ?? '#');
    _authorCtrl = TextEditingController(text: p?.authorName ?? 'Sardorxon Valiyev');
    _tagsCtrl = TextEditingController(text: p?.tags.join(', ') ?? '');
    _featuredOrderCtrl = TextEditingController(text: (p?.featuredOrder ?? 0).toString());
    _featured = p?.featured ?? false;
    _bannerUrl = p?.imageUrl;
    _logoUrl = p?.logoUrl;
    _posterUrl = p?.videoPosterUrl;
    _videoUrl = p?.videoUrl;
    _screenshots = [...(p?.screenshots ?? const [])];
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _ratingCtrl.dispose();
    _linkCtrl.dispose();
    _githubCtrl.dispose();
    _authorCtrl.dispose();
    _tagsCtrl.dispose();
    _featuredOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _addScreenshot() async {
    final repo = context.read<PortfolioRepository>();
    String? error;
    final url = await pickAndUploadFile(context, repo: repo, folder: 'screenshots', fileType: FileType.image, onError: (m) => error = m);
    if (!mounted) return;
    if (url != null) {
      setState(() => _screenshots.add(url));
    } else if (error != null) {
      showAdminToast(context, error!, isError: true);
    }
  }

  Future<void> _save() async {
    final slug = _slugCtrl.text.trim();
    if (slug.isEmpty) {
      showAdminToast(context, 'Slug kiritilishi shart.', isError: true);
      return;
    }
    setState(() => _saving = true);
    final repo = context.read<PortfolioRepository>();
    final raw = _fieldsKey.currentState!.getValues();
    final title = {for (final e in raw.entries) e.key: e.value['title'] ?? ''};
    final tagline = {for (final e in raw.entries) e.key: e.value['tagline'] ?? ''};
    final category = {for (final e in raw.entries) e.key: e.value['category'] ?? ''};
    final description = {for (final e in raw.entries) e.key: e.value['description'] ?? ''};

    final payload = {
      'slug': slug,
      'rating': double.tryParse(_ratingCtrl.text) ?? 5.0,
      'link': _linkCtrl.text.trim().isEmpty ? '#' : _linkCtrl.text.trim(),
      'github_link': _githubCtrl.text.trim().isEmpty ? '#' : _githubCtrl.text.trim(),
      'author_name': _authorCtrl.text.trim().isEmpty ? 'Sardorxon Valiyev' : _authorCtrl.text.trim(),
      'tags': _tagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      'image_url': _bannerUrl,
      'logo_url': _logoUrl,
      'video_poster_url': _posterUrl,
      'video_url': _videoUrl,
      'screenshots': _screenshots,
      'title': title,
      'tagline': tagline,
      'category': category,
      'description': description,
    };

    try {
      final saved = _isNew ? await repo.createProject(payload) : await repo.updateProject(widget.project!.id, payload);
      final featuredOrder = int.tryParse(_featuredOrderCtrl.text) ?? 0;
      await repo.setFeatured(saved.id, featured: _featured, featuredOrder: featuredOrder);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showAdminToast(context, e.toString(), isError: true);
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'Yangi loyiha' : 'Loyihani tahrirlash')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminCard(
            title: 'Rasmlar',
            child: Column(
              children: [
                UploadPicker(initialUrl: _bannerUrl, folder: 'projects', fileType: FileType.image, label: "Banner (ro'yxatlarda)", onUploaded: (u) => setState(() => _bannerUrl = u)),
                const SizedBox(height: 14),
                UploadPicker(initialUrl: _logoUrl, folder: 'logos', fileType: FileType.image, label: 'Logo (ichki sahifada)', onUploaded: (u) => setState(() => _logoUrl = u)),
                const SizedBox(height: 14),
                UploadPicker(initialUrl: _posterUrl, folder: 'posters', fileType: FileType.image, label: 'Video uchun banner (ixtiyoriy)', onUploaded: (u) => setState(() => _posterUrl = u)),
              ],
            ),
          ),
          AdminCard(
            title: 'Asosiy maʼlumotlar',
            child: Column(
              children: [
                TextField(controller: _slugCtrl, decoration: const InputDecoration(labelText: 'Slug (masalan: ecommerce)')),
                const SizedBox(height: 10),
                TextField(controller: _ratingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reyting')),
                const SizedBox(height: 10),
                TextField(controller: _linkCtrl, decoration: const InputDecoration(labelText: 'Loyiha havolasi')),
                const SizedBox(height: 10),
                TextField(controller: _githubCtrl, decoration: const InputDecoration(labelText: 'GitHub havolasi')),
                const SizedBox(height: 10),
                TextField(controller: _authorCtrl, decoration: const InputDecoration(labelText: 'Muallif')),
                const SizedBox(height: 10),
                TextField(controller: _tagsCtrl, decoration: const InputDecoration(labelText: 'Texnologiyalar (vergul bilan)')),
              ],
            ),
          ),
          AdminCard(
            title: 'Skrinshotlar',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final url in _screenshots)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(imageUrl: url, width: 72, height: 72, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: -6, right: -6,
                            child: IconButton(
                              icon: const Icon(Icons.cancel_rounded, size: 20, color: AppColors.brown700),
                              onPressed: () => setState(() => _screenshots.remove(url)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlinedButton(onPressed: _addScreenshot, child: const Text("+ Rasm qo'shish")),
              ],
            ),
          ),
          AdminCard(
            title: 'Video',
            child: UploadPicker(
              initialUrl: _videoUrl,
              folder: 'videos',
              fileType: FileType.video,
              label: 'Video (ixtiyoriy, maksimal 150MB)',
              onUploaded: (u) => setState(() => _videoUrl = u),
            ),
          ),
          AdminCard(
            title: 'Tarjimalar',
            child: LocaleFieldsEditor(
              key: _fieldsKey,
              initialValues: {
                for (final l in ['uz', 'uz_cyr', 'en', 'ru'])
                  l: {
                    'title': p?.title[l] ?? '',
                    'tagline': p?.tagline[l] ?? '',
                    'category': p?.category[l] ?? '',
                    'description': p?.description[l] ?? '',
                  },
              },
              fields: const [
                LocaleFieldDef(key: 'title', label: 'Nomi'),
                LocaleFieldDef(key: 'tagline', label: 'Qisqa tavsif'),
                LocaleFieldDef(key: 'category', label: 'Kategoriya'),
                LocaleFieldDef(key: 'description', label: "To'liq tavsif", multiline: true),
              ],
            ),
          ),
          AdminCard(
            title: 'Bosh sahifa',
            child: Row(
              children: [
                Checkbox(value: _featured, onChanged: (v) => setState(() => _featured = v ?? false)),
                const Expanded(child: Text("Bosh sahifada ko'rsatish")),
                SizedBox(
                  width: 70,
                  child: TextField(controller: _featuredOrderCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'tartib')),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Saqlash'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
