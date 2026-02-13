import 'package:corevia_mobile/core/providers/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:corevia_mobile/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Créez des instances des notifiers au lieu de ValueNotifier
    OnboardingNotifier onboardingNotifier = OnboardingNotifier(true); // Ou l'état que tu souhaites
    AuthNotifier authNotifier = AuthNotifier(false); // Ou l'état que tu souhaites

    // Pompez le widget avec les notifiers corrects
    await tester.pumpWidget(MyApp(
      onboardingNotifier: onboardingNotifier,
      authNotifier: authNotifier,
    ));

    // Continue avec les tests...
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap sur l'icône '+' et triggerez un frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Vérifiez que le compteur a été incrémenté.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
