import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/profile_employee_data_model.dart';
import '../models/employee_enums.dart';
import '../models/schedule_data_model.dart';
import '../models/reference_model.dart';

abstract class ProfileRepository {
  Future<UserModel> enrollFace(String faceDataBase64);
  Future<UserModel> deleteFace();
  Future<UserModel> updateProfilePhoto(File file);
  Future<UserModel> updateProfile({
    String? name,
    String? fullName,
    String? phone,
    int? jobTitleId,
    int? institutionId,
  });
  Future<UserModel> updateHomeLocation({
    required double latitude,
    required double longitude,
  });
  Future<List<ReferenceItem>> fetchReferences(String model);
  Future<ProfileEmployeeDataModel?> getEmployeeData();
  Future<ProfileEmployeeDataModel> upsertEmployeeData({
    String? fullName,
    String? titlePrefix,
    String? titleSuffix,
    Gender? gender,
    String? birthPlace,
    DateTime? birthDate,
    Religion? religion,
    MaritalStatus? maritalStatus,
    String? nik,
    String? address,
    String? postalCode,
    String? bankAccountNumber,
    String? bankName,
    String? bankAccountHolderName,
    String? motherName,
    String? fatherName,
    int? childrenCount,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
  });
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<ScheduleDataModel> getSchedules();
  Future<Map<String, dynamic>> updateSchedule(int scheduleId);
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio);

  final Dio _dio;

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }

  @override
  Future<UserModel> enrollFace(String faceDataBase64) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/mobile/profile/face',
        data: {'face_data': faceDataBase64},
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mendaftar wajah');
    }
  }

  @override
  Future<UserModel> deleteFace() async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/mobile/profile/face',
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus data wajah');
    }
  }

  @override
  Future<UserModel> updateProfilePhoto(File file) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/profile',
        data: formData,
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui foto profil');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? fullName,
    String? phone,
    int? jobTitleId,
    int? institutionId,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (fullName != null) payload['full_name'] = fullName;
      if (phone != null) payload['phone'] = phone;
      if (jobTitleId != null) payload['job_title_id'] = jobTitleId.toString();
      if (institutionId != null) payload['institution_id'] = institutionId.toString();

      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/profile',
        data: FormData.fromMap(payload),
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui profil');
    }
  }

  @override
  Future<UserModel> updateHomeLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/profile/home-location',
        data: {
          'home_latitude': latitude,
          'home_longitude': longitude,
        },
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menyimpan lokasi rumah');
    }
  }

  @override
  Future<List<ReferenceItem>> fetchReferences(String model) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/reference/$model');
      return ApiResponse.fromJsonList(
        response.data!,
        (data) => ReferenceItem.fromJson(data),
      ).data ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat referensi $model');
    }
  }

  @override
  Future<ProfileEmployeeDataModel?> getEmployeeData() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/profile/employee-data',
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => ProfileEmployeeDataModel.fromJson(
          data as Map<String, dynamic>,
        ),
      ).data;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat data pegawai');
    }
  }

  @override
  Future<ProfileEmployeeDataModel> upsertEmployeeData({
    String? fullName,
    String? titlePrefix,
    String? titleSuffix,
    Gender? gender,
    String? birthPlace,
    DateTime? birthDate,
    Religion? religion,
    MaritalStatus? maritalStatus,
    String? nik,
    String? address,
    String? postalCode,
    String? bankAccountNumber,
    String? bankName,
    String? bankAccountHolderName,
    String? motherName,
    String? fatherName,
    int? childrenCount,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (fullName != null) payload['full_name'] = fullName;
      if (titlePrefix != null) payload['title_prefix'] = titlePrefix;
      if (titleSuffix != null) payload['title_suffix'] = titleSuffix;
      if (gender != null) payload['gender'] = gender.name;
      if (birthPlace != null) payload['birth_place'] = birthPlace;
      if (birthDate != null) payload['birth_date'] = birthDate.toIso8601String().split('T')[0];
      if (religion != null) payload['religion'] = religion.name;
      if (maritalStatus != null) payload['marital_status'] = maritalStatus.name;
      if (nik != null) payload['nik'] = nik;
      if (address != null) payload['address'] = address;
      if (postalCode != null) payload['postal_code'] = postalCode;
      if (bankAccountNumber != null) payload['bank_account_number'] = bankAccountNumber;
      if (bankName != null) payload['bank_name'] = bankName;
      if (bankAccountHolderName != null) payload['bank_account_holder_name'] = bankAccountHolderName;
      if (motherName != null) payload['mother_name'] = motherName;
      if (fatherName != null) payload['father_name'] = fatherName;
      if (childrenCount != null) payload['children_count'] = childrenCount.toString();
      if (emergencyContactName != null) payload['emergency_contact_name'] = emergencyContactName;
      if (emergencyContactPhone != null) payload['emergency_contact_phone'] = emergencyContactPhone;
      if (emergencyContactRelationship != null) payload['emergency_contact_relationship'] = emergencyContactRelationship;

      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/profile/employee-data',
        data: FormData.fromMap(payload),
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => ProfileEmployeeDataModel.fromJson(
          data as Map<String, dynamic>,
        ),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui data pegawai');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final formData = FormData.fromMap({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });
      await _dio.put<Map<String, dynamic>>(
        '/mobile/profile/password',
        data: formData,
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui password');
    }
  }

  @override
  Future<ScheduleDataModel> getSchedules() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/profile/schedules',
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => ScheduleDataModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat data jadwal');
    }
  }

  @override
  Future<Map<String, dynamic>> updateSchedule(int scheduleId) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/profile/schedules',
        data: {'schedule_id': scheduleId},
      );

      final apiResponse = ApiResponse.fromJson(
        response.data!,
        (data) => data as Map<String, dynamic>,
      );

      return {
        'data': apiResponse.data,
        'message': apiResponse.message,
      };
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menyimpan jadwal');
    }
  }
}
