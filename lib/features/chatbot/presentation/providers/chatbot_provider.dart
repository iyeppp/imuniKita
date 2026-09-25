import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/chatbot_mock_datasource.dart';
import '../../data/models/chat_message_model.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  const ChatState({required this.messages, required this.isLoading});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._datasource)
    : super(const ChatState(messages: [], isLoading: false));

  final ChatbotMockDatasource _datasource;
  final _uuid = const Uuid();

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // 1. Tambah pesan user
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    // 2. Ambil respons dari datasource (mock delay)
    try {
      final responseText = await _datasource.getResponse(trimmed);

      final botMessage = ChatMessage(
        id: _uuid.v4(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
    } catch (_) {
      // Fallback bila terjadi error tak terduga
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        text: 'Maaf, terjadi kesalahan. Coba lagi beberapa saat. 🙏',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }

  void clearMessages() {
    state = const ChatState(messages: [], isLoading: false);
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final chatbotDatasourceProvider = Provider<ChatbotMockDatasource>(
  (ref) => ChatbotMockDatasource(),
);

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(ref.read(chatbotDatasourceProvider)),
);
