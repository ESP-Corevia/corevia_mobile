import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../domain/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final isError = message.isError;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: EdgeInsets.only(
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
          bottom: 8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? const Color(0xFFFEE2E2)
              : isUser
                  ? const Color(0xFF34C759)
                  : const Color(0xFFF5F5F7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
        ),
        child: isUser
            ? Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              )
            : _AssistantContent(message: message, isError: isError),
      ),
    );
  }
}

class _AssistantContent extends StatelessWidget {
  final ChatMessage message;
  final bool isError;

  const _AssistantContent({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    if (message.content.isEmpty) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF34C759),
        ),
      );
    }

    final textColor = isError ? const Color(0xFFDC2626) : const Color(0xFF1D1D1F);

    return MarkdownBody(
      data: message.content,
      selectable: true,
      shrinkWrap: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 15, height: 1.5, color: textColor),
        strong: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textColor),
        em: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: textColor),
        code: TextStyle(
          fontSize: 13,
          color: textColor,
          backgroundColor: Colors.black.withValues(alpha: 0.05),
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF1D1D1F),
          borderRadius: BorderRadius.circular(8),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        listBullet: TextStyle(fontSize: 15, color: textColor),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey.shade400, width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      ),
    );
  }
}
