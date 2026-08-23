import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackState {
  final double currentTime;
  final bool isPlaying;
  final int selectedClipIndex;
  final int selectedOverlayIndex;
  final double volume;
  final bool isMuted;
  final bool isFullscreen;
  final bool isTransitionDrawerOpen;
  final int activeTransitionClipIndex;

  const PlaybackState({
    this.currentTime = 0.0,
    this.isPlaying = false,
    this.selectedClipIndex = -1,
    this.selectedOverlayIndex = -1,
    this.volume = 1.0,
    this.isMuted = false,
    this.isFullscreen = false,
    this.isTransitionDrawerOpen = false,
    this.activeTransitionClipIndex = -1,
  });

  PlaybackState copyWith({
    double? currentTime,
    bool? isPlaying,
    int? selectedClipIndex,
    int? selectedOverlayIndex,
    double? volume,
    bool? isMuted,
    bool? isFullscreen,
    bool? isTransitionDrawerOpen,
    int? activeTransitionClipIndex,
  }) {
    return PlaybackState(
      currentTime: currentTime ?? this.currentTime,
      isPlaying: isPlaying ?? this.isPlaying,
      selectedClipIndex: selectedClipIndex ?? this.selectedClipIndex,
      selectedOverlayIndex: selectedOverlayIndex ?? this.selectedOverlayIndex,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isTransitionDrawerOpen: isTransitionDrawerOpen ?? this.isTransitionDrawerOpen,
      activeTransitionClipIndex: activeTransitionClipIndex ?? this.activeTransitionClipIndex,
    );
  }

  /// Formats seconds into standard Animotica timecode: M:SS:F.FF (e.g. 0:00:4.00)
  static String formatTimecode(double seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds < 0) return '0:00:0.00';
    final int mins = seconds ~/ 60;
    final double remSecs = seconds % 60;
    final int secInt = remSecs.toInt();
    final int centis = ((remSecs - secInt) * 100).toInt();

    final mStr = mins.toString();
    final sStr = secInt.toString().padLeft(2, '0');
    final cStr = centis.toString().padLeft(2, '0');
    return '$mStr:$sStr:$cStr';
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(const PlaybackState());

  void setPlaying(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void seekTo(double timeSeconds, double maxDuration) {
    final clamped = timeSeconds.clamp(0.0, maxDuration > 0 ? maxDuration : 0.0);
    state = state.copyWith(currentTime: clamped);
  }

  void stepFrameForward(double maxDuration, {double frameStep = 1.0 / 30.0}) {
    final newTime = (state.currentTime + frameStep).clamp(0.0, maxDuration);
    state = state.copyWith(currentTime: newTime, isPlaying: false);
  }

  void stepFrameBackward({double frameStep = 1.0 / 30.0}) {
    final newTime = (state.currentTime - frameStep).clamp(0.0, 999999.0);
    state = state.copyWith(currentTime: newTime, isPlaying: false);
  }

  void selectClip(int index) {
    state = state.copyWith(selectedClipIndex: index, selectedOverlayIndex: -1);
  }

  void selectOverlay(int index) {
    state = state.copyWith(selectedOverlayIndex: index, selectedClipIndex: -1);
  }

  void setVolume(double vol) {
    state = state.copyWith(volume: vol.clamp(0.0, 2.0));
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void openTransitionDrawer(int clipIndex) {
    state = state.copyWith(
      isTransitionDrawerOpen: true,
      activeTransitionClipIndex: clipIndex,
    );
  }

  void closeTransitionDrawer() {
    state = state.copyWith(
      isTransitionDrawerOpen: false,
      activeTransitionClipIndex: -1,
    );
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier();
});
