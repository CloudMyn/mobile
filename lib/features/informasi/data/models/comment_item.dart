class CommentItem {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final DateTime? editedAt;
  final int depth; // 1=root, 2=reply, 3=deep reply (flat)
  final List<CommentItem> replies;
  final bool isDeleted;

  const CommentItem({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.parentId,
    required this.createdAt,
    this.editedAt,
    required this.depth,
    this.replies = const [],
    this.isDeleted = false,
  });

  factory CommentItem.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    final deleted = json['is_deleted'] as bool? ?? false;
    return CommentItem(
      id: '${json['id']}',
      authorId: '${author?['id'] ?? ''}',
      authorName: author?['name']?.toString() ?? 'User',
      content: json['content']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      editedAt: json['edited_at'] != null ? DateTime.tryParse(json['edited_at'].toString()) : null,
      depth: json['depth'] as int? ?? 1,
      replies: (json['replies'] as List<dynamic>? ?? [])
          .map((reply) => CommentItem.fromJson(reply as Map<String, dynamic>))
          .toList(),
      isDeleted: deleted,
    );
  }

  CommentItem copyWith({
    List<CommentItem>? replies,
    String? content,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return CommentItem(
      id: id,
      authorId: authorId,
      authorName: authorName,
      content: content ?? this.content,
      parentId: parentId,
      createdAt: createdAt,
      editedAt: editedAt ?? this.editedAt,
      depth: depth,
      replies: replies ?? this.replies,
      isDeleted: isDeleted ?? this.isDeleted,
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
