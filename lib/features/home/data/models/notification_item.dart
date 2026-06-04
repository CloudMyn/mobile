/// Model data untuk satu item notifikasi dari backend.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    required this.href,
    required this.action,
    required this.category,
    required this.icon,
    this.summary,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type;
  final String href;
  final String action;
  final String category;
  final String icon;
  final String? summary;

  String get body => message;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Notifikasi',
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['read'] as bool? ?? false,
      type: json['type'] as String? ?? 'system',
      href: json['href'] as String? ?? '/notifications',
      action: json['action'] as String? ?? 'route',
      category: json['category'] as String? ?? 'system',
      icon: json['icon'] as String? ?? 'lucide:bell',
      summary: json['summary'] as String?,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? type,
    String? href,
    String? action,
    String? category,
    String? icon,
    String? summary,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      href: href ?? this.href,
      action: action ?? this.action,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      summary: summary ?? this.summary,
    );
  }
}
