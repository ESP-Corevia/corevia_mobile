import 'package:flutter_test/flutter_test.dart';
import 'package:corevia_mobile/core/routes/route_persistence.dart';
import 'package:corevia_mobile/core/utils/validators.dart';
import 'package:corevia_mobile/features/ai_chat/domain/chat_message.dart';

void main() {
  group('Validators', () {
    test('accepts a valid email and rejects malformed input', () {
      expect(Validators.validateEmail('patient@example.com'), isNull);
      expect(
        Validators.validateEmail('not-an-email'),
        'Please enter a valid email address',
      );
    });

    test('enforces strong password rules when requested', () {
      expect(
        Validators.validatePassword('password', requireStrongRules: true),
        'Password must contain at least one uppercase letter',
      );
      expect(
        Validators.validatePassword('StrongPass1!', requireStrongRules: true),
        isNull,
      );
    });
  });

  group('Restorable routes', () {
    test('rejects transient and booking confirmation routes', () {
      expect(isRestorableRoute('/login'), isFalse);
      expect(isRestorableRoute('/onboarding'), isFalse);
      expect(isRestorableRoute('/calendar/booking/confirmation'), isFalse);
      expect(isRestorableRoute('/appointments'), isTrue);
    });

    test('falls back to the authenticated home route for unsafe values', () {
      expect(sanitizeRestorableRoute(null), '/home');
      expect(sanitizeRestorableRoute('/login'), '/home');
      expect(
          sanitizeRestorableRoute('/calendar?tab=list'), '/calendar?tab=list');
    });
  });

  group('ChatMessage API serialization', () {
    test('serializes tool approvals using the AI SDK message shape', () {
      final message = ChatMessage(
        role: ChatRole.assistant,
        content: 'Action required',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1234),
        toolCalls: [
          ToolCallInfo(
            toolCallId: 'tool-1',
            toolName: 'mark_intake_taken',
            approvalId: 'approval-1',
            args: {'intakeId': 'intake-1'},
            state: ToolCallState.approved,
          ),
        ],
      );

      final payload = message.toApiMessage();
      final parts = (payload['parts'] as List).cast<Map<String, dynamic>>();
      expect(payload['role'], 'assistant');
      expect(payload['id'], 'msg_1234');
      expect(parts.any((part) => part['type'] == 'step-start'), isTrue);
      final toolPart = parts.firstWhere(
        (part) => part['type'] == 'tool-mark_intake_taken',
      );
      expect(toolPart['approval'], {
        'id': 'approval-1',
        'approved': true,
      });
    });
  });
}
