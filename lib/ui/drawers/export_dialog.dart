import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../models/project_model.dart';
import '../../engine/ffmpeg/filter_graph_builder.dart';
import '../../engine/ffmpeg/ffmpeg_manager.dart';

class ExportDialog extends StatefulWidget {
  final ProjectModel project;

  const ExportDialog({super.key, required this.project});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  String selectedResolution = '1080p (Full HD)';
  int selectedFps = 60;
  bool isRendering = false;
  double progress = 0.0;
  String statusText = 'Ready to export';

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
                const Text('Export Video Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                if (!isRendering)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (!isRendering) ...[
              const Text('Resolution', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedResolution,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: '720p (HD)', child: Text('720p (HD 1280x720)')),
                  DropdownMenuItem(value: '1080p (Full HD)', child: Text('1080p (Full HD 1920x1080)')),
                  DropdownMenuItem(value: '4K (Ultra HD)', child: Text('4K (Ultra HD 3840x2160)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => selectedResolution = val);
                },
              ),
              const SizedBox(height: 16),

              const Text('Frame Rate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('30 FPS'),
                    selected: selectedFps == 30,
                    onSelected: (_) => setState(() => selectedFps = 30),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('60 FPS (Smooth)'),
                    selected: selectedFps == 60,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) => setState(() => selectedFps = 60),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text('Save & Render MP4', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: _startExport,
                ),
              ),
            ] else ...[
              Text(statusText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress > 0 ? progress : null,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text('${(progress * 100).toInt()}% completed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    FFmpegManager().cancelActiveTask();
                    setState(() => isRendering = false);
                  },
                  child: const Text('Cancel Export', style: TextStyle(color: Colors.red)),
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
      statusText = 'Initializing render pipeline...';
    });

    int outW = 1920;
    int outH = 1080;
    if (selectedResolution.startsWith('720p')) {
      outW = 1280;
      outH = 720;
    } else if (selectedResolution.startsWith('4K')) {
      outW = 3840;
      outH = 2160;
    }

    final renderProject = widget.project.copyWith(
      exportWidth: outW,
      exportHeight: outH,
      fps: selectedFps,
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
            SnackBar(
              content: Text('Video exported successfully: $savePath'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            isRendering = false;
            statusText = 'Export failed. Please check source clips.';
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
