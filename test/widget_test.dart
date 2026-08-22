import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:corevia_mobile/main.dart';
import 'package:corevia_mobile/core/providers/notifiers.dart';
import 'package:corevia_mobile/core/routes/app_router.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final onboardingNotifier = OnboardingNotifier(true);
    final authNotifier = AuthNotifier(false);
    final router = createRouter(onboardingNotifier, authNotifier);

    await tester.pumpWidget(
      ChangeNotifierProvider<LocaleNotifier>.value(
        value: LocaleNotifier(null),
        child: MyApp(router: router),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
