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
    int count = 0;
    void countRecursive(List<CommentItem> list) {
      count += list.length;
      for (final c in list) {
        countRecursive(c.replies);
      }
    }
    countRecursive(commentsFor(articleId));
    return count;
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
      final comments = await _service.addComment(
        articleId: articleId,
        articleSlug: articleSlug,
        content: content,
        parentId: parentId,
      );
      commentsMap[articleId] = comments;
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
          commentCount: totalComments(articleId),
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
    try {
      final result = await _service.fetchDetail(articleSlug);
      commentsMap[articleId] = result.comments;
    } on ApiException catch (e) {
      Get.snackbar('Gagal memuat komentar', e.message,
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

