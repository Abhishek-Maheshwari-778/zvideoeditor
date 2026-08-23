import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:z_movie_maker/main.dart';

void main() {
  testWidgets('App smoke test loads ZMovieMakerApp without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ZMovieMakerApp(),
      ),
    );

    expect(find.byType(ZMovieMakerApp), findsOneWidget);
  });
}
