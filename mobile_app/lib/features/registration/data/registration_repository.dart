import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';

class RegistrationRepository {
  final ApiClient _apiClient;

  RegistrationRepository(this._apiClient);

  Future<void> register(String code, String fcmToken) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.registerPath,
        data: {'code': code, 'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        throw const CodeNotFoundException();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw const UnknownApiException();
    }
  }
}
