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

import 'dart:io';

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../TokenUtils/export_token_util.dart';
import '../../../l10n/l10n.dart';

class LocalBackupsBottomSheet extends StatefulWidget {
  const LocalBackupsBottomSheet({
    super.key,
    required this.onSelected,
  });

  final Function(FileSystemEntity) onSelected;

  @override
  LocalBackupsBottomSheetState createState() => LocalBackupsBottomSheetState();
}

class LocalBackupsBottomSheetState
    extends BaseDynamicState<LocalBackupsBottomSheet> {
  List<FileSystemEntity> files = const [];
  List<FileSystemEntity> defaultPathBackupFiles = const [];

  @override
  void initState() {
    ExportTokenUtil.getLocalBackups().then((value) {
      setState(() {
        files = value[0];
        defaultPathBackupFiles = value[1];
        files.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
        defaultPathBackupFiles.sort(
            (a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      });
    });
    super.initState();
  }

  Radius radius = ChewieDimens.defaultRadius;

  @override
  Widget build(BuildContext context) {
    var mainBody = Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
            top: radius,
            bottom: ResponsiveUtil.isWideDevice() ? radius : Radius.zero),
        color: ChewieTheme.scaffoldBackgroundColor,
        border: ChewieTheme.border,
        boxShadow: ChewieTheme.defaultBoxShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeader(),
          Flexible(
            child: _buildButtons(),
          ),
        ],
      ),
    );
    return ResponsiveUtil.isWideDevice() ? Center(child: mainBody) : mainBody;
  }

  _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: ChewieTheme.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(LucideIcons.hardDrive,
                color: ChewieTheme.primaryColor, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.cloudBackupFiles(
                      files.length + defaultPathBackupFiles.length),
                  style: ChewieTheme.titleMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildButtons() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      itemBuilder: (context, index) => _buildItem(
        index < files.length
            ? files[index]
            : defaultPathBackupFiles[index - files.length],
        index >= files.length,
      ),
      itemCount: files.length + defaultPathBackupFiles.length,
    );
  }

  _buildItem(FileSystemEntity file, bool isDefaultPath) {
    String size = CacheUtil.renderSize(file.statSync().size.toDouble(),
        fractionDigits: 0);
    String time = TimeUtil.formatTimestamp(
        file.statSync().modified.millisecondsSinceEpoch);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ChewieTheme.canvasColor,
        borderRadius: ChewieDimens.borderRadius12,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ChewieTheme.primaryColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.fileArchive,
                size: 17, color: ChewieTheme.primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FileUtil.getFileNameWithExtension(file.path),
                  style: ChewieTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "$time  ·  $size",
                  style: ChewieTheme.bodySmall.copyWith(
                    color: ChewieTheme.bodyMedium.color?.withAlpha(120),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isDefaultPath)
                  Text(
                    appLocalizations.fromInternalBackupPath,
                    style: ChewieTheme.bodySmall.copyWith(
                      color: ChewieTheme.bodyMedium.color?.withAlpha(120),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          CircleIconButton(
            icon: Icon(LucideIcons.import,
                size: 18, color: ChewieTheme.primaryColor),
            onTap: () async {
              Navigator.pop(context);
              widget.onSelected(file);
            },
          ),
          CircleIconButton(
            icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 18),
            onTap: () async {
              CustomLoadingDialog.showLoading(title: appLocalizations.deleting);
              try {
                await file.delete();
                setState(() {
                  files.remove(file);
                });
                IToast.showTop(appLocalizations.deleteSuccess);
              } catch (e, t) {
                ILogger.error("Failed to delete backup file from local", e, t);
                IToast.showTop(appLocalizations.deleteFailed);
              }
              CustomLoadingDialog.dismissLoading();
            },
          ),
        ],
      ),
    );
  }
}
