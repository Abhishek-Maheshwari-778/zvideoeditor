import 'package:flutter_test/flutter_test.dart';
import 'package:z_movie_maker/models/project_model.dart';
import 'package:z_movie_maker/models/clip_model.dart';
import 'package:z_movie_maker/models/transition_model.dart';
import 'package:z_movie_maker/engine/ffmpeg/filter_graph_builder.dart';

void main() {
  group('FilterGraphBuilder Tests', () {
    test('Builds valid FFmpeg command for single solid color clip', () {
      final clip = ClipModel(
        id: 'c1',
        type: ClipType.solidColor,
        name: 'Black Background',
        solidColorHex: '#000000',
        duration: 5.0,
      );

      final project = ProjectModel(
        id: 'p1',
        title: 'SingleClipProject',
        exportWidth: 1920,
        exportHeight: 1080,
        fps: 60,
        clips: [clip],
      );

      final command = FilterGraphBuilder.buildProjectExportCommand(
        project: project,
        outputPath: 'C:/test_output.mp4',
      );

      expect(command.contains('-filter_complex'), isTrue);
      expect(command.contains('scale=1920:1080:force_original_aspect_ratio=decrease'), isTrue);
      expect(command.contains('-r'), isTrue);
      expect(command.contains('60'), isTrue);
      expect(command.last, equals('C:/test_output.mp4'));
    });

    test('Chains xfade transitions between two clips', () {
      final clip1 = ClipModel(
        id: 'c1',
        type: ClipType.solidColor,
        name: 'Clip 1',
        duration: 4.0,
        transitionAfter: const TransitionModel(
          id: 't1',
          type: TransitionType.fadeBlack,
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

      final command = FilterGraphBuilder.buildProjectExportCommand(
        project: project,
        outputPath: 'C:/transition_test.mp4',
      );

      final filterIndex = command.indexOf('-filter_complex');
      expect(filterIndex, isNot(-1));
      final filterString = command[filterIndex + 1];

      expect(filterString.contains('xfade=transition=fadeblack'), isTrue);
    });
  });
}
