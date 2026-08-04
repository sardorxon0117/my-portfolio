import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../core/theme_provider.dart';
import '../core/app_data.dart';
import '../widgets/section_heading.dart';
import '../widgets/hero_typewriter.dart';
import '../widgets/project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final locale = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Column(
      children: [
        _TopBar(locale: locale, themeProvider: themeProvider),
        Expanded(
          child: appData.loading
              ? const Center(child: CircularProgressIndicator())
              : appData.error != null
                  ? _ErrorRetry(message: appData.error!, onRetry: () => context.read<AppData>().load())
                  : RefreshIndicator(
                      onRefresh: () => context.read<AppData>().load(),
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 40),
                        children: [
                          _HeroSection(locale: locale, hero: appData.content.hero),
                          if (appData.stats.isNotEmpty || appData.content.about.isNotEmpty)
                            _AboutSection(locale: locale, about: appData.content.about, stats: appData.stats),
                          if (appData.skills.isNotEmpty) _SkillsSection(locale: locale, skills: appData.skills),
                          if (appData.featuredProjects.isNotEmpty) _FeaturedProjectsSection(locale: locale, projects: appData.featuredProjects),
                          _CtaSection(locale: locale),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final LocaleProvider locale;
  final ThemeProvider themeProvider;
  const _TopBar({required this.locale, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          const Text('SV', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.accent)),
          const Spacer(),
          PopupMenuButton<String>(
            initialValue: locale.locale,
            onSelected: (v) => locale.setLocale(v),
            itemBuilder: (context) => supportedLocales
                .map((l) => PopupMenuItem(value: l, child: Text(localeShortLabels[l] ?? l)))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
              child: Text(localeShortLabels[locale.locale] ?? locale.locale.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
          IconButton(
            onPressed: () => themeProvider.toggle(),
            icon: Icon(themeProvider.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final LocaleProvider locale;
  final Map<String, dynamic> hero;
  const _HeroSection({required this.locale, required this.hero});

  @override
  Widget build(BuildContext context) {
    final localeHero = Map<String, dynamic>.from(hero[locale.locale] ?? hero['uz'] ?? {});
    final eyebrow = localeHero['eyebrow'] as String? ?? '';
    final fullName = (localeHero['name'] as String?) ?? 'Sardorxon Valiyev';
    final role = localeHero['role'] as String? ?? '';
    final text = localeHero['text'] as String? ?? '';
    final parts = fullName.trim().split(' ');
    final lastName = parts.isNotEmpty ? parts.removeLast() : '';
    final firstName = parts.join(' ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(eyebrow.toUpperCase(), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, letterSpacing: 2, fontSize: 12)),
          const SizedBox(height: 12),
          Text(firstName, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w900, fontSize: 40)),
          Text(lastName, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w900, fontSize: 40, color: AppColors.accent)),
          const SizedBox(height: 14),
          HeroTypewriter(rawText: role, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.accent)),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => context.go('/projects'), child: Text(locale.t('cta_projects'))),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: () => context.go('/contact'), child: Text(locale.t('cta_contact'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final LocaleProvider locale;
  final Map<String, dynamic> about;
  final List stats;
  const _AboutSection({required this.locale, required this.about, required this.stats});

  @override
  Widget build(BuildContext context) {
    final localeAbout = Map<String, dynamic>.from(about[locale.locale] ?? about['uz'] ?? {});
    final photoUrl = about['photo_url'] as String?;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(eyebrow: locale.t('about_eyebrow'), heading: locale.t('about_heading')),
          const SizedBox(height: 20),
          if (photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 16),
          Text(localeAbout['paragraph1'] as String? ?? '', style: const TextStyle(height: 1.7)),
          const SizedBox(height: 10),
          Text(localeAbout['paragraph2'] as String? ?? '', style: const TextStyle(height: 1.7)),
          if (stats.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 28,
              runSpacing: 12,
              children: stats.map((s) {
                final label = Map<String, dynamic>.from(s.label);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${s.count}+', style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w800, fontSize: 24, color: AppColors.accent)),
                    Text(locale.field(label), style: const TextStyle(fontSize: 12)),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  final LocaleProvider locale;
  final List skills;
  const _SkillsSection({required this.locale, required this.skills});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(eyebrow: locale.t('skills_eyebrow'), heading: locale.t('skills_heading')),
          const SizedBox(height: 20),
          ...skills.map((skill) {
            final name = Map<String, dynamic>.from(skill.name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  if (skill.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(imageUrl: skill.imageUrl!, width: 36, height: 36, fit: BoxFit.cover),
                    )
                  else
                    Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.brown200, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(locale.field(name), style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${skill.percent}%', style: const TextStyle(fontSize: 12, color: AppColors.accent)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: skill.percent / 100,
                            minHeight: 6,
                            backgroundColor: AppColors.brown200.withValues(alpha: 0.4),
                            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FeaturedProjectsSection extends StatelessWidget {
  final LocaleProvider locale;
  final List projects;
  const _FeaturedProjectsSection({required this.locale, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SectionHeading(eyebrow: locale.t('projects_eyebrow'), heading: locale.t('projects_heading')),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: projects.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final p = projects[i];
                return ProjectCard(project: p, onTap: () => context.push('/project/${p.slug}'));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: TextButton(
              onPressed: () => context.go('/projects'),
              child: Text(locale.t('view_all_projects')),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  final LocaleProvider locale;
  const _CtaSection({required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [AppColors.brown700, AppColors.brown900]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.t('cta_eyebrow').toUpperCase(), style: const TextStyle(color: AppColors.brown200, fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 8),
          Text('${locale.t('cta_title1')} ${locale.t('cta_title2')}',
              style: const TextStyle(color: Colors.white, fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 22)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => context.go('/contact'), child: Text(locale.t('cta_contact_btn'))),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Qayta urinish')),
        ],
      ),
    );
  }
}
