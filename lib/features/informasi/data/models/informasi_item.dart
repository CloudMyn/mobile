class InformasiItem {
  final String id;
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
}
