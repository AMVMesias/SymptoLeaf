/// Modelo para mensajes del chat
class ChatMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.user(String content) {
    return ChatMessage(
      content: content,
      role: MessageRole.user,
    );
  }

  factory ChatMessage.assistant(String content) {
    return ChatMessage(
      content: content,
      role: MessageRole.assistant,
    );
  }

  factory ChatMessage.loading() {
    return ChatMessage(
      content: '',
      role: MessageRole.assistant,
      isLoading: true,
    );
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}

enum MessageRole { user, assistant }
