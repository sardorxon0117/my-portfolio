class Review {
  final int id;
  final int projectId;
  final String name;
  final int rating;
  final String comment;
  final String? adminReply;
  final String? repliedAt;
  final String createdAt;
  final String? projectSlug;
  final Map<String, dynamic>? projectTitle;

  Review({
    required this.id,
    required this.projectId,
    required this.name,
    required this.rating,
    required this.comment,
    this.adminReply,
    this.repliedAt,
    required this.createdAt,
    this.projectSlug,
    this.projectTitle,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        projectId: json['project_id'] as int,
        name: json['name'] ?? '',
        rating: json['rating'] ?? 0,
        comment: json['comment'] ?? '',
        adminReply: json['admin_reply'] as String?,
        repliedAt: json['replied_at'] as String?,
        createdAt: json['created_at'] ?? '',
        projectSlug: json['project_slug'] as String?,
        projectTitle: json['project_title'] != null ? Map<String, dynamic>.from(json['project_title']) : null,
      );
}
