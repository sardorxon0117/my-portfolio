class SocialLink {
  final int id;
  final String platform;
  final String url;
  final int orderIndex;

  SocialLink({required this.id, required this.platform, required this.url, required this.orderIndex});

  factory SocialLink.fromJson(Map<String, dynamic> json) => SocialLink(
        id: json['id'] as int,
        platform: json['platform'] ?? '',
        url: json['url'] ?? '',
        orderIndex: json['order_index'] ?? 0,
      );
}
