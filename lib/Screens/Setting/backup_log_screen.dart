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

import 'dart:math';

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:cloudotp/Models/auto_backup_log.dart';
import 'package:cloudotp/Screens/Setting/setting_backup_screen.dart';
import 'package:cloudotp/Screens/Setting/setting_navigation_screen.dart';
import 'package:cloudotp/Utils/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../Database/config_dao.dart';
import '../../l10n/l10n.dart';

class BackupLogScreen extends StatefulWidget {
  final bool isOverlay;

  const BackupLogScreen({
    super.key,
    this.isOverlay = false,
  });

  static void show(BuildContext context) {
    if (ResponsiveUtil.isLandscapeLayout()) {
      BottomSheetBuilder.showGenericContextMenu(
        context,
        const BackupLogScreen(isOverlay: true),
      );
    } else {
      BottomSheetBuilder.showBottomSheet(
        context,
        (ctx) => const BackupLogScreen(),
        responsive: true,
      );
    }
  }

  @override
  BackupLogScreenState createState() => BackupLogScreenState();
}

class BackupLogScreenState extends BaseDynamicState<BackupLogScreen> {
  String _autoBackupPassword = "";

  bool get canBackup => _autoBackupPassword.isNotEmpty;

  Color get _accent => ChewieTheme.primaryColor;

  Radius get _radius => ChewieDimens.defaultRadius;

  @override
  void initState() {
    super.initState();
    ConfigDao.getConfig().then((config) {
      setState(() {
        _autoBackupPassword = config.backupPassword;
      });
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (appProvider.autoBackupLoadingStatus == LoadingStatus.failed) {
        appProvider.autoBackupLoadingStatus = LoadingStatus.none;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget header = Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: _buildHeader(),
    );

    Widget body = _buildLogList();

    if (widget.isOverlay) {
      final overlayHeight = appProvider.autoBackupLogs.isEmpty || !canBackup
          ? 200.0
          : 400.0;
      return Container(
        width: min(300, MediaQuery.sizeOf(context).width - 80),
        height: min(overlayHeight, MediaQuery.sizeOf(context).height - 80),
        decoration: BoxDecoration(
          color: ChewieTheme.scaffoldBackgroundColor,
          borderRadius: ChewieDimens.borderRadius8,
          border: ChewieTheme.border,
          boxShadow: ChewieTheme.defaultBoxShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            header,
            Expanded(child: body),
          ],
        ),
      );
    }

    return Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.65,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: _radius,
              bottom: ResponsiveUtil.isWideDevice() ? _radius : Radius.zero,
            ),
            color: ChewieTheme.scaffoldBackgroundColor,
            border: ChewieTheme.border,
            boxShadow: ChewieTheme.defaultBoxShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              header,
              Flexible(child: body),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _accent.withAlpha(30),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(LucideIcons.history, color: _accent, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocalizations.backupLogs,
                style: ChewieTheme.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 1),
              Text(
                appLocalizations.backupLogSubtitle,
                style: ChewieTheme.bodySmall.copyWith(
                  color: ChewieTheme.bodyMedium.color?.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
        if (canBackup && appProvider.autoBackupLogs.isNotEmpty)
          CircleIconButton(
            icon: Icon(LucideIcons.trash2, size: 16, color: _accent),
            onTap: clear,
          ),
      ],
    );
  }

  clear() {
    appProvider.clearAutoBackupLogs();
    appProvider.autoBackupLoadingStatus = LoadingStatus.none;
    setState(() {});
  }

  Widget _buildLogList() {
    if (!canBackup) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appLocalizations.haveNotSetBackupPassword,
              style: ChewieTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            RoundIconTextButton(
              height: 36,
              text: appLocalizations.goToSetBackupPassword,
              background: _accent,
              onPressed: () {
                if (widget.isOverlay) {
                  RouteUtil.pushDialogRoute(context,
                      const SettingNavigationScreen(initPageIndex: 3));
                } else {
                  Navigator.pop(context);
                  RouteUtil.pushCupertinoRoute(
                      context,
                      const BackupSettingScreen(
                          jumpToAutoBackupPassword: true));
                }
              },
            ),
          ],
        ),
      );
    }

    if (appProvider.autoBackupLogs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child:
            EmptyPlaceholder(text: appLocalizations.noBackupLogs, topPadding: 10),
      );
    }

    if (widget.isOverlay) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            appProvider.autoBackupLogs.length,
            (index) => BackupLogItem(
              log: appProvider.autoBackupLogs[index],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      shrinkWrap: true,
      itemCount: appProvider.autoBackupLogs.length,
      itemBuilder: (context, index) {
        return BackupLogItem(
          log: appProvider.autoBackupLogs[index],
        );
      },
    );
  }
}

class BackupLogItem extends StatefulWidget {
  final AutoBackupLog log;

  const BackupLogItem({super.key, required this.log});

  @override
  BackupLogItemState createState() => BackupLogItemState();
}

class BackupLogItemState extends BaseDynamicState<BackupLogItem> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: ChewieTheme.canvasColor,
        borderRadius: ChewieDimens.borderRadius8,
        child: InkWell(
          borderRadius: ChewieDimens.borderRadius8,
          onTap: !expanded
              ? () {
                  setState(() {
                    expanded = true;
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: ChewieDimens.borderRadius8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.log.triggerType.label,
                      style: ChewieTheme.bodyMedium,
                    ),
                    const Spacer(),
                    RoundIconTextButton(
                      radius: 5,
                      height: 24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      text: widget.log.lastStatusItem.labelShort,
                      textStyle: ChewieTheme.labelSmall
                          ?.apply(color: Colors.white),
                      background: widget.log.lastStatus.color,
                    ),
                    const SizedBox(width: 5),
                    CircleIconButton(
                      padding: const EdgeInsets.all(4),
                      icon: Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: ChewieTheme.labelSmall?.color),
                      onTap: () {
                        setState(() {
                          expanded = !expanded;
                        });
                      },
                    ),
                  ],
                ),
                if (expanded) const SizedBox(height: 5),
                if (expanded) _buildList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildList() {
    return CustomHtmlWidget(
      content: List.generate(
        widget.log.status.length,
        (i) {
          AutoBackupLogStatusItem statusItem = widget.log.status[i];
          return '[${TimeUtil.timestampToDateString(statusItem.timestamp)}]: ${statusItem.label(widget.log)}';
        },
      ).join('<br>'),
      style: ChewieTheme.labelSmall,
    );
  }
}
