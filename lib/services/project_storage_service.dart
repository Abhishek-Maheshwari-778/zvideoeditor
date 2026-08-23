import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/project_model.dart';

class ProjectStorageService {
  /// Prompts user to pick a project file and loads the ProjectModel
  static Future<ProjectModel?> openProjectFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open Z-Movie Maker Project',
      type: FileType.custom,
      allowedExtensions: ['openanimotica', 'zmovie', 'json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      try {
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return ProjectModel.fromJson(json);
      } catch (e) {
        debugPrint('[ProjectStorage] Failed to read project: $e');
      }
    }
    return null;
  }

  /// Prompts user to save the current project
  static Future<String?> saveProjectToFile(ProjectModel project) async {
    final defaultFileName = '${project.title.replaceAll(' ', '_')}.openanimotica';
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Project',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['openanimotica', 'zmovie', 'json'],
    );

    if (result != null) {
      final file = File(result);
      final jsonStr = const JsonEncoder.withIndent('  ').convert(project.toJson());
      await file.writeAsString(jsonStr);
      return result;
    }
    return null;
  }

  /// Saves an auto-recovery draft in app cache directory
  static Future<void> saveAutoSaveDraft(ProjectModel project) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final draftFile = File(p.join(appDir.path, 'autosave_project.json'));
      final jsonStr = jsonEncode(project.toJson());
      await draftFile.writeAsString(jsonStr);
    } catch (_) {}
  }
}
