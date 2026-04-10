enum ChatRole { user, assistant }

enum ToolCallState { pending, approved, rejected }

class ToolCallInfo {
  final String toolCallId;
  final String toolName;
  final Map<String, dynamic> args;
  ToolCallState state;
  Map<String, dynamic>? result;

  ToolCallInfo({
    required this.toolCallId,
    required this.toolName,
    required this.args,
    this.state = ToolCallState.pending,
    this.result,
  });

  String get displayName => _toolLabels[toolName] ?? toolName;

  bool get needsApproval => _mutationTools.contains(toolName);

  static const _mutationTools = {
    'create_appointment',
    'mark_intake_taken',
    'mark_intake_skipped',
  };

  static const _toolLabels = {
    'create_appointment': 'Prendre un rendez-vous',
    'mark_intake_taken': 'Marquer la prise comme effectuée',
    'mark_intake_skipped': 'Marquer la prise comme ignorée',
    'get_my_appointments': 'Consulter mes rendez-vous',
    'get_appointment_detail': 'Détail du rendez-vous',
    'list_doctors': 'Rechercher des médecins',
    'get_available_slots': 'Consulter les créneaux',
    'search_medications': 'Rechercher un médicament',
    'get_my_today_pillbox': 'Prises du jour',
    'list_my_medications': 'Mes médicaments',
    'get_medication_detail': 'Détail du médicament',
  };

  /// Tools that should trigger a provider refresh after execution.
  static const refreshProviders = {
    'mark_intake_taken': 'pillbox',
    'mark_intake_skipped': 'pillbox',
  };
}

class ChatMessage {
  final ChatRole role;
  String content;
  final DateTime timestamp;
  final bool isError;
  final List<ToolCallInfo> toolCalls;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.isError = false,
    List<ToolCallInfo>? toolCalls,
  })  : timestamp = timestamp ?? DateTime.now(),
        toolCalls = toolCalls ?? [];

  bool get hasPendingToolCalls =>
      toolCalls.any((tc) => tc.state == ToolCallState.pending);

  /// Convert to AI SDK UIMessage format for sending to backend.
  Map<String, dynamic> toApiMessage() {
    final parts = <Map<String, dynamic>>[];

    if (content.isNotEmpty) {
      parts.add({'type': 'text', 'text': content});
    }

    for (final tc in toolCalls) {
      final part = <String, dynamic>{
        'type': 'tool-invocation',
        'toolCallId': tc.toolCallId,
        'toolName': tc.toolName,
        'args': tc.args,
      };

      if (tc.state == ToolCallState.approved) {
        part['state'] = 'result';
        part['result'] = tc.result ?? {'approved': true};
      } else if (tc.state == ToolCallState.rejected) {
        part['state'] = 'result';
        part['result'] = {'error': 'User rejected this action'};
      } else {
        part['state'] = 'call';
      }

      parts.add(part);
    }

    return {
      'id': 'msg_${timestamp.millisecondsSinceEpoch}',
      'role': role == ChatRole.user ? 'user' : 'assistant',
      'parts': parts,
    };
  }
}
