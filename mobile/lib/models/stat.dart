class Stat {
  final int id;
  final int orderIndex;
  final int count;
  final Map<String, dynamic> label;

  Stat({required this.id, required this.orderIndex, required this.count, required this.label});

  factory Stat.fromJson(Map<String, dynamic> json) => Stat(
        id: json['id'] as int,
        orderIndex: json['order_index'] ?? 0,
        count: json['count'] ?? 0,
        label: Map<String, dynamic>.from(json['label'] ?? const {}),
      );
}
