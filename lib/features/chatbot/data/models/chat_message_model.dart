/// Model pesan chat — disimpan in-memory (tidak perlu Hive).
class ChatMessage {
  final String id; // uuid v4
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
