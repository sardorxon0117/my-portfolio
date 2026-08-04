class ContactMessage {
  final int id;
  final String name;
  final String email;
  final String subject;
  final String message;
  final bool isRead;
  final String createdAt;

  ContactMessage({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory ContactMessage.fromJson(Map<String, dynamic> json) => ContactMessage(
        id: json['id'] as int,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        subject: json['subject'] ?? '',
        message: json['message'] ?? '',
        isRead: json['is_read'] ?? false,
        createdAt: json['created_at'] ?? '',
      );
}
