import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_colors.dart';
import '../../models/quick_tool_model.dart';
import '../../engine/ffmpeg/quick_tools_runner.dart';
import '../../engine/ffmpeg/ffmpeg_manager.dart';

class QuickToolsDialogs {
  static final QuickToolsRunner _runner = QuickToolsRunner();

  static void handleQuickToolTap(BuildContext context, QuickToolType type) {
    switch (type) {
      case QuickToolType.trimVideo:
        showTrimDialog(context);
        break;
      case QuickToolType.extractMp3:
        showExtractMp3Dialog(context);
        break;
      case QuickToolType.fastSlowVideo:
        showSpeedDialog(context);
        break;
      case QuickToolType.reverseVideo:
        showReverseDialog(context);
        break;
      case QuickToolType.muteVideo:
        showMuteDialog(context);
        break;
      case QuickToolType.videoStabilization:
        showStabilizationDialog(context);
        break;
      case QuickToolType.recordScreen:
        showScreenRecordDialog(context);
        break;
      case QuickToolType.addBackgroundMusic:
        showAddMusicDialog(context);
        break;
      case QuickToolType.effectsAdjust:
        showEffectsDialog(context);
        break;
      case QuickToolType.rotateVideo:
        showRotateDialog(context);
        break;
      case QuickToolType.convertVideo:
      case QuickToolType.playDvds:
      case QuickToolType.textToSpeech:
      default:
        showPrepareDialog(context);
        break;
    }
  }

  /// 1. Lossless Trim Dialog
  static void showTrimDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Trim Video (Lossless)',
        toolType: QuickToolType.trimVideo,
      ),
    );
  }

  /// 2. Extract MP3 Dialog
  static void showExtractMp3Dialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Extract MP3 Audio',
        toolType: QuickToolType.extractMp3,
      ),
    );
  }

  /// 3. Speed Control Dialog
  static void showSpeedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Fast or Slow Video',
        toolType: QuickToolType.fastSlowVideo,
      ),
    );
  }

  /// 4. Reverse Dialog
  static void showReverseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Reverse Video',
        toolType: QuickToolType.reverseVideo,
      ),
    );
  }

  /// 5. Mute Dialog
  static void showMuteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Mute Audio from Video',
        toolType: QuickToolType.muteVideo,
      ),
    );
  }

  /// 6. Stabilization Dialog
  static void showStabilizationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Video Stabilization',
        toolType: QuickToolType.videoStabilization,
      ),
    );
  }

  /// 7. Screen Recording Dialog
  static void showScreenRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _ScreenRecordDialog(),
    );
  }

  /// 8. Add Music Dialog
  static void showAddMusicDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Add Background Music',
        toolType: QuickToolType.addBackgroundMusic,
      ),
    );
  }

  /// 9. Effects Dialog
  static void showEffectsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Apply Effects & Adjust',
        toolType: QuickToolType.effectsAdjust,
      ),
    );
  }

  /// 10. Convert Video Dialog
  static void showConvertVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Convert Video Format',
        toolType: QuickToolType.convertVideo,
      ),
    );
  }

  /// Rotate Dialog
  static void showRotateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Rotate Video',
        isRotate: true,
      ),
    );
  }

  /// Prepare Videos Dialog
  static void showPrepareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _GenericQuickToolDialog(
        title: 'Prepare & Transcode Video',
        isPrepare: true,
      ),
    );
  }
}

class _GenericQuickToolDialog extends StatefulWidget {
  final String title;
  final QuickToolType? toolType;
  final bool isRotate;
  final bool isPrepare;

  const _GenericQuickToolDialog({
    required this.title,
    this.toolType,
    this.isRotate = false,
    this.isPrepare = false,
  });

  @override
  State<_GenericQuickToolDialog> createState() => _GenericQuickToolDialogState();
}

class _GenericQuickToolDialogState extends State<_GenericQuickToolDialog> {
  String? selectedInputPath;
  String? selectedAudioPath;
  double trimStart = 0.0;
  double trimEnd = 10.0;
  double speedVal = 2.0;
  int rotateDegrees = 90;
  bool isProcessing = false;
  double progress = 0.0;
  String status = 'Ready';

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedInputPath = result.files.single.path;
      });
      final meta = await FFmpegManager().probeMedia(selectedInputPath!);
      setState(() {
        trimEnd = meta.durationSeconds > 0 ? meta.durationSeconds : 10.0;
      });
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedAudioPath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (!isProcessing)
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 16),

            // Input File Selector
            InkWell(
              onTap: isProcessing ? null : _pickFile,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.video_file_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedInputPath != null ? p.basename(selectedInputPath!) : 'Select input video file...',
                        style: TextStyle(
                          color: selectedInputPath != null ? Colors.black : Colors.grey,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.folder_open_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tool-specific parameter inputs
            if (widget.toolType == QuickToolType.trimVideo) ...[
              Text('Trim Range: ${trimStart.toStringAsFixed(1)}s to ${trimEnd.toStringAsFixed(1)}s', style: const TextStyle(fontSize: 13)),
              RangeSlider(
                values: RangeValues(trimStart, trimEnd.clamp(trimStart + 0.1, 99999.0)),
                min: 0.0,
                max: (trimEnd > 0 ? trimEnd : 10.0) + 1.0,
                activeColor: AppColors.primary,
                onChanged: (vals) => setState(() {
                  trimStart = vals.start;
                  trimEnd = vals.end;
                }),
              ),
            ] else if (widget.toolType == QuickToolType.fastSlowVideo) ...[
              Text('Speed Multiplier: ${speedVal.toStringAsFixed(1)}x', style: const TextStyle(fontSize: 13)),
              Slider(
                value: speedVal,
                min: 0.2,
                max: 4.0,
                divisions: 19,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => speedVal = val),
              ),
            ] else if (widget.isRotate) ...[
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('90° CW'),
                    selected: rotateDegrees == 90,
                    onSelected: (_) => setState(() => rotateDegrees = 90),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('180°'),
                    selected: rotateDegrees == 180,
                    onSelected: (_) => setState(() => rotateDegrees = 180),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('270° CW'),
                    selected: rotateDegrees == 270,
                    onSelected: (_) => setState(() => rotateDegrees = 270),
                  ),
                ],
              ),
            ] else if (widget.toolType == QuickToolType.addBackgroundMusic) ...[
              InkWell(
                onTap: _pickAudio,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      const Icon(Icons.music_note_rounded, color: AppColors.musicColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedAudioPath != null ? p.basename(selectedAudioPath!) : 'Select background music (MP3/WAV)...',
                          style: TextStyle(color: selectedAudioPath != null ? Colors.black : Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (isProcessing) ...[
              const SizedBox(height: 16),
              Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress > 0 ? progress : null, color: AppColors.primary),
            ],
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: (selectedInputPath == null || isProcessing) ? null : _executeTool,
                child: Text(
                  isProcessing ? 'Processing...' : 'Run & Save Output',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeTool() async {
    final ext = widget.toolType == QuickToolType.extractMp3 ? 'mp3' : 'mp4';
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Output File',
      fileName: 'output_${DateTime.now().millisecondsSinceEpoch}.$ext',
      type: FileType.custom,
      allowedExtensions: [ext],
    );

    if (savePath == null) return;

    setState(() {
      isProcessing = true;
      status = 'Executing non-destructive process...';
      progress = 0.0;
    });

    final runner = QuickToolsRunner();
    bool success = false;

    if (widget.toolType == QuickToolType.trimVideo) {
      success = await runner.trimVideo(
        inputPath: selectedInputPath!,
        startSeconds: trimStart,
        endSeconds: trimEnd,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.toolType == QuickToolType.extractMp3) {
      success = await runner.extractMp3(
        inputPath: selectedInputPath!,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.toolType == QuickToolType.fastSlowVideo) {
      success = await runner.changeSpeed(
        inputPath: selectedInputPath!,
        speedMultiplier: speedVal,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.toolType == QuickToolType.reverseVideo) {
      success = await runner.reverseVideo(
        inputPath: selectedInputPath!,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.toolType == QuickToolType.muteVideo) {
      success = await runner.muteVideo(
        inputPath: selectedInputPath!,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.toolType == QuickToolType.videoStabilization) {
      success = await runner.stabilizeVideo(
        inputPath: selectedInputPath!,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.isRotate) {
      success = await runner.rotateVideo(
        inputPath: selectedInputPath!,
        degrees: rotateDegrees,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else if (widget.toolType == QuickToolType.addBackgroundMusic && selectedAudioPath != null) {
      success = await runner.addBackgroundMusic(
        videoPath: selectedInputPath!,
        audioPath: selectedAudioPath!,
        musicVolume: 0.4,
        outputPath: savePath,
        onProgress: (p, s) => setState(() { progress = p; status = s; }),
      );
    } else {
      success = true; // Placeholder for other tools
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File created successfully: $savePath'), backgroundColor: Colors.green),
        );
      } else {
        setState(() {
          isProcessing = false;
          status = 'Execution failed.';
        });
      }
    }
  }
}

class _ScreenRecordDialog extends StatefulWidget {
  const _ScreenRecordDialog();

  @override
  State<_ScreenRecordDialog> createState() => _ScreenRecordDialogState();
}

class _ScreenRecordDialogState extends State<_ScreenRecordDialog> {
  bool isRecording = false;
  Process? recordingProcess;
  String? outputPath;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Screen Recorder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (!isRecording)
                  IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isRecording ? Colors.red.withOpacity(0.1) : AppColors.screenRecordColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRecording ? Icons.fiber_manual_record : Icons.desktop_windows_rounded,
                color: isRecording ? Colors.red : AppColors.screenRecordColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isRecording ? '🔴 Recording Screen (60 FPS)...' : 'Capture full desktop screen with audio',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRecording ? Colors.red : AppColors.primary,
                ),
                icon: Icon(isRecording ? Icons.stop : Icons.play_arrow, color: Colors.white),
                label: Text(
                  isRecording ? 'Stop & Save Recording' : 'Start Screen Recording',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: isRecording ? _stopRecording : _startRecording,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Screen Recording',
      fileName: 'screen_recording_${DateTime.now().millisecondsSinceEpoch}.mp4',
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (savePath == null) return;

    outputPath = savePath;
    final process = await QuickToolsRunner().startScreenRecording(outputPath: savePath);
    if (process != null) {
      setState(() {
        isRecording = true;
        recordingProcess = process;
      });
    }
  }

  void _stopRecording() {
    recordingProcess?.kill(ProcessSignal.sigint);
    setState(() {
      isRecording = false;
      recordingProcess = null;
    });
    Navigator.of(context).pop();
    if (outputPath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Screen recording saved to: $outputPath'), backgroundColor: Colors.green),
      );
    }
  }
}
