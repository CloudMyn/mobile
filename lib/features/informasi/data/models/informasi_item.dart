class InformasiItem {
  final String id;
  final String slug;
  final String title;
  final String content;
  final String categoryId;
  final String author;
  final String? imageUrl;
  final bool isPinned;
  final DateTime publishedAt;
  final List<String> tags;
  final int commentCount;
  final int viewCount;

  const InformasiItem({
    required this.id,
    required this.slug,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.author,
    this.imageUrl,
    this.isPinned = false,
    required this.publishedAt,
    this.tags = const [],
    this.commentCount = 0,
    this.viewCount = 0,
  });

  factory InformasiItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>?;
    final tags = (json['tags'] as List<dynamic>? ?? [])
        .map((tag) => (tag as Map<String, dynamic>)['name']?.toString() ?? '')
        .where((tag) => tag.isNotEmpty)
        .toList();

    return InformasiItem(
      id: '${json['id']}',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: (json['content'] ?? json['content_preview'] ?? '').toString(),
      categoryId: '${json['category_id'] ?? category?['id'] ?? ''}',
      author: json['author_name']?.toString() ??
          (json['author'] as Map<String, dynamic>?)?['name']?.toString() ??
          '',
      imageUrl: json['cover_image_url']?.toString(),
      isPinned: json['is_pinned'] as bool? ?? false,
      publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? '') ??
          DateTime.now(),
      tags: tags,
      commentCount: json['comment_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
    );
  }
}
