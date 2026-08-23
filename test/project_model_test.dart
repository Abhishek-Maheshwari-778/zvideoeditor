import 'package:flutter_test/flutter_test.dart';
import 'package:z_movie_maker/models/project_model.dart';
import 'package:z_movie_maker/models/clip_model.dart';
import 'package:z_movie_maker/models/transition_model.dart';

void main() {
  group('ProjectModel Tests', () {
    test('Calculates total duration without transitions correctly', () {
      final clip1 = ClipModel(
        id: 'c1',
        type: ClipType.solidColor,
        name: 'Clip 1',
        duration: 4.0,
      );
      final clip2 = ClipModel(
        id: 'c2',
        type: ClipType.solidColor,
        name: 'Clip 2',
        duration: 5.0,
      );

      final project = ProjectModel(
        id: 'p1',
        clips: [clip1, clip2],
      );

      expect(project.totalDuration, equals(9.0));
    });

    test('Calculates total duration with transition overlap', () {
      final clip1 = ClipModel(
        id: 'c1',
        type: ClipType.solidColor,
        name: 'Clip 1',
        duration: 4.0,
        transitionAfter: const TransitionModel(
          id: 't1',
          type: TransitionType.crossFade,
          duration: 1.0,
        ),
      );
      final clip2 = ClipModel(
        id: 'c2',
        type: ClipType.solidColor,
        name: 'Clip 2',
        duration: 4.0,
      );

      final project = ProjectModel(
        id: 'p1',
        clips: [clip1, clip2],
      );

      // 4.0 + 4.0 - (1.0 / 2) = 7.5
      expect(project.totalDuration, equals(7.5));
    });

    test('Serializes and deserializes JSON project properly', () {
      final clip = ClipModel(
        id: 'c1',
        type: ClipType.gradient,
        name: 'Gradient Clip',
        duration: 6.0,
        gradientColorsHex: ['#8A2387', '#E94057'],
      );

      final original = ProjectModel(
        id: 'proj-123',
        title: 'Vacation Movie',
        aspectRatio: CanvasAspectRatio.ratio9_16,
        clips: [clip],
      );

      final json = original.toJson();
      final restored = ProjectModel.fromJson(json);

      expect(restored.id, equals('proj-123'));
      expect(restored.title, equals('Vacation Movie'));
      expect(restored.aspectRatio, equals(CanvasAspectRatio.ratio9_16));
      expect(restored.clips.length, equals(1));
      expect(restored.clips.first.name, equals('Gradient Clip'));
    });
  });
}
