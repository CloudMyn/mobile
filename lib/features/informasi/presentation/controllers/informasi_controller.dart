import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/models/comment_item.dart';
import '../../data/models/informasi_category.dart';
import '../../data/models/informasi_item.dart';
import '../../data/services/informasi_service.dart';
import '../../../auth/data/models/user_model.dart';

class InformasiController extends GetxController {
  InformasiController({required InformasiService service}) : _service = service;

  final InformasiService _service;
  final items = <InformasiItem>[].obs;
  final categories = <InformasiCategory>[].obs;
  final detailItems = <String, InformasiItem>{}.obs;
  final relatedItemsMap = <String, List<InformasiItem>>{}.obs;
  final commentsMap = <String, List<CommentItem>>{}.obs;
  final selectedCategoryId = Rx<String?>(null);
  final dateRange = Rx<DateTimeRange?>(null);
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  final commentsCurrentPage = <String, int>{}.obs;
  final commentsLastPage = <String, int>{}.obs;
  final commentsTotalMap = <String, int>{}.obs;
  final commentsErrorMap = <String, String>{}.obs;
  final isCommentsInitialLoadingMap = <String, bool>{}.obs;
  final isCommentsLoadingMoreMap = <String, bool>{}.obs;
  final isCommentSubmittingMap = <String, bool>{}.obs;
  final isDetailLoadingMap = <String, bool>{}.obs;
  final publicProfiles = <String, UserModel>{}.obs;
  final isLoadingPublicProfile = <String, bool>{}.obs;

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
      result = result
          .where((i) => i.categoryId == selectedCategoryId.value)
          .toList();
    }
    if (dateRange.value != null) {
      final range = dateRange.value!;
      result = result
          .where(
            (i) =>
                !i.publishedAt.isBefore(range.start) &&
                !i.publishedAt.isAfter(range.end),
          )
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

  InformasiItem articleFor(String articleId, {InformasiItem? fallback}) {
    return detailItems[articleId] ??
        items.firstWhereOrNull((item) => item.id == articleId) ??
        fallback!;
  }

  List<InformasiItem> relatedItemsFor(String articleId) =>
      relatedItemsMap[articleId] ?? const [];

  List<CommentItem> commentsFor(String articleId) =>
      commentsMap[articleId] ?? const [];

  int totalComments(String articleId, {int fallback = 0}) {
    return commentsTotalMap[articleId] ??
        detailItems[articleId]?.commentCount ??
        items.firstWhereOrNull((item) => item.id == articleId)?.commentCount ??
        fallback;
  }

  bool hasMoreComments(String articleId) {
    final current = commentsCurrentPage[articleId] ?? 0;
    final last = commentsLastPage[articleId] ?? 0;
    return current > 0 && current < last;
  }

  bool isCommentsInitialLoading(String articleId) =>
      isCommentsInitialLoadingMap[articleId] ?? false;

  bool isCommentsLoadingMore(String articleId) =>
      isCommentsLoadingMoreMap[articleId] ?? false;

  String? commentsErrorFor(String articleId) => commentsErrorMap[articleId];

  Future<void> loadData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _service.fetchFeed();
      categories.assignAll(result.categories);

      final seen = <String>{};
      final uniqueList = <InformasiItem>[];
      for (final item in result.pinned) {
        if (seen.add(item.id)) {
          uniqueList.add(item.isPinned ? item : item.copyWith(isPinned: true));
        }
      }
      for (final item in result.items) {
        if (seen.add(item.id)) {
          uniqueList.add(item);
        }
      }
      items.assignAll(uniqueList);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDetail(String slug, String articleId) async {
    if (isDetailLoadingMap[articleId] == true) return;

    isDetailLoadingMap[articleId] = true;
    try {
      final result = await _service.fetchDetail(slug);
      detailItems[articleId] = result.article;
      relatedItemsMap[articleId] = result.relatedItems;
      _upsertArticle(result.article);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      isDetailLoadingMap[articleId] = false;
    }
  }

  Future<void> addComment(
    String articleId,
    String content, {
    String? parentId,
  }) async {
    if (isCommentSubmittingMap[articleId] == true) return;

    isCommentSubmittingMap[articleId] = true;
    try {
      final newComment = await _service.addComment(
        articleId: articleId,
        content: content,
        parentId: parentId,
      );

      final currentComments = List<CommentItem>.from(
        commentsMap[articleId] ?? const [],
      );
      var insertIdx = currentComments.length;
      if (parentId != null) {
        final parentIdx = currentComments.indexWhere((c) => c.id == parentId);
        if (parentIdx != -1) {
          insertIdx = parentIdx + 1;
        }
      }
      currentComments.insert(insertIdx, newComment);
      commentsMap[articleId] = currentComments;
      commentsTotalMap[articleId] = totalComments(articleId) + 1;
      _incrementArticleCommentCount(articleId);
      commentsErrorMap.remove(articleId);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Komentar gagal',
        message: e.message,
        isError: true,
      );
      rethrow;
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Komentar gagal',
        message: e.message,
        isError: true,
      );
      rethrow;
    } finally {
      isCommentSubmittingMap[articleId] = false;
    }
  }

  Future<void> editComment(
    String articleId,
    String commentId,
    String content,
  ) async {
    try {
      final updatedComment = await _service.editComment(
        commentId: commentId,
        content: content,
      );

      final currentComments = List<CommentItem>.from(
        commentsMap[articleId] ?? const [],
      );
      final index = currentComments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        currentComments[index] = currentComments[index].copyWith(
          content: updatedComment.content,
          editedAt: updatedComment.editedAt,
        );
        commentsMap[articleId] = currentComments;
      }
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal mengedit',
        message: e.message,
        isError: true,
      );
      rethrow;
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal mengedit',
        message: e.message,
        isError: true,
      );
      rethrow;
    }
  }

  Future<void> deleteComment(String articleId, String commentId) async {
    try {
      await _service.deleteComment(commentId);

      final currentComments = List<CommentItem>.from(
        commentsMap[articleId] ?? const [],
      );
      final index = currentComments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        // Soft-delete lokal: tandai sebagai terhapus, jangan remove dari list
        // agar sub-komentar tetap tampil
        currentComments[index] = currentComments[index].copyWith(
          isDeleted: true,
          content: '[Komentar ini telah dihapus]',
        );
        commentsMap[articleId] = currentComments;

        // Kurangi count hanya 1 (komentar ini saja, bukan replies)
        commentsTotalMap[articleId] = (commentsTotalMap[articleId] ?? 1) - 1;
        _decrementArticleCommentCount(articleId);
      }
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal menghapus',
        message: e.message,
        isError: true,
      );
      rethrow;
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal menghapus',
        message: e.message,
        isError: true,
      );
      rethrow;
    }
  }

  Future<void> loadComments(String articleSlug, String articleId) async {
    if (isCommentsInitialLoading(articleId)) return;

    isCommentsInitialLoadingMap[articleId] = true;
    commentsErrorMap.remove(articleId);
    try {
      final result = await _service.fetchComments(articleSlug, page: 1);
      commentsMap[articleId] = result.items;
      commentsCurrentPage[articleId] = result.currentPage;
      commentsLastPage[articleId] = result.lastPage;
      commentsTotalMap[articleId] = result.total;
    } on ApiException catch (e) {
      commentsErrorMap[articleId] = e.message;
      AppFeedback.showSnackbar(
        title: 'Gagal memuat komentar',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      commentsErrorMap[articleId] = e.message;
      AppFeedback.showSnackbar(
        title: 'Gagal memuat komentar',
        message: e.message,
        isError: true,
      );
    } finally {
      isCommentsInitialLoadingMap[articleId] = false;
    }
  }

  Future<void> loadMoreComments(String articleSlug, String articleId) async {
    if (isCommentsInitialLoading(articleId) ||
        isCommentsLoadingMore(articleId) ||
        !hasMoreComments(articleId)) {
      return;
    }

    isCommentsLoadingMoreMap[articleId] = true;
    try {
      final nextPage = (commentsCurrentPage[articleId] ?? 1) + 1;
      final result = await _service.fetchComments(articleSlug, page: nextPage);
      final currentList = commentsMap[articleId] ?? const <CommentItem>[];
      commentsMap[articleId] = [...currentList, ...result.items];
      commentsCurrentPage[articleId] = result.currentPage;
      commentsLastPage[articleId] = result.lastPage;
      commentsTotalMap[articleId] = result.total;
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal memuat komentar tambahan',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal memuat komentar tambahan',
        message: e.message,
        isError: true,
      );
    } finally {
      isCommentsLoadingMoreMap[articleId] = false;
    }
  }

  void _upsertArticle(InformasiItem updated) {
    final index = items.indexWhere((item) => item.id == updated.id);
    if (index >= 0) {
      items[index] = updated;
    }
    items.refresh();
  }

  void _incrementArticleCommentCount(String articleId) {
    final current = detailItems[articleId];
    if (current != null) {
      detailItems[articleId] = current.copyWith(
        commentCount: current.commentCount + 1,
      );
    }

    final listIndex = items.indexWhere((item) => item.id == articleId);
    if (listIndex >= 0) {
      items[listIndex] = items[listIndex].copyWith(
        commentCount: items[listIndex].commentCount + 1,
      );
      items.refresh();
    }
  }

  void _decrementArticleCommentCount(String articleId) {
    final current = detailItems[articleId];
    if (current != null && current.commentCount > 0) {
      detailItems[articleId] = current.copyWith(
        commentCount: current.commentCount - 1,
      );
    }

    final listIndex = items.indexWhere((item) => item.id == articleId);
    if (listIndex >= 0 && items[listIndex].commentCount > 0) {
      items[listIndex] = items[listIndex].copyWith(
        commentCount: items[listIndex].commentCount - 1,
      );
      items.refresh();
    }
  }

  Future<UserModel?> getPublicProfile(String userId) async {
    if (publicProfiles.containsKey(userId)) {
      return publicProfiles[userId];
    }
    if (isLoadingPublicProfile[userId] == true) {
      return null;
    }

    isLoadingPublicProfile[userId] = true;
    try {
      final user = await _service.fetchPublicProfile(userId);
      publicProfiles[userId] = user;
      return user;
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal memuat profil',
        message: e.message,
        isError: true,
      );
      return null;
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal memuat profil',
        message: e.message,
        isError: true,
      );
      return null;
    } finally {
      isLoadingPublicProfile[userId] = false;
    }
  }
}
