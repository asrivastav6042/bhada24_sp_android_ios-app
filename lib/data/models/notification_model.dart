/// Firebase notification model
class NotificationModel {
  final String? id;
  final String? title;
  final String? body;
  final String? message;
  final bool isRead;
  final String? timestamp;
  final int? userId;
  final String? actionUrl;
  final Map<String, dynamic>? data;

  const NotificationModel({
    this.id,
    this.title,
    this.body,
    this.message,
    this.isRead = false,
    this.timestamp,
    this.userId,
    this.actionUrl,
    this.data,
  });

  factory NotificationModel.fromJson(String key, Map<String, dynamic> json) {
    return NotificationModel(
      id: key,
      title: json['title'] as String?,
      body: json['body'] as String?,
      message: json['message'] as String?,
      isRead: json['isRead'] == true,
      timestamp: json['timestamp'] as String?,
      userId: json['userId'] as int?,
      actionUrl: json['actionUrl'] as String? ??
          (json['data'] is Map ? json['data']['actionUrl'] as String? : null),
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }

  String get displayTitle => title ?? 'Notification';
  String get displayBody => body ?? message ?? '';
  bool get hasContent => title != null || body != null || message != null;

  DateTime? get dateTime {
    if (timestamp == null) return null;
    return DateTime.tryParse(timestamp!);
  }
}
