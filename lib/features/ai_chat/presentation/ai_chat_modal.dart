import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/ai_chat_service.dart';
import '../domain/chat_message.dart';
import 'widgets/chat_bubble.dart';

class AiChatModal extends StatefulWidget {
  const AiChatModal({super.key});

  @override
  State<AiChatModal> createState() => _AiChatModalState();
}

class _AiChatModalState extends State<AiChatModal> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiChatService _chatService = AiChatService();

  bool _isStreaming = false;
  CancelToken? _activeCancelToken;

  @override
  void dispose() {
    _activeCancelToken?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isStreaming) return;

    _inputController.clear();

    final userMessage = ChatMessage(role: ChatRole.user, content: text);
    final assistantMessage = ChatMessage(role: ChatRole.assistant, content: '');

    setState(() {
      _messages.add(userMessage);
      _messages.add(assistantMessage);
      _isStreaming = true;
    });

    _scrollToBottom();

    _activeCancelToken = _chatService.streamChat(
      messages: _messages.where((m) => !m.isError && m.content.isNotEmpty).toList(),
      onDelta: (delta) {
        if (!mounted) return;
        setState(() {
          assistantMessage.content += delta;
        });
        _scrollToBottom();
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          if (assistantMessage.content.isEmpty) {
            _messages.remove(assistantMessage);
            _messages.add(ChatMessage(
              role: ChatRole.assistant,
              content: error,
              isError: true,
            ));
          }
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          _activeCancelToken = null;
          if (assistantMessage.content.isEmpty && _messages.contains(assistantMessage)) {
            _messages.remove(assistantMessage);
          }
        });
      },
    );
  }

  void _stopStreaming() {
    _activeCancelToken?.cancel();
    setState(() {
      _isStreaming = false;
      _activeCancelToken = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SafeArea(
          bottom: false,
          child: _buildHeader(),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(child: _buildMessageList()),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Color(0xFF34C759),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'DocAI Assistant',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1F),
                  ),
                ),
                Text(
                  _isStreaming ? 'En train d\'ecrire...' : 'En ligne',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isStreaming ? const Color(0xFF34C759) : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF1D1D1F)),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF5F5F7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Posez votre question a DocAI',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) => ChatBubble(message: _messages[index]),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _inputController,
                  enabled: !_isStreaming,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Votre message...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  style: const TextStyle(fontSize: 15, color: Color(0xFF1D1D1F)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _isStreaming ? _stopStreaming : _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isStreaming ? const Color(0xFFEF4444) : const Color(0xFF34C759),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  _isStreaming ? Icons.stop_rounded : Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens the AI chat as a full-screen modal page.
/// Uses rootNavigator to escape the ShellRoute's BottomNavBar overlay.
void showAiChatModal(BuildContext context) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const AiChatModal(),
    ),
  );
}
