import 'package:flutter/material.dart';
import '../molecules/input_with_button.dart';
import '../molecules/message_bubble.dart';
import '../../../data/models/chat_message_model.dart';

/// Organism: Área completa de chat con mensajes y entrada
class ChatArea extends StatelessWidget {
  final List<ChatMessage> messages;
  final TextEditingController messageController;
  final ScrollController? scrollController;
  final FocusNode? focusNode;
  final VoidCallback? onSendMessage;
  final bool isLoading;

  const ChatArea({
    Key? key,
    required this.messages,
    required this.messageController,
    this.scrollController,
    this.focusNode,
    this.onSendMessage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista de mensajes
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return MessageBubble(
                content: message.content,
                isUser: message.isUser,
                timestamp: message.timestamp,
                isLoading: message.isLoading,
              );
            },
          ),
        ),
        
        // Área de entrada
        InputWithButton(
          controller: messageController,
          hintText: 'Escribe tu mensaje...',
          focusNode: focusNode,
          onButtonPressed: onSendMessage,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
