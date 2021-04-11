import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ProgressBar widget exists', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProgressBar(
        progress: Duration.zero,
        total: Duration(minutes: 5),
      ),
    );

    final progressBarFinder = find.byType(ProgressBar);
    expect(progressBarFinder, findsOneWidget);
  });

  testWidgets('ProgressBar widget properties exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProgressBar(
        progress: Duration.zero,
        total: Duration(minutes: 5),
        buffered: Duration(minutes: 1),
        onSeek: (duration) {},
        barHeight: 2.0,
        baseBarColor: Color(0x00000000),
        progressBarColor: Color(0x00000000),
        bufferedBarColor: Color(0x00000000),
        thumbRadius: 20.0,
        thumbColor: Color(0x00000000),
        timeLabelLocation: TimeLabelLocation.sides,
        timeLabelTextStyle: const TextStyle(color: Color(0x00000000)),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    expect(progressBar.progress, Duration.zero);
    expect(progressBar.total, Duration(minutes: 5));
    expect(progressBar.buffered, Duration(minutes: 1));
    expect(progressBar.onSeek, isNotNull);
    expect(progressBar.barHeight, 2.0);
    expect(progressBar.baseBarColor, Color(0x00000000));
    expect(progressBar.progressBarColor, Color(0x00000000));
    expect(progressBar.bufferedBarColor, Color(0x00000000));
    expect(progressBar.thumbRadius, 20.0);
    expect(progressBar.thumbColor, Color(0x00000000));
    expect(progressBar.timeLabelLocation, TimeLabelLocation.sides);
    expect(progressBar.timeLabelTextStyle,
        const TextStyle(color: Color(0x00000000)));
  });

  testWidgets('TimeLabelLocation.below size correct',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: ProgressBar(
          progress: Duration.zero,
          total: Duration(minutes: 5),
          timeLabelLocation: TimeLabelLocation.below,
        ),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    final baseSize = tester.getSize(find.byType(ProgressBar));
    expect(baseSize.width, equals(800.0));
    expect(baseSize.height, equals(34.0));
  });

  testWidgets('TimeLabelLocation.sides size correct',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: ProgressBar(
          progress: Duration.zero,
          total: Duration(minutes: 5),
          timeLabelLocation: TimeLabelLocation.sides,
        ),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    final baseSize = tester.getSize(find.byType(ProgressBar));
    expect(baseSize.width, equals(800.0));
    expect(baseSize.height, equals(20.0));
  });

  testWidgets('TimeLabelLocation.none size correct',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: ProgressBar(
          progress: Duration.zero,
          total: Duration(minutes: 5),
          timeLabelLocation: TimeLabelLocation.none,
        ),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    final baseSize = tester.getSize(find.byType(ProgressBar));
    expect(baseSize.width, equals(800.0));
    expect(baseSize.height, equals(20.0));
  });

  testWidgets('ProgressBar default size is TimeLabelLocation.below',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: ProgressBar(
          progress: Duration.zero,
          total: Duration(minutes: 5),
        ),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    final baseSize = tester.getSize(find.byType(ProgressBar));
    expect(baseSize.width, equals(800.0));
    expect(baseSize.height, equals(34.0));
  });

  testWidgets('Changing the thumb radius changes the widget size',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: ProgressBar(
          progress: Duration.zero,
          total: Duration(minutes: 5),
          thumbRadius: 30,
          timeLabelLocation: TimeLabelLocation.none,
        ),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    final baseSize = tester.getSize(find.byType(ProgressBar));
    expect(baseSize.width, equals(800.0));
    expect(baseSize.height, equals(60.0));
  });

  testWidgets(
      'The height is the max of the font and thumb radius for TimeLabelLocation.sides',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      Center(
        child: ProgressBar(
          progress: Duration.zero,
          total: Duration(minutes: 5),
          thumbRadius: 5,
          timeLabelLocation: TimeLabelLocation.sides,
        ),
      ),
    );

    ProgressBar progressBar = tester.firstWidget(find.byType(ProgressBar));
    expect(progressBar, isNotNull);

    final baseSize = tester.getSize(find.byType(ProgressBar));
    expect(baseSize.width, equals(800.0));
    expect(baseSize.height, equals(14.0));
  });
}
