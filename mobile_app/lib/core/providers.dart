import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network/api_client.dart';
import 'storage/local_storage_service.dart';
import 'services/fcm_service.dart';
import 'services/deep_link_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final localStorageServiceProvider = Provider<LocalStorageService>(
  (ref) => LocalStorageService(),
);

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());

final deepLinkServiceProvider = Provider<DeepLinkService>(
  (ref) => DeepLinkService(),
);
