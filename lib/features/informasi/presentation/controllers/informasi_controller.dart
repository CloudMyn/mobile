import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/services/informasi_service.dart';
import '../../data/models/comment_item.dart';
import '../../data/models/informasi_category.dart';
import '../../data/models/informasi_item.dart';

class InformasiController extends GetxController {
  InformasiController({required InformasiService service}) : _service = service;

  final InformasiService _service;
  final items = <InformasiItem>[].obs;
  final categories = <InformasiCategory>[].obs;
  final commentsMap = <String, List<CommentItem>>{}.obs;
  final selectedCategoryId = Rx<String?>(null);
  final dateRange = Rx<DateTimeRange?>(null);
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  final commentsCurrentPage = <String, int>{}.obs;
  final commentsHasMore = <String, bool>{}.obs;
  final isCommentsLoadingMap = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  List<InformasiItem> get pinnedItems =>
      items.where((i) => i.isPinned).take(2).toList();

  List<InformasiItem> get filteredItems {
    var result = items.where((i) => !i.isPinned).toList();
    if (selectedCategoryId.value != null) {
      result = result.where((i) => i.categoryId == selectedCategoryId.value).toList();
    }
    if (dateRange.value != null) {
      final range = dateRange.value!;
      result = result
          .where((i) =>
              !i.publishedAt.isBefore(range.start) &&
              !i.publishedAt.isAfter(range.end))
          .toList();
    }
    return result;
  }

  void selectCategory(String? id) {
    selectedCategoryId.value = id;
    items.refresh();
  }

  void applyDateRange(DateTimeRange? range) {
    dateRange.value = range;
    items.refresh();
  }

  void resetFilters() {
    selectedCategoryId.value = null;
    dateRange.value = null;
    items.refresh();
  }

  List<CommentItem> commentsFor(String articleId) =>
      commentsMap[articleId] ?? [];

  int totalComments(String articleId) {
    return (commentsMap[articleId] ?? []).length;
  }

  Future<void> addComment(
    String articleId,
    String content,
    String authorName, {
    String? parentId,
    int parentDepth = 0,
  }) async {
    try {
      final articleSlug = items
              .firstWhereOrNull((item) => item.id == articleId)
              ?.slug ??
          '';
      final newComment = await _service.addComment(
        articleId: articleId,
        articleSlug: articleSlug,
        content: content,
        parentId: parentId,
      );
      
      final currentComments = commentsMap[articleId] ?? [];
      int insertIdx = currentComments.length;
      if (parentId != null) {
         // Find the last comment that belongs to the same parent chain to append after it,
         // but a simple insert after parent works as a quick optimistic UI update.
         final parentIdx = currentComments.indexWhere((c) => c.id == parentId);
         if (parentIdx != -1) {
            insertIdx = parentIdx + 1;
         }
      }
      currentComments.insert(insertIdx, newComment);
      commentsMap[articleId] = [...currentComments];

      final index = items.indexWhere((item) => item.id == articleId);
      if (index >= 0) {
        final old = items[index];
        items[index] = InformasiItem(
          id: old.id,
          slug: old.slug,
          title: old.title,
          content: old.content,
          categoryId: old.categoryId,
          author: old.author,
          imageUrl: old.imageUrl,
          isPinned: old.isPinned,
          publishedAt: old.publishedAt,
          tags: old.tags,
          commentCount: old.commentCount + 1, // increment count
          viewCount: old.viewCount,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar('Komentar gagal', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _service.fetchFeed();
      categories.assignAll(result.categories);
      items.assignAll([...result.pinned, ...result.items]);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments(String articleSlug, String articleId) async {
    isCommentsLoadingMap[articleId] = true;
    try {
      final comments = await _service.fetchComments(articleSlug, page: 1);
      commentsMap[articleId] = comments;
      commentsCurrentPage[articleId] = 1;
      commentsHasMore[articleId] = comments.length >= 15;
    } on ApiException catch (e) {
      Get.snackbar('Gagal memuat komentar', e.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCommentsLoadingMap[articleId] = false;
    }
  }

  Future<void> loadMoreComments(String articleSlug, String articleId) async {
    if (isCommentsLoadingMap[articleId] == true || commentsHasMore[articleId] == false) return;
    
    isCommentsLoadingMap[articleId] = true;
    try {
      final nextPage = (commentsCurrentPage[articleId] ?? 1) + 1;
      final newComments = await _service.fetchComments(articleSlug, page: nextPage);
      
      final currentList = commentsMap[articleId] ?? [];
      commentsMap[articleId] = [...currentList, ...newComments];
      commentsCurrentPage[articleId] = nextPage;
      commentsHasMore[articleId] = newComments.length >= 15;
    } on ApiException catch (e) {
      Get.snackbar('Gagal memuat komentar tambahan', e.message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isCommentsLoadingMap[articleId] = false;
    }
  }
}

