class Skill {
  final int id;
  final int orderIndex;
  final String? imageUrl;
  final int percent;
  final Map<String, dynamic> name;

  Skill({required this.id, required this.orderIndex, this.imageUrl, required this.percent, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'] as int,
        orderIndex: json['order_index'] ?? 0,
        imageUrl: json['image_url'] as String?,
        percent: json['percent'] ?? 0,
        name: Map<String, dynamic>.from(json['name'] ?? const {}),
      );
}
