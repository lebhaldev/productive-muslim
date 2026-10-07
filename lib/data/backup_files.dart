import 'dart:convert';

import 'package:file_picker/file_picker.dart';

/// Where backup files go: the Android file picker, faked in tests.
class BackupFiles {
  const BackupFiles();

  /// Asks where to save [contents]. Returns false if the user cancels.
  Future<bool> save(String fileName, String contents) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: utf8.encode(contents),
      mimeType: 'application/json',
      dialogTitle: 'Save Nurday backup',
    );
    return uri != null;
  }

  /// Asks for a backup file. Returns null if the user cancels.
  Future<String?> open() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Choose a Nurday backup',
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes(), allowMalformed: true);
  }
}
