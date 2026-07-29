import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/notification_model.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<List<NotificationModel>> fetchHistory(String code) async {
    final response = await _apiClient.dio.get(
      ApiConstants.notificationsHistoryPath(code),
    );
    final data = response.data as List;
    return data
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String notificationId) async {
    await _apiClient.dio.patch(ApiConstants.markReadPath(notificationId));
  }
}
