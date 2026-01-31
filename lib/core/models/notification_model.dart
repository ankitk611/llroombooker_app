class AppNotification {
  final int notyId;
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.notyId,
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(
    Map<String, dynamic> json, {
    required bool isRead,
  }) {
    return AppNotification(
      notyId: json['notyid'],
      id: json['id'],
      title: json['data']['title'],
      message: json['data']['message'],
      isRead: isRead,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
