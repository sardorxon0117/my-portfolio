import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../core/portfolio_repository.dart';
import '../models/project.dart';
import '../widgets/star_rating.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String slug;
  const ProjectDetailScreen({super.key, required this.slug});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Project? _project;
  String? _error;
  Map<String, dynamic>? _reviewsData;
  bool _viewTracked = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<PortfolioRepository>();
    try {
      final project = await repo.getProject(widget.slug);
      final reviews = await repo.getReviews(widget.slug);
      if (mounted) setState(() { _project = project; _reviewsData = reviews; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _trackView() async {
    if (_viewTracked) return;
    _viewTracked = true;
    try {
      await context.read<PortfolioRepository>().trackView(widget.slug);
      if (mounted && _project != null) {
        setState(() {
          _project = Project.fromJson({
            ..._projectToJsonLite(_project!),
            'views_count': _project!.viewsCount + 1,
          });
        });
      }
    } catch (_) {}
  }

  Map<String, dynamic> _projectToJsonLite(Project p) => {
        'id': p.id, 'slug': p.slug, 'order_index': p.orderIndex, 'featured': p.featured, 'featured_order': p.featuredOrder,
        'image_url': p.imageUrl, 'logo_url': p.logoUrl, 'screenshots': p.screenshots, 'video_url': p.videoUrl,
        'video_poster_url': p.videoPosterUrl, 'rating': p.rating, 'link': p.link, 'github_link': p.githubLink,
        'tags': p.tags, 'title': p.title, 'tagline': p.tagline, 'description': p.description, 'category': p.category,
        'author_name': p.authorName, 'views_count': p.viewsCount, 'created_at': p.createdAt,
      };

  Future<void> _openLink(String url) async {
    _trackView();
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();

    if (_error != null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(locale.t('error_not_found'))));
    }
    if (_project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final p = _project!;
    final title = p.title[locale.locale] ?? p.title['uz'] ?? p.slug;
    final description = p.description[locale.locale] ?? p.description['uz'] ?? '';
    final average = (_reviewsData?['average'] as num?)?.toDouble() ?? 0;
    final reviewCount = (_reviewsData?['count'] as num?)?.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: (p.logoUrl ?? p.imageUrl) != null
                        ? CachedNetworkImage(imageUrl: (p.logoUrl ?? p.imageUrl)!, fit: BoxFit.cover)
                        : Container(
                            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.brown300, AppColors.brown600])),
                            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(p.authorName, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _MetaItem(value: '${p.viewsCount}', label: locale.t('views_label')),
                const SizedBox(width: 22),
                _MetaItem(value: '${p.tags.length}', label: locale.t('tech_count_label')),
                const SizedBox(width: 22),
                _MetaItem(value: reviewCount > 0 ? '★ ${average.toStringAsFixed(1)}' : '—', label: locale.t('reviews_label')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: () => _openLink(p.link), child: Text(locale.t('view_project_btn'))),
                ),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: () => _openLink(p.githubLink), child: Text(locale.t('github_btn'))),
              ],
            ),
          ),
          if (p.videoUrl != null || p.screenshots.isNotEmpty) ...[
            const SizedBox(height: 22),
            SizedBox(
              height: 240,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (p.videoUrl != null) _VideoTile(project: p),
                  ...p.screenshots.map((url) => Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: CachedNetworkImage(imageUrl: url, width: 155, height: 240, fit: BoxFit.cover),
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locale.t('description'), style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 10),
                Text(
                  description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.7),
                ),
                Builder(builder: (context) {
                  final needsReadMore = description.length > 220;
                  if (!needsReadMore) return const SizedBox.shrink();
                  return TextButton(
                    onPressed: () => context.push('/project/${p.slug}/description'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                    child: Text(locale.t('read_more_btn')),
                  );
                }),
                const SizedBox(height: 22),
                Text(locale.t('technologies'), style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: p.tags
                      .map((tag) => Chip(label: Text(tag), backgroundColor: AppColors.brown200.withValues(alpha: 0.3)))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _ReviewsSection(slug: widget.slug, data: _reviewsData, locale: locale, onSubmitted: _load),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String value;
  final String label;
  const _MetaItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _VideoTile extends StatefulWidget {
  final Project project;
  const _VideoTile({required this.project});

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  @override
  Widget build(BuildContext context) {
    final poster = widget.project.videoPosterUrl ?? widget.project.logoUrl ?? widget.project.imageUrl;
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () => showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (_) => _VideoLightbox(url: widget.project.videoUrl!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 427,
            height: 240,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (poster != null) CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover) else Container(color: Colors.black),
                Container(color: Colors.black26),
                const Center(
                  child: CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.play_arrow_rounded, color: AppColors.brown700, size: 32)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoLightbox extends StatefulWidget {
  final String url;
  const _VideoLightbox({required this.url});

  @override
  State<_VideoLightbox> createState() => _VideoLightboxState();
}

class _VideoLightboxState extends State<_VideoLightbox> {
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: _ready
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            )
          : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Colors.white))),
    );
  }
}

class _ReviewsSection extends StatefulWidget {
  final String slug;
  final Map<String, dynamic>? data;
  final LocaleProvider locale;
  final VoidCallback onSubmitted;
  const _ReviewsSection({required this.slug, required this.data, required this.locale, required this.onSubmitted});

  @override
  State<_ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<_ReviewsSection> {
  final _nameCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  int _rating = 0;
  bool _submitting = false;
  String? _status;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _commentCtrl.text.trim().isEmpty || _rating == 0) {
      setState(() => _status = 'Barcha maydonlarni to\'ldiring va baho tanlang.');
      return;
    }
    setState(() { _submitting = true; _status = null; });
    try {
      await context.read<PortfolioRepository>().submitReview(widget.slug, name: _nameCtrl.text.trim(), rating: _rating, comment: _commentCtrl.text.trim());
      _nameCtrl.clear();
      _commentCtrl.clear();
      setState(() { _rating = 0; _status = widget.locale.t('review_sent'); });
      widget.onSubmitted();
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = (widget.data?['reviews'] as List?) ?? [];
    final average = (widget.data?['average'] as num?)?.toDouble() ?? 0;
    final count = (widget.data?['count'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.locale.t('reviews_heading'), style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          if (count > 0)
            Row(
              children: [
                Text(average.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w800, fontSize: 30, color: AppColors.accent)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRating(rating: average),
                    Text('$count ta fikr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: Theme.of(context).cardColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: StarPicker(value: _rating, onChanged: (v) => setState(() => _rating = v))),
                const SizedBox(height: 8),
                TextField(controller: _nameCtrl, decoration: InputDecoration(hintText: widget.locale.t('review_name_ph'))),
                const SizedBox(height: 10),
                TextField(controller: _commentCtrl, maxLines: 3, decoration: InputDecoration(hintText: widget.locale.t('review_comment_ph'))),
                const SizedBox(height: 10),
                if (_status != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_status!, style: const TextStyle(color: AppColors.accent))),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(widget.locale.t('review_submit')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (reviews.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Center(child: Text(widget.locale.t('reviews_empty'))))
          else
            ...reviews.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Theme.of(context).cardColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                          StarRating(rating: (r['rating'] as num).toDouble(), size: 14),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(r['comment'] ?? ''),
                      if (r['admin_reply'] != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
                            color: AppColors.brown200.withValues(alpha: 0.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.locale.t('admin_reply_label'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.accent)),
                              Text(r['admin_reply']),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
