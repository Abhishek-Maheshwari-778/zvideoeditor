import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/project_model.dart';

class ProjectStorageService {
  static Timer? _autoSaveTimer;
  static ProjectModel? _lastAutoSavedProject;

  /// Starts the background periodic auto-save (every 60 seconds)
  static void startAutoSave(ProjectModel Function() getCurrentProject) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      final project = getCurrentProject();
      if (project.clips.isEmpty && project.overlays.isEmpty) return;

      try {
        final appDir = await getApplicationSupportDirectory();
        final autoSaveDir = Directory(p.join(appDir.path, 'autosaves'));
        if (!await autoSaveDir.exists()) {
          await autoSaveDir.create(recursive: true);
        }

        final autoSaveFile = File(p.join(autoSaveDir.path, 'project_autosave.openanimotica.bak'));
        final jsonString = jsonEncode(project.toJson());
        await autoSaveFile.writeAsString(jsonString);
        _lastAutoSavedProject = project;
        debugPrint('[AutoSave] Project state snapshot backed up successfully at ${DateTime.now()}');
      } catch (e) {
        debugPrint('[AutoSave] Backup failed: $e');
      }
    });
  }

  /// Stops background auto-save timer
  static void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Checks if an auto-save recovery file exists from a previous session
  static Future<ProjectModel?> checkAutoSaveRecovery() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final autoSaveFile = File(p.join(appDir.path, 'autosaves', 'project_autosave.openanimotica.bak'));
      if (await autoSaveFile.exists()) {
        final content = await autoSaveFile.readAsString();
        final Map<String, dynamic> json = jsonDecode(content);
        return ProjectModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('[AutoSave] Error reading recovery file: $e');
    }
    return null;
  }

  /// Clears the autosave recovery file after explicit user save or discard
  static Future<void> clearAutoSave() async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final autoSaveFile = File(p.join(appDir.path, 'autosaves', 'project_autosave.openanimotica.bak'));
      if (await autoSaveFile.exists()) {
        await autoSaveFile.delete();
      }
    } catch (_) {}
  }

  /// Prompts the user to save the current project state to an .openanimotica JSON file
  static Future<String?> saveProjectToFile(ProjectModel project) async {
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Z-Movie Maker Project',
      fileName: '${project.title}.openanimotica',
      type: FileType.custom,
      allowedExtensions: ['openanimotica', 'json'],
    );

    if (savePath == null) return null;

    final file = File(savePath.endsWith('.openanimotica') ? savePath : '$savePath.openanimotica');
    final jsonString = const JsonEncoder.withIndent('  ').convert(project.toJson());
    await file.writeAsString(jsonString);
    return file.path;
  }

  /// Prompts the user to open an existing .openanimotica / .json project file
  static Future<ProjectModel?> openProjectFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open Z-Movie Maker Project',
      type: FileType.custom,
      allowedExtensions: ['openanimotica', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> json = jsonDecode(content);
      return ProjectModel.fromJson(json);
    }
    return null;
  }
}
