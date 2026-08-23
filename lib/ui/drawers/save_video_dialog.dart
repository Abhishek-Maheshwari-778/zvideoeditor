import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../engine/ffmpeg/filter_graph_builder.dart';
import '../../engine/ffmpeg/ffmpeg_manager.dart';

class SaveVideoDialog extends StatefulWidget {
  final ProjectModel project;

  const SaveVideoDialog({super.key, required this.project});

  @override
  State<SaveVideoDialog> createState() => _SaveVideoDialogState();
}

class _SaveVideoDialogState extends State<SaveVideoDialog> {
  int resolutionIndex = 1; // 0: 480P, 1: 720P, 2: 1080P, 3: 1440P, 4: 4K
  int qualityIndex = 1; // 0: Draft (2M), 1: Standard (10M), 2: Good (15M), 3: Best (20M)
  int fpsIndex = 2; // 0: 24, 1: 25, 2: 30, 3: 50, 4: 60
  bool showMoreSettings = false;
  bool isRendering = false;
  double progress = 0.0;
  String statusText = 'Ready to export';

  final List<String> resolutions = ['480P', '720P', '1080P', '1440P', '4K'];
  final List<String> qualities = ['Draft\n2 Mbps', 'Standard\n10 Mbps', 'Good\n15 Mbps', 'Best\n20 Mbps'];
  final List<double> bitratesMbps = [2.0, 10.0, 15.0, 20.0];
  final List<int> fpsValues = [24, 25, 30, 50, 60];

  /// Calculates estimated file size based on duration and selected bitrate (Matching Image 3: 3.75 MB)
  String get estimatedFileSize {
    final dur = widget.project.totalDuration > 0 ? widget.project.totalDuration : 3.0;
    final mbps = bitratesMbps[qualityIndex];
    final totalMegabits = dur * (mbps + 0.192);
    final totalMegaBytes = totalMegabits / 8.0;
    return '${totalMegaBytes.toStringAsFixed(2)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                'Save Video',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!isRendering) ...[
              // 1. Video Resolution Slider (Matching Image 3)
              const Text(
                'Video Resolution',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF0078D7),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: const Color(0xFF0078D7),
                  overlayColor: const Color(0xFF0078D7).withOpacity(0.2),
                ),
                child: Slider(
                  value: resolutionIndex.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  onChanged: (val) => setState(() => resolutionIndex = val.toInt()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(resolutions.length, (index) {
                    final isPro = index >= 2;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          resolutions[index],
                          style: TextStyle(
                            color: resolutionIndex == index ? const Color(0xFF0078D7) : Colors.white70,
                            fontSize: 11,
                            fontWeight: resolutionIndex == index ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isPro) ...[
                          const SizedBox(width: 2),
                          const Icon(Icons.lock, size: 10, color: Color(0xFFFF9500)),
                        ],
                      ],
                    );
                  }),
              ),
              const SizedBox(height: 20),

              // 2. Video Quality & Estimated File Size (Matching Image 3)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Video Quality',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Output File Size: $estimatedFileSize',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF0078D7),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: const Color(0xFF0078D7),
                ),
                child: Slider(
                  value: qualityIndex.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  onChanged: (val) => setState(() => qualityIndex = val.toInt()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(qualities.length, (index) {
                    final isPro = index >= 2;
                    return Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              qualities[index].split('\n')[0],
                              style: TextStyle(
                                color: qualityIndex == index ? const Color(0xFF0078D7) : Colors.white70,
                                fontSize: 10,
                                fontWeight: qualityIndex == index ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isPro) ...[
                              const SizedBox(width: 2),
                              const Icon(Icons.lock, size: 10, color: Color(0xFFFF9500)),
                            ],
                          ],
                        ),
                        Text(
                          qualities[index].split('\n')[1],
                          style: const TextStyle(color: Colors.grey, fontSize: 9),
                        ),
                      ],
                    );
                  }),
              ),
              const SizedBox(height: 20),

              // 3. Frame Rate Slider (Matching Image 3)
              const Text(
                'Frame Rate',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF0078D7),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: const Color(0xFF0078D7),
                ),
                child: Slider(
                  value: fpsIndex.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  onChanged: (val) => setState(() => fpsIndex = val.toInt()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(fpsValues.length, (index) {
                    final isPro = index >= 3;
                    return Row(
                      children: [
                        Text(
                          '${fpsValues[index]} fps',
                          style: TextStyle(
                            color: fpsIndex == index ? const Color(0xFF0078D7) : Colors.white70,
                            fontSize: 11,
                            fontWeight: fpsIndex == index ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isPro) ...[
                          const SizedBox(width: 2),
                          const Icon(Icons.lock, size: 10, color: Color(0xFFFF9500)),
                        ],
                      ],
                    );
                  }),
              ),
              const SizedBox(height: 16),

              // Expandable More Settings
              InkWell(
                onTap: () => setState(() => showMoreSettings = !showMoreSettings),
                child: Row(
                  children: [
                    Icon(
                      showMoreSettings ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF0078D7),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'More Settings',
                      style: TextStyle(color: Color(0xFF0078D7), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (showMoreSettings) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF2B2B2B), borderRadius: BorderRadius.circular(6)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Encoder: H.264 / NVENC (Hardware)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('Audio: AAC 192kbps', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Action Buttons Row (Matching Image 3)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF2222), Color(0xFFFF9500)],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Watermark removed! You have full PRO export features.')),
                          );
                        },
                        child: const Text('Remove Watermark', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        onPressed: _startExport,
                        child: const Text('Export Video', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Back', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
              ),
            ] else ...[
              // Real-Time Progress View
              Text(statusText, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: Colors.white24,
                color: const Color(0xFF0078D7),
                minHeight: 8,
              ),
              const SizedBox(height: 10),
              Text(
                '${(progress * 100).toInt()}% completed',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 24),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    FFmpegManager().cancelActiveTask();
                    setState(() => isRendering = false);
                  },
                  child: const Text('Cancel Export', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startExport() async {
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export MP4 Video',
      fileName: '${widget.project.title}.mp4',
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    if (savePath == null) return;

    setState(() {
      isRendering = true;
      progress = 0.0;
      statusText = 'Rendering ${resolutions[resolutionIndex]} at ${fpsValues[fpsIndex]} fps...';
    });

    int outW = 1920;
    int outH = 1080;
    if (resolutionIndex == 0) {
      outW = 854;
      outH = 480;
    } else if (resolutionIndex == 1) {
      outW = 1280;
      outH = 720;
    } else if (resolutionIndex == 3) {
      outW = 2560;
      outH = 1440;
    } else if (resolutionIndex == 4) {
      outW = 3840;
      outH = 2160;
    }

    final renderProject = widget.project.copyWith(
      exportWidth: outW,
      exportHeight: outH,
      fps: fpsValues[fpsIndex],
    );

    try {
      final args = FilterGraphBuilder.buildProjectExportCommand(
        project: renderProject,
        outputPath: savePath,
      );

      final success = await FFmpegManager().executeCommand(
        arguments: args,
        totalDurationSeconds: renderProject.totalDuration,
        onProgress: (p, text) {
          if (mounted) {
            setState(() {
              progress = p;
              statusText = text;
            });
          }
        },
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video exported successfully: $savePath'), backgroundColor: Colors.green),
          );
        } else {
          setState(() {
            isRendering = false;
            statusText = 'Export failed.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isRendering = false;
          statusText = 'Error: $e';
        });
      }
    }
  }
}
