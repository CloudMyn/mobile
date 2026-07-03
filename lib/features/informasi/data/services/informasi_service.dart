import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/comment_item.dart';
import '../models/informasi_category.dart';
import '../models/informasi_item.dart';
import '../models/paginated_comment_result.dart';
import '../../../auth/data/models/user_model.dart';

class InformasiFeedResult {
  const InformasiFeedResult({
    required this.pinned,
    required this.items,
    required this.categories,
  });

  final List<InformasiItem> pinned;
  final List<InformasiItem> items;
  final List<InformasiCategory> categories;
}

class InformasiDetailResult {
  const InformasiDetailResult({
    required this.article,
    required this.relatedItems,
  });

  final InformasiItem article;
  final List<InformasiItem> relatedItems;
}

class InformasiService {
  InformasiService(this._dio);

  final Dio _dio;

  Future<InformasiFeedResult> fetchFeed() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/information',
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};

      return InformasiFeedResult(
        pinned: (payload['pinned'] as List<dynamic>? ?? [])
            .map((item) => InformasiItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        items: (payload['items'] as List<dynamic>? ?? [])
            .map((item) => InformasiItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        categories:
            ((payload['filters'] as Map<String, dynamic>?)?['categories']
                        as List<dynamic>? ??
                    [])
                .map(
                  (item) =>
                      InformasiCategory.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat informasi');
    }
  }

  Future<InformasiDetailResult> fetchDetail(String slug) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/information/$slug',
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final articleJson = payload['article'] as Map<String, dynamic>? ?? {};
      final relatedJson = payload['related_items'] as List<dynamic>? ?? [];

      return InformasiDetailResult(
        article: InformasiItem.fromJson(articleJson),
        relatedItems: relatedJson
            .map((item) => InformasiItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat detail informasi');
    }
  }

  Future<CommentItem> addComment({
    required String articleId,
    required String content,
    String? parentId,
  }) async {
    try {
      Response<Map<String, dynamic>> response;
      if (parentId == null) {
        response = await _dio.post<Map<String, dynamic>>(
          '/mobile/information/$articleId/comments',
          data: {'content': content},
        );
      } else {
        response = await _dio.post<Map<String, dynamic>>(
          '/mobile/information/$articleId/comments/$parentId/replies',
          data: {'content': content},
        );
      }

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final commentJson = payload['comment'] as Map<String, dynamic>? ?? {};
      return CommentItem.fromJson(commentJson);
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mengirim komentar');
    }
  }

  Future<PaginatedCommentResult> fetchComments(
    String slug, {
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/information/$slug/comments',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final itemsJson = payload['items'] as List<dynamic>? ?? [];
      return PaginatedCommentResult(
        items: itemsJson
            .map((item) => CommentItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        currentPage: envelope.meta?.currentPage ?? page,
        perPage: envelope.meta?.perPage ?? perPage,
        total: envelope.meta?.total ?? itemsJson.length,
        lastPage: envelope.meta?.lastPage ?? page,
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat komentar');
    }
  }

  Future<CommentItem> editComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/information/comments/$commentId',
        data: {'content': content},
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );
      final payload = envelope.data ?? <String, dynamic>{};
      final commentJson = payload['comment'] as Map<String, dynamic>? ?? {};
      return CommentItem.fromJson(commentJson);
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mengedit komentar');
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete<dynamic>('/mobile/information/comments/$commentId');
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus komentar');
    }
  }

  Future<UserModel> fetchPublicProfile(String userId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/users/$userId',
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat profil pengguna');
    }
  }

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }
}
