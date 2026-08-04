import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/portfolio_repository.dart';
import '../../models/review.dart';
import '../../widgets/star_rating.dart';
import '../admin_widgets.dart';

class ReviewsTab extends StatefulWidget {
  const ReviewsTab({super.key});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  List<Review>? _reviews;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reviews = await context.read<PortfolioRepository>().getAllReviews();
      if (mounted) setState(() => _reviews = reviews);
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews == null) return const Center(child: CircularProgressIndicator());
    if (_reviews!.isEmpty) return const Center(child: Text("Hozircha sharhlar yo'q."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews!.length,
      itemBuilder: (context, i) {
        final r = _reviews![i];
        return _ReviewCard(
          review: r,
          onDeleted: () => setState(() => _reviews!.removeWhere((x) => x.id == r.id)),
          onReplied: (updated) => setState(() {
            final idx = _reviews!.indexWhere((x) => x.id == r.id);
            _reviews![idx] = updated;
          }),
        );
      },
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback onDeleted;
  final ValueChanged<Review> onReplied;
  const _ReviewCard({required this.review, required this.onDeleted, required this.onReplied});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  late final TextEditingController _replyCtrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _replyCtrl = TextEditingController(text: widget.review.adminReply ?? '');
  }

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _reply() async {
    if (_replyCtrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await context.read<PortfolioRepository>().replyToReview(widget.review.id, _replyCtrl.text.trim());
      widget.onReplied(Review(
        id: widget.review.id, projectId: widget.review.projectId, name: widget.review.name, rating: widget.review.rating,
        comment: widget.review.comment, adminReply: _replyCtrl.text.trim(), repliedAt: DateTime.now().toIso8601String(),
        createdAt: widget.review.createdAt, projectSlug: widget.review.projectSlug, projectTitle: widget.review.projectTitle,
      ));
      if (mounted) showAdminToast(context, 'Javob yuborildi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    try {
      await context.read<PortfolioRepository>().deleteReview(widget.review.id);
      widget.onDeleted();
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    return AdminCard(
      title: r.projectTitle?['uz'] ?? r.projectSlug ?? 'Loyiha',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(r.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              StarRating(rating: r.rating.toDouble(), size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(r.comment),
          const SizedBox(height: 12),
          TextField(controller: _replyCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Javob yozish')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy ? null : _reply,
                  child: _busy ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Javob yozish'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _busy ? null : _delete, child: const Text("O'chirish")),
            ],
          ),
        ],
      ),
    );
  }
}
