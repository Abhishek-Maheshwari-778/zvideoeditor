import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/project_model.dart';
import '../models/clip_model.dart';
import '../models/transition_model.dart';
import '../models/overlay_layer_model.dart';

class ProjectNotifier extends StateNotifier<ProjectModel> {
  final List<ProjectModel> _undoStack = [];
  final List<ProjectModel> _redoStack = [];
  static const _uuid = Uuid();

  ProjectNotifier()
      : super(
          ProjectModel(
            id: 'proj-${const Uuid().v4().substring(0, 8)}',
            title: 'Untitled_Project',
          ),
        );

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _pushUndo() {
    _undoStack.add(state);
    _redoStack.clear();
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }

  void undo() {
    if (canUndo) {
      _redoStack.add(state);
      state = _undoStack.removeLast();
    }
  }

  void redo() {
    if (canRedo) {
      _undoStack.add(state);
      state = _redoStack.removeLast();
    }
  }

  void loadProject(ProjectModel project) {
    _undoStack.clear();
    _redoStack.clear();
    state = project;
  }

  void updateTitle(String newTitle) {
    _pushUndo();
    state = state.copyWith(title: newTitle);
  }

  void updateAspectRatio(CanvasAspectRatio ratio) {
    _pushUndo();
    state = state.copyWith(
      aspectRatio: ratio,
      exportWidth: ratio.defaultWidth,
      exportHeight: ratio.defaultHeight,
    );
  }

  void addClip(ClipModel clip) {
    _pushUndo();
    final updatedClips = List<ClipModel>.from(state.clips)..add(clip);
    state = state.copyWith(clips: updatedClips);
  }

  void removeClipAt(int index) {
    if (index >= 0 && index < state.clips.length) {
      _pushUndo();
      final updatedClips = List<ClipModel>.from(state.clips)..removeAt(index);
      state = state.copyWith(clips: updatedClips);
    }
  }

  void duplicateClipAt(int index) {
    if (index >= 0 && index < state.clips.length) {
      _pushUndo();
      final original = state.clips[index];
      final duplicate = original.copyWith(
        id: 'clip-${_uuid.v4().substring(0, 8)}',
        name: '${original.name} (Copy)',
      );
      final updatedClips = List<ClipModel>.from(state.clips)..insert(index + 1, duplicate);
      state = state.copyWith(clips: updatedClips);
    }
  }

  void updateClip(int index, ClipModel updatedClip) {
    if (index >= 0 && index < state.clips.length) {
      _pushUndo();
      final updatedClips = List<ClipModel>.from(state.clips);
      updatedClips[index] = updatedClip;
      state = state.copyWith(clips: updatedClips);
    }
  }

  /// Splits a clip into two distinct clips at the given split point (in seconds relative to clip start)
  void splitClipAt(int index, double splitOffsetSeconds) {
    if (index < 0 || index >= state.clips.length) return;
    final clip = state.clips[index];

    if (splitOffsetSeconds <= 0.2 || splitOffsetSeconds >= clip.duration - 0.2) {
      return; // Too close to boundaries
    }

    _pushUndo();
    final firstPart = clip.copyWith(
      id: 'clip-${_uuid.v4().substring(0, 8)}',
      duration: splitOffsetSeconds,
      sourceTrimOut: clip.sourceTrimIn + splitOffsetSeconds,
      transitionAfter: null,
    );

    final secondPart = clip.copyWith(
      id: 'clip-${_uuid.v4().substring(0, 8)}',
      duration: clip.duration - splitOffsetSeconds,
      sourceTrimIn: clip.sourceTrimIn + splitOffsetSeconds,
    );

    final updatedClips = List<ClipModel>.from(state.clips)
      ..removeAt(index)
      ..insert(index, firstPart)
      ..insert(index + 1, secondPart);

    state = state.copyWith(clips: updatedClips);
  }

  void setTransition(int clipIndex, TransitionModel? transition) {
    if (clipIndex >= 0 && clipIndex < state.clips.length) {
      _pushUndo();
      final updatedClips = List<ClipModel>.from(state.clips);
      updatedClips[clipIndex] = updatedClips[clipIndex].copyWith(transitionAfter: transition);
      state = state.copyWith(clips: updatedClips);
    }
  }

  void addOverlay(OverlayLayerModel overlay) {
    _pushUndo();
    final updatedOverlays = List<OverlayLayerModel>.from(state.overlays)..add(overlay);
    state = state.copyWith(overlays: updatedOverlays);
  }

  void removeOverlayAt(int index) {
    if (index >= 0 && index < state.overlays.length) {
      _pushUndo();
      final updatedOverlays = List<OverlayLayerModel>.from(state.overlays)..removeAt(index);
      state = state.copyWith(overlays: updatedOverlays);
    }
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectModel>((ref) {
  return ProjectNotifier();
});
