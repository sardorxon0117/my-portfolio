/// Wraps the /api/content response: { hero: {...}, about: {...}, contact: {...}, marquee: {...} }
/// Each section's per-locale fields stay as raw maps — screens pull the field
/// they need via LocaleProvider.field(section['uz']?, ...).
class SiteContent {
  final Map<String, dynamic> hero;
  final Map<String, dynamic> about;
  final Map<String, dynamic> contact;
  final Map<String, dynamic> marquee;

  SiteContent({required this.hero, required this.about, required this.contact, required this.marquee});

  factory SiteContent.fromJson(Map<String, dynamic> json) => SiteContent(
        hero: Map<String, dynamic>.from(json['hero'] ?? const {}),
        about: Map<String, dynamic>.from(json['about'] ?? const {}),
        contact: Map<String, dynamic>.from(json['contact'] ?? const {}),
        marquee: Map<String, dynamic>.from(json['marquee'] ?? const {}),
      );

  factory SiteContent.empty() => SiteContent(hero: const {}, about: const {}, contact: const {}, marquee: const {});
}
