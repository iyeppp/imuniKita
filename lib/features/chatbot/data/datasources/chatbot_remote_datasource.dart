import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import 'chatbot_mock_datasource.dart';

/// Remote datasource AI Chatbot dengan fallback mock offline.
class ChatbotRemoteDatasource {
  ChatbotRemoteDatasource({
    this.apiClient,
    ChatbotMockDatasource? mockDatasource,
  })  : _mockDatasource = mockDatasource ?? ChatbotMockDatasource();

  final ApiClient? apiClient;
  final ChatbotMockDatasource _mockDatasource;

  Future<String> getResponse(String userMessage) async {
    if (apiClient != null) {
      try {
        final response = await apiClient!.post<Map<String, dynamic>>(
          '/v1/chatbot/messages',
          data: {'message': userMessage},
        );

        if (response.data != null) {
          final data = response.data!['data'] as Map<String, dynamic>?;
          final reply = data?['reply'] as String?;
          if (reply != null && reply.isNotEmpty) {
            return reply;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('ChatbotRemoteDatasource: POST chatbot gagal ($e), memuat fallback keyword.');
        }
      }
    }

    return _mockDatasource.getResponse(userMessage);
  }
}
