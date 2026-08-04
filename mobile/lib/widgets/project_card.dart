import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';
import '../core/i18n.dart';
import '../models/project.dart';

/// Play-Store-style tile: banner image, icon overlapping the bottom-left
/// corner, title + tagline — used on both the Home featured row and the
/// All Projects grid.
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).cardColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: project.imageUrl != null
                  ? CachedNetworkImage(imageUrl: project.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.brown300, AppColors.brown700]),
                      ),
                      child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.title[locale] ?? project.title['uz'] ?? project.slug,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.tagline[locale] ?? project.tagline['uz'] ?? '',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
