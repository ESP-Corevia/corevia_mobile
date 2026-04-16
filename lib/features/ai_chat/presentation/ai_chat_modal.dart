import 'package:flutter/material.dart';

import '../data/rag_chat_storage.dart';
import '../data/rag_socket_chat_service.dart';
import '../data/rag_socket_config.dart';
import '../domain/chat_message.dart';
import '../domain/rag_agent.dart';
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
  final RagChatStorage _storage = RagChatStorage();

  bool _isStreaming = false;
  bool _isConnected = false;
  String _selectedAgentId = RagAgents.medecinGeneraliste.id;
  String? _userId;

  RagSocketChatService? _socket;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _socket?.dispose();
    _inputController.dispose();
    _scrollController.dispose();
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

  Future<void> _init() async {
    final agentId = await _storage.getSelectedAgentId();
    final history = await _storage.loadUserHistory(agentId);
    final userId = await _storage.getOrCreateUserId();

    if (!mounted) return;
    setState(() {
      _selectedAgentId = agentId;
      _userId = userId;
      _messages
        ..clear()
        ..addAll(history);
    });

    _connect();
  }

  void _connect() {
    _socket ??= RagSocketChatService(url: RagSocketConfig.resolveUrl());
    _socket!.connect(onConnectionChanged: (connected) {
      if (!mounted) return;
      setState(() {
        _isConnected = connected;
      });
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isStreaming) return;

    _inputController.clear();

    final userMessage = ChatMessage(role: ChatRole.user, content: text);

    setState(() {
      _messages.add(userMessage);
    });

    await _storage.appendUserMessage(_selectedAgentId, userMessage);
    _scrollToBottom();

    await _streamResponse(query: text);
  }

  Future<void> _streamResponse({required String query}) async {
    final assistantMessage = ChatMessage(role: ChatRole.assistant, content: '');

    setState(() {
      _messages.add(assistantMessage);
      _isStreaming = true;
    });

    _scrollToBottom();

    _connect();

    _userId ??= await _storage.getOrCreateUserId();
    final userId = _userId!;

    await _socket!.sendQuery(
      agentId: _selectedAgentId,
      query: query,
      userId: userId,
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
          if (_messages.contains(assistantMessage)) {
            if (assistantMessage.content.isEmpty) {
              _messages.remove(assistantMessage);
              _messages.add(ChatMessage(
                role: ChatRole.assistant,
                content: error,
                isError: true,
              ));
            }
          }
          _isStreaming = false;
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          if (assistantMessage.content.isEmpty && _messages.contains(assistantMessage)) {
            _messages.remove(assistantMessage);
          }
        });
      },
    );
  }

  void _stopStreaming() {
    _socket?.disconnect();
    setState(() {
      _isStreaming = false;
    });
  }

  Future<void> _selectAgent(String agentId) async {
    if (agentId == _selectedAgentId) return;

    _stopStreaming();

    await _storage.setSelectedAgentId(agentId);
    final history = await _storage.loadUserHistory(agentId);

    if (!mounted) return;
    setState(() {
      _selectedAgentId = agentId;
      _messages
        ..clear()
        ..addAll(history);
    });
  }

  Future<void> _clearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l’historique ?'),
        content: const Text(
          'Cela supprimera les questions enregistrées localement et réinitialisera votre identifiant de chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (shouldClear != true) return;

    _stopStreaming();
    await _storage.clearUserHistory(_selectedAgentId);
    await _storage.resetUserId();

    if (!mounted) return;
    setState(() {
      _userId = null;
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(child: _buildMessageList()),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final agent = RagAgents.byId(_selectedAgentId);
    final status = _isStreaming
        ? 'En train d\'écrire...'
        : _isConnected
            ? 'En ligne'
            : 'Connexion...';

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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'DocAI Assistant',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1D1F),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: agent.id,
                        items: RagAgents.all
                            .map((a) => DropdownMenuItem<String>(
                                  value: a.id,
                                  child: Text(a.label),
                                ))
                            .toList(),
                        onChanged: _isStreaming ? null : (v) => _selectAgent(v ?? agent.id),
                      ),
                    ),
                  ],
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isStreaming
                        ? const Color(0xFF34C759)
                        : Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Les réponses IA ne sont pas enregistrées.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isStreaming ? null : _clearHistory,
            icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade700),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF5F5F7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 8),
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
              'Posez votre question à ${RagAgents.byId(_selectedAgentId).label}',
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

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length,
            itemBuilder: (context, index) => ChatBubble(message: _messages[index]),
          ),
        ),
      ],
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
              onTap: _isStreaming ? _stopStreaming : () => _sendMessage(),
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

/// Opens the AI chat as a bottom sheet modal.
/// Uses rootNavigator to escape the ShellRoute's BottomNavBar overlay.
void showAiChatModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (modalContext) => const AiChatModal(),
  );
}
