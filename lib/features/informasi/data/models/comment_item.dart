class CommentItem {
  final String id;
  final String authorName;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final int depth; // 1=root, 2=reply, 3=deep reply (flat)
  final List<CommentItem> replies;

  const CommentItem({
    required this.id,
    required this.authorName,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.depth,
    this.replies = const [],
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return CommentItem(
      id: '${json['id']}',
      authorName: author?['name']?.toString() ?? 'User',
      content: json['content']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      depth: json['depth'] as int? ?? 1,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((reply) => CommentItem.fromJson(reply as Map<String, dynamic>))
          .toList(),
    );
  }

  CommentItem copyWith({List<CommentItem>? replies}) {
    return CommentItem(
      id: id,
      authorName: authorName,
      content: content,
      parentId: parentId,
      createdAt: createdAt,
      depth: depth,
      replies: replies ?? this.replies,
    );
  }

  String get initials {
    final parts = authorName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}h yang lalu';
    if (diff.inHours > 0) return '${diff.inHours}j yang lalu';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m yang lalu';
    return 'Baru saja';
  }
}
