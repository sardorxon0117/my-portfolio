class Project {
  final int id;
  final String slug;
  final int orderIndex;
  final bool featured;
  final int featuredOrder;
  final String? imageUrl;
  final String? logoUrl;
  final List<String> screenshots;
  final String? videoUrl;
  final String? videoPosterUrl;
  final double rating;
  final String link;
  final String githubLink;
  final List<String> tags;
  final Map<String, dynamic> title;
  final Map<String, dynamic> tagline;
  final Map<String, dynamic> description;
  final Map<String, dynamic> category;
  final String authorName;
  final int viewsCount;
  final String createdAt;

  Project({
    required this.id,
    required this.slug,
    required this.orderIndex,
    required this.featured,
    required this.featuredOrder,
    this.imageUrl,
    this.logoUrl,
    required this.screenshots,
    this.videoUrl,
    this.videoPosterUrl,
    required this.rating,
    required this.link,
    required this.githubLink,
    required this.tags,
    required this.title,
    required this.tagline,
    required this.description,
    required this.category,
    required this.authorName,
    required this.viewsCount,
    required this.createdAt,
  });

  // Postgres NUMERIC columns (like `rating`) come back from node-postgres as
  // JSON strings, not numbers, to avoid float precision loss — handle both.
  static double _parseDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      slug: json['slug'] as String,
      orderIndex: json['order_index'] ?? 0,
      featured: json['featured'] ?? false,
      featuredOrder: json['featured_order'] ?? 0,
      imageUrl: json['image_url'] as String?,
      logoUrl: json['logo_url'] as String?,
      screenshots: List<String>.from(json['screenshots'] ?? const []),
      videoUrl: json['video_url'] as String?,
      videoPosterUrl: json['video_poster_url'] as String?,
      rating: _parseDouble(json['rating'], 5.0),
      link: json['link'] ?? '#',
      githubLink: json['github_link'] ?? '#',
      tags: List<String>.from(json['tags'] ?? const []),
      title: Map<String, dynamic>.from(json['title'] ?? const {}),
      tagline: Map<String, dynamic>.from(json['tagline'] ?? const {}),
      description: Map<String, dynamic>.from(json['description'] ?? const {}),
      category: Map<String, dynamic>.from(json['category'] ?? const {}),
      authorName: json['author_name'] ?? 'Sardorxon Valiyev',
      viewsCount: json['views_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
