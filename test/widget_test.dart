import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:z_movie_maker/main.dart';

void main() {
  testWidgets('App smoke test loads ZMovieMakerApp without crashing', (WidgetTester tester) async {
    // Set virtual desktop window size
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: ZMovieMakerApp(),
      ),
    );

    expect(find.byType(ZMovieMakerApp), findsOneWidget);
  });
}
