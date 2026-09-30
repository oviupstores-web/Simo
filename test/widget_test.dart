import 'package:flutter_test/flutter_test.dart';

import 'package:menoo/main.dart';

void main() {
  testWidgets('L\'app démarre et affiche Menoo', (tester) async {
    await tester.pumpWidget(const MenooApp());
    expect(find.text('Menoo'), findsOneWidget);
  });
}
