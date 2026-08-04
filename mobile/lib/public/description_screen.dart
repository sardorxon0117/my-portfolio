import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/i18n.dart';
import '../core/portfolio_repository.dart';
import '../models/project.dart';

class DescriptionScreen extends StatefulWidget {
  final String slug;
  const DescriptionScreen({super.key, required this.slug});

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  Project? _project;
  String? _error;

  @override
  void initState() {
    super.initState();
    context.read<PortfolioRepository>().getProject(widget.slug).then(
          (p) => mounted ? setState(() => _project = p) : null,
          onError: (e) => mounted ? setState(() => _error = e.toString()) : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(locale.t('full_description_heading'))),
      body: _error != null
          ? Center(child: Text(locale.t('error_not_found')))
          : _project == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: (_project!.logoUrl ?? _project!.imageUrl) != null
                                ? CachedNetworkImage(imageUrl: (_project!.logoUrl ?? _project!.imageUrl)!, fit: BoxFit.cover)
                                : const Icon(Icons.storefront_rounded),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _project!.title[locale.locale] ?? _project!.title['uz'] ?? _project!.slug,
                            style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _project!.description[locale.locale] ?? _project!.description['uz'] ?? '',
                      style: const TextStyle(height: 1.8, fontSize: 15),
                    ),
                  ],
                ),
    );
  }
}
