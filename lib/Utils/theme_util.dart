/*
 * Copyright (c) 2024 Robert-Stackflow.
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.
 * If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:convert';
import 'dart:io';

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

class ThemeUtil {
  static const int _version = 1;

  static String exportThemeToJson(ChewieThemeColorData theme) {
    return jsonEncode({
      'cloudotp_theme_version': _version,
      'theme': theme.toJson(),
    });
  }

  static ChewieThemeColorData? importThemeFromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (!map.containsKey('cloudotp_theme_version') ||
          !map.containsKey('theme')) {
        return null;
      }
      final version = map['cloudotp_theme_version'] as int?;
      if (version == null || version > _version) return null;
      return ChewieThemeColorData.fromJson(
          map['theme'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static void exportToClipboard(
      BuildContext context, ChewieThemeColorData theme) {
    ChewieUtils.copy(context, exportThemeToJson(theme),
        toastText: appLocalizations.themeExportSuccess);
  }

  static Future<bool> exportToFile(ChewieThemeColorData theme) async {
    final json = exportThemeToJson(theme);
    final bytes = Uint8List.fromList(utf8.encode(json));
    final fileName = '${theme.name.replaceAll(RegExp(r'[^\w一-鿿-]'), '_')}.json';
    String? filePath = await FileUtil.saveFile(
      dialogTitle: appLocalizations.exportTheme,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );
    return filePath != null;
  }

  static Future<ChewieThemeColorData?> importFromClipboard() async {
    final data = await ChewieUtils.getClipboardData();
    if (data == null || data.isEmpty) return null;
    return importThemeFromJson(data);
  }

  static Future<ChewieThemeColorData?> importFromFile() async {
    FilePickerResult? result = await FileUtil.pickFiles(
      dialogTitle: appLocalizations.importTheme,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return null;
    final path = result.files.single.path;
    if (path == null) return null;
    final file = File(path);
    final content = await file.readAsString();
    return importThemeFromJson(content);
  }
}
