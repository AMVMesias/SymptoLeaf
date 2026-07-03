import 'package:flutter/material.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';

/// Molecule: Burbuja de mensaje para chat
class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUser;
  final DateTime? timestamp;
  final bool isLoading;
  final Color? userBubbleColor;
  final Color? botBubbleColor;

  const MessageBubble({
    Key? key,
    required this.content,
    required this.isUser,
    this.timestamp,
    this.isLoading = false,
    this.userBubbleColor,
    this.botBubbleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? (userBubbleColor ?? EsquemaColor.primaryGreen)
        : (botBubbleColor ?? Colors.white);
    final textColor = isUser ? Colors.white : EsquemaColor.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              _buildLoadingIndicator()
            else
              Text(
                content,
                style: Tipografia.cuerpo.copyWith(color: textColor),
              ),
            if (timestamp != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatTime(timestamp!),
                style: Tipografia.caption.copyWith(
                  color: isUser
                      ? Colors.white.withOpacity(0.7)
                      : EsquemaColor.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(0),
        const SizedBox(width: 4),
        _buildDot(1),
        const SizedBox(width: 4),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: EsquemaColor.textSecondary.withOpacity(0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
