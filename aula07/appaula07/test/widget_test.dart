import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:appaula07/data/carrinho_provider.dart';
import 'package:appaula07/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CarrinhoProvider(),
        child: const SMHotelApp(),
      ),
    );

    expect(find.text('S&M Hotel'), findsWidgets);
  });
}
