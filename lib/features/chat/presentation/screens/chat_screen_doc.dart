import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;

class ChatScreen extends StatefulWidget {
  final String conversationId;
  
  const ChatScreen({
    super.key, 
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final chat_core.User _assistant = const chat_core.User(
    id: 'ai',
    name: 'Doc Locke.AI',
  );
  final chat_core.User _currentUser = const chat_core.User(
    id: 'user',
    name: 'Georges',
  );
  late final chat_core.InMemoryChatController _chatController;
  bool _isTyping = false;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _chatController = chat_core.InMemoryChatController();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    if (widget.conversationId != 'new') {
      _loadConversation(widget.conversationId);
    } else {
      _addSystemMessage(
        'Bonjour Georges ! Je suis Doc Locke.AI, votre assistant médical virtuel. '
        'Je peux vous aider à comprendre vos symptômes et vous orienter vers les bons spécialistes.'
      );
    }
  }
  
  void _loadConversation(String conversationId) {
    _addSystemMessage(
      'Reprise de la conversation. Comment puis-je vous aider aujourd\'hui ?'
    );
  }

  void _sendCurrentMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _handleSendPressed(text);
    _messageController.clear();
    _messageFocusNode.requestFocus();
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.grey[700], size: 22),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(
                  color: Color(0xFF1D1D1F), 
                  fontSize: 15,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendCurrentMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.grey[600], 
                    fontSize: 15,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5DF394), Color(0xFF34C759)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF34C759).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_upward_rounded, 
                color: Colors.white, 
                size: 22,
              ),
              onPressed: _sendCurrentMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _typingAnimationController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _addSystemMessage(String text) {
    final message = _buildTextMessage(author: _assistant, text: text);
    _chatController.insertMessage(message, index: 0);
  }

  Future<void> _handleSendPressed(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final textMessage = _buildTextMessage(author: _currentUser, text: trimmed);
    _chatController.insertMessage(textMessage, index: 0);

    setState(() {
      _isTyping = true;
    });

    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      setState(() {
        _isTyping = false;
      });

      final aiMessage = _buildTextMessage(
        author: _assistant,
        text: _generateMockResponse(trimmed),
      );
      _chatController.insertMessage(aiMessage, index: 0);

      if (trimmed.toLowerCase().contains('lung') || 
          trimmed.toLowerCase().contains('poumon') ||
          trimmed.toLowerCase().contains('hurts')) {
        await Future.delayed(const Duration(milliseconds: 500));
        final cardMessage = _buildDoctorCardMessage();
        _chatController.insertMessage(cardMessage, index: 0);
      }
    }
  }

  chat_core.Message _buildDoctorCardMessage() {
    final now = DateTime.now();
    return chat_core.Message.custom(
      id: now.millisecondsSinceEpoch.toString(),
      authorId: _assistant.id,
      createdAt: now,
      metadata: {
        'type': 'doctor_card',
        'doctor': {
          'name': 'Dr. Ahmed Badaoui',
          'specialty': 'Lung Specialist',
          'rating': 5.0,
          'distance': '2km',
          'image': 'doctor_avatar',
        },
      },
    );
  }

  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('lung') || lowerMessage.contains('poumon') || lowerMessage.contains('hurts')) {
      return 'Hey Georges! Of course, I think you should get your lung checked asap!\n\nI\'m happy to schedule you with Dr. Ahmed Badaoui a certified Lung specialist.';
    } else if (lowerMessage.contains('schedule') || lowerMessage.contains('time')) {
      return 'Of course, Georges. I\'ll update your calendar with Dr. Ahmed and set an automatic alert to you!';
    } else if (lowerMessage.contains('thanks') || lowerMessage.contains('merci')) {
      return 'You\'re welcome! Take care and don\'t hesitate if you need anything else! 💚';
    } else {
      return 'I understand your concern. Could you provide more details so I can help you better?\n\n💡 Remember: my advice is informative and never replaces professional medical advice.';
    }
  }

  chat_core.Message _buildTextMessage({
    required chat_core.User author,
    required String text,
  }) {
    final now = DateTime.now();
    return chat_core.Message.text(
      id: now.millisecondsSinceEpoch.toString(),
      authorId: author.id,
      createdAt: now,
      text: text,
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(right: 80, left: 16, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0),
          const SizedBox(width: 6),
          _buildDot(1),
          const SizedBox(width: 6),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final value = (_typingAnimationController.value - (index * 0.2)) % 1.0;
        final opacity = (value < 0.5) ? value * 2 : (1 - value) * 2;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF34C759).withOpacity(0.4 + (opacity * 0.6)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF34C759).withOpacity(opacity * 0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(right: 60, left: 16, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.person, size: 28, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          doctor['name'] ?? 'Dr. Ahmed Badaoui',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF34C759),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialty'] ?? 'Lung Specialist',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFBE0A), size: 14),
                      const SizedBox(width: 2),
                      Text(
                        doctor['rating']?.toString() ?? '5.0',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1D1D1F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600], size: 12),
                      const SizedBox(width: 2),
                      Text(
                        doctor['distance'] ?? '2km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  '10:30 - 11:30 AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'For a Lung Checkup',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5DF394), Color(0xFF34C759)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Doc Locke.AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF1D1D1F),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F2C1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFBE0A),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1D1D1F), size: 16),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF1D1D1F), size: 20),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20, top: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5EA),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                          ),
                          title: const Text(
                            'Effacer l\'historique',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () {
                            setState(() {
                              _chatController.dispose();
                              _chatController = chat_core.InMemoryChatController();
                            });
                            Navigator.pop(context);
                            _addSystemMessage('Historique effacé. Comment puis-je vous aider ?');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<chat_core.Message>>(
                stream: Stream.value(_chatController.messages),
                builder: (context, snapshot) {
                  final messages = snapshot.data ?? [];
                  
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    itemCount: messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == 0) {
                        return _buildTypingIndicator();
                      }
                      
                      final messageIndex = _isTyping ? index - 1 : index;
                      final message = messages[messageIndex];
                      final isUser = message.authorId == _currentUser.id;
                      
                      if (message is chat_core.CustomMessage) {
                        final metadata = message.metadata;
                        if (metadata?['type'] == 'doctor_card') {
                          return _buildDoctorCard(metadata?['doctor'] ?? {});
                        }
                      }
                      
                      if (message is chat_core.TextMessage) {
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                              left: isUser ? 60 : 16,
                              right: isUser ? 16 : 60,
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isUser 
                                  ? const Color(0xFF34C759) 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: isUser ? Colors.white : const Color(0xFF1D1D1F),
                                height: 1.5,
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }
}