import 'package:corevia_mobile/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as chat_core;

// Modèle pour les IAs spécialisées
class AIDoctor {
  final String id;
  final String name;
  final String specialty;
  final Color primaryColor;
  final Color secondaryColor;

  const AIDoctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

// Liste des IAs disponibles
final List<AIDoctor> availableAIs = [
  const AIDoctor(
    id: 'doc_locke',
    name: 'Doc Locke.AI',
    specialty: 'Médecine Générale',
    primaryColor: Color(0xFF34C759),
    secondaryColor: Color(0xFF5DF394),
  ),
  const AIDoctor(
    id: 'dr_cardio',
    name: 'Dr. CardioIA',
    specialty: 'Cardiologie',
    primaryColor: Color(0xFFFF3B30),
    secondaryColor: Color(0xFFFF6B6B),
  ),
  const AIDoctor(
    id: 'dr_neuro',
    name: 'Dr. NeuroBot',
    specialty: 'Neurologie',
    primaryColor: Color(0xFF5856D6),
    secondaryColor: Color(0xFF8E8CD8),
  ),
  const AIDoctor(
    id: 'dr_dermato',
    name: 'Dr. DermaAI',
    specialty: 'Dermatologie',
    primaryColor: Color(0xFFFF9500),
    secondaryColor: Color(0xFFFFB340),
  ),
];

// Modèle pour les conversations
class Conversation {
  final String id;
  final String aiDoctorId;
  final String title;
  final DateTime lastMessageDate;
  final String preview;

  Conversation({
    required this.id,
    required this.aiDoctorId,
    required this.title,
    required this.lastMessageDate,
    required this.preview,
  });
}

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String? aiDoctorId;
  
  const ChatScreen({
    super.key, 
    required this.conversationId,
    this.aiDoctorId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late AIDoctor _currentAI;
  late chat_core.User _assistant;
  final chat_core.User _currentUser = const chat_core.User(
    id: 'user',
    name: 'Georges',
  );
  late final chat_core.InMemoryChatController _chatController;
  bool _isTyping = false;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  late AnimationController _typingAnimationController;

  // Liste des conversations (mock data)
  final List<Conversation> _conversations = [
    Conversation(
      id: 'conv_1',
      aiDoctorId: 'doc_locke',
      title: 'Consultation poumons',
      lastMessageDate: DateTime.now().subtract(const Duration(hours: 2)),
      preview: 'Hey Georges! Of course, I think you should...',
    ),
    Conversation(
      id: 'conv_2',
      aiDoctorId: 'dr_cardio',
      title: 'Douleurs thoraciques',
      lastMessageDate: DateTime.now().subtract(const Duration(days: 1)),
      preview: 'Les douleurs que vous décrivez peuvent...',
    ),
    Conversation(
      id: 'conv_3',
      aiDoctorId: 'dr_neuro',
      title: 'Migraines fréquentes',
      lastMessageDate: DateTime.now().subtract(const Duration(days: 3)),
      preview: 'Pour vos migraines, je recommande...',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialiser l'IA actuelle
    final aiId = widget.aiDoctorId ?? 'doc_locke';
    _currentAI = availableAIs.firstWhere(
      (ai) => ai.id == aiId,
      orElse: () => availableAIs[0],
    );
    
    _assistant = chat_core.User(
      id: _currentAI.id,
      name: _currentAI.name,
    );
    
    _chatController = chat_core.InMemoryChatController();
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // S'assurer que le widget est monté avant d'effectuer des opérations asynchrones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.conversationId != 'new') {
          _loadConversation(widget.conversationId);
        } else {
          _addSystemMessage(
            'Bonjour Georges ! Je suis ${_currentAI.name}, spécialiste en ${_currentAI.specialty}. ' 
            'Comment puis-je vous aider aujourd\'hui ?'
          );
        }
      }
    });
  }
  
  void _loadConversation(String conversationId) {
    _addSystemMessage(
      'Reprise de la conversation. Comment puis-je vous aider aujourd\'hui ?'
    );
  }

  void _addSystemMessage(String text) {
    final message = _buildTextMessage(author: _assistant, text: text);
    _chatController.insertMessage(message, index: 0);
  }

  void _showAISelectionDialog() {
    AIDoctor selectedAI = _currentAI;  // Garder une référence locale de l'IA sélectionnée
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // En-tête
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, color: Color(0xFF6C63FF), size: 28),
                        const SizedBox(width: 12),
                        const Text(
                          'Choisir un spécialiste',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 24, color: Colors.grey),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  
                  // Liste des IAs
                  Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableAIs.length,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      itemBuilder: (context, index) {
                        final ai = availableAIs[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: selectedAI.id == ai.id 
                                ? ai.primaryColor.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: selectedAI.id == ai.id
                                ? Border.all(color: ai.primaryColor, width: 1.5)
                                : null,
                            boxShadow: selectedAI.id == ai.id ? [
                              BoxShadow(
                                color: ai.primaryColor.withOpacity(0.1),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ] : null,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Mettre à jour la sélection visuelle immédiatement
                                setDialogState(() {
                                  selectedAI = ai;
                                });

                                // Détruire l'ancien contrôleur s'il existe
                                _chatController.dispose();
                                
                                // Mettre à jour l'état principal
                                setState(() {
                                  _currentAI = ai;
                                  _assistant = chat_core.User(
                                    id: _currentAI.id,
                                    name: _currentAI.name,
                                  );
                                  _chatController = chat_core.InMemoryChatController();
                                  _isTyping = false;
                                  
                                  // Ajouter le message de bienvenue
                                  _addSystemMessage(
                                    'Bonjour Georges ! Je suis ${ai.name}, spécialiste en ${ai.specialty}. ' 
                                    'Comment puis-je vous aider aujourd\'hui ?'
                                  );
                                });
                                
                                // Fermer la boîte de dialogue après un court délai pour un meilleur retour visuel
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [ai.secondaryColor, ai.primaryColor],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: ai.primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded, 
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Texte
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ai.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1D1D1F),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ai.specialty,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Indicateur de sélection
                                    if (_currentAI.id == ai.id)
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: ai.primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.check_circle_rounded,
                                          color: ai.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Bouton de fermeture
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6C63FF),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                        ),
                      ),
                      child: const Text(
                        'Fermer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header du drawer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_currentAI.primaryColor, _currentAI.secondaryColor],
                ),
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
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Georges',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Patient',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bouton nouvelle conversation
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context); // Fermer le drawer
                  _showAISelectionDialog();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_currentAI.primaryColor, _currentAI.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _currentAI.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Nouvelle conversation',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section IAs disponibles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'IAs Spécialisées',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.withOpacity(0.2),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste des IAs
            ...availableAIs.map((ai) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ai.secondaryColor, ai.primaryColor],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                ai.name,
                style: TextStyle(
                  fontWeight: ai.id == _currentAI.id ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                  color: ai.id == _currentAI.id ? ai.primaryColor : const Color(0xFF1D1D1F),
                ),
              ),
              subtitle: Text(
                ai.specialty,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              trailing: ai.id == _currentAI.id
                  ? Icon(Icons.check_circle, color: ai.primaryColor, size: 20)
                  : null,
              onTap: () {
                Navigator.pop(context);
                if (ai.id != _currentAI.id) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        conversationId: 'new',
                        aiDoctorId: ai.id,
                      ),
                    ),
                  );
                }
              },
            )).toList(),

            const Divider(height: 32),
            
            // Section historique
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Historique',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.withOpacity(0.2),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            // Liste des conversations
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  final ai = availableAIs.firstWhere(
                    (a) => a.id == conversation.aiDoctorId,
                    orElse: () => availableAIs[0],
                  );
                  
                  final uniqueKey = ValueKey('ai_${ai.id}_${conversation.id}');
                  
                  return ListTile(
                    key: uniqueKey,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [ai.secondaryColor, ai.primaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      conversation.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation.preview,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(conversation.lastMessageDate),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close, size: 18, color: Colors.grey.withOpacity(0.2)),
                      onPressed: () {
                        // Supprimer la conversation
                        setState(() {
                          _conversations.removeAt(index);
                        });
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            conversationId: conversation.id,
                            aiDoctorId: conversation.aiDoctorId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inHours < 1) {
      return 'Il y a ${diff.inMinutes}min';
    } else if (diff.inHours < 24) {
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays}j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              icon: Icon(Icons.add, color: Colors.grey.withOpacity(0.7), size: 22),
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
                    color: Colors.grey.withOpacity(0.2), 
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
              gradient: LinearGradient(
                colors: [_currentAI.secondaryColor, _currentAI.primaryColor],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _currentAI.primaryColor.withOpacity(0.3),
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

  void _sendCurrentMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Créer et envoyer le message utilisateur
    final message = _buildTextMessage(
      author: _currentUser,
      text: text,
    );
    _chatController.insertMessage(message, index: 0);
    
    // Effacer le champ de texte et donner le focus
    _messageController.clear();
    _messageFocusNode.requestFocus();
    
    // Simuler une réponse de l'IA
    _simulateAIReply(text);
  }

  void _simulateAIReply(String userMessage) {
    setState(() {
      _isTyping = true;
    });

    // Simuler un délai de frappe
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      final response = _generateMockResponse(userMessage);
      
      setState(() {
        _isTyping = false;
        _addSystemMessage(response);
        
        // Si la réponse contient une carte médecin, l'ajouter
        if (userMessage.toLowerCase().contains('trouv') || 
            userMessage.toLowerCase().contains('spécialiste') ||
            userMessage.toLowerCase().contains('médecin')) {
          _addSystemMessage(_generateDoctorCardMessage());
        }
      });
    });
  }

  String _generateMockResponse(String message) {
    // Logique de génération de réponse factice
    if (message.toLowerCase().contains('bonjour') || 
        message.toLowerCase().contains('salut') ||
        message.toLowerCase().contains('coucou')) {
      return 'Bonjour Georges ! Comment puis-je vous aider aujourd\'hui ?';
    } else if (message.toLowerCase().contains('santé') || 
               message.toLowerCase().contains('souci') ||
               message.toLowerCase().contains('problème')) {
      return 'Je vois que vous avez un problème de santé. Pouvez-vous me décrire vos symptômes plus en détail ?';
    } else if (message.toLowerCase().contains('merci')) {
      return 'Je vous en prie ! N\'hésitez pas si vous avez d\'autres questions.';
    } else {
      return 'Je comprends que vous dites : "$message". En tant que ${_currentAI.specialty}, je peux vous aider avec des questions liées à ce domaine.';
    }
  }

  String _generateDoctorCardMessage() {
    return 'Voici un médecin qui pourrait vous aider :\n\n'
           '👨‍⚕️ Dr. Dupont\n'
           '📍 Hôpital de la Pitié-Salpêtrière, Paris\n'
           '📞 01 45 67 89 00\n\n'
           'Spécialiste reconnu dans son domaine avec plus de 15 ans d\'expérience.';
  }

  @override
  void dispose() {
    _chatController.dispose();
    _typingAnimationController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
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
            color: Colors.black.withOpacity(0.05),
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
            color: _currentAI.primaryColor.withOpacity(0.4 + (opacity * 0.6)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _currentAI.primaryColor.withOpacity(opacity * 0.3),
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
            color: Colors.black.withOpacity(0.05),
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
                child: Icon(Icons.person, size: 28, color: Colors.grey.withOpacity(0.7)),
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
                          decoration: BoxDecoration(
                            color: _currentAI.primaryColor,
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
                        color: Colors.grey.withOpacity(0.2),
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
                      Icon(Icons.location_on, color: Colors.grey.withOpacity(0.2), size: 12),
                      const SizedBox(width: 2),
                      Text(
                        doctor['distance'] ?? '2km',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _currentAI.primaryColor,
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
                color: Colors.grey.withOpacity(0.2),
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
      drawer: _buildDrawer(),
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
                    gradient: LinearGradient(
                      colors: [_currentAI.secondaryColor, _currentAI.primaryColor],
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
                      color: _currentAI.primaryColor,
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
                      Flexible(
                        child: Text(
                          _currentAI.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF1D1D1F),
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                    _currentAI.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withOpacity(0.2),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF1D1D1F), size: 20),
              onPressed: () => Scaffold.of(context).openDrawer(),
              padding: EdgeInsets.zero,
            ),
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
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content area with messages
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Messages list
                Expanded(
                  child: StreamBuilder<List<chat_core.Message>>(
                    stream: Stream.value(_chatController.messages),
                    builder: (context, snapshot) {
                      final messages = snapshot.data ?? [];
                      
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 0,
                          right: 0,
                          bottom: 160, // Augmenté de 140 à 160 pour plus d'espace
                        ),
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
                                      ? _currentAI.primaryColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
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
              ],
            ),
          ),
          
          // Message composer positioned above bottom nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 80, // Augmenté de 60 à 80 pour plus d'espace
            child: _buildComposer(),
          ),
          
          // Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(currentLocation: '/chat/ai/new'),
          ),
        ],
      ),
    );
  }
}