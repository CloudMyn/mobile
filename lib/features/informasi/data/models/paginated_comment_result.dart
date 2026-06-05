import 'comment_item.dart';

class PaginatedCommentResult {
  const PaginatedCommentResult({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final List<CommentItem> items;
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
