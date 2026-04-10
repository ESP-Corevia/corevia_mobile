enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  String content;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Convert to AI SDK UIMessage format for sending to backend.
  /// Matches the UIMessage shape expected by convertToModelMessages().
  Map<String, dynamic> toApiMessage() => {
    'id': 'msg_${timestamp.millisecondsSinceEpoch}',
    'role': role == ChatRole.user ? 'user' : 'assistant',
    'parts': [
      {'type': 'text', 'text': content},
    ],
  };
}
