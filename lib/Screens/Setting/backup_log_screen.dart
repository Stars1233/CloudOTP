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
import 'package:cloudotp/Database/auto_backup_log_dao.dart';
import 'package:cloudotp/Models/auto_backup_log.dart';
import 'package:cloudotp/Screens/Setting/setting_backup_screen.dart';
import 'package:cloudotp/Screens/Setting/setting_navigation_screen.dart';
import 'package:cloudotp/Utils/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../Database/config_dao.dart';
import '../../l10n/l10n.dart';

class BackupLogScreen extends StatefulWidget {
  final bool isOverlay;

  const BackupLogScreen({
    super.key,
    this.isOverlay = false,
  });

  static bool _hasContextMenuOverlay(BuildContext context) {
    return context.findAncestorStateOfType<GenericContextMenuOverlayState>() !=
        null;
  }

  static void show(BuildContext context) {
    if (ResponsiveUtil.isLandscapeLayout() && _hasContextMenuOverlay(context)) {
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
  List<AutoBackupLog> _mergedLogs = [];
  bool _isLoadingHistory = false;
  bool _hasLoadedHistory = false;

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
      if (_autoBackupPassword.isNotEmpty) {
        _loadHistoricalLogs();
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (appProvider.autoBackupLoadingStatus == LoadingStatus.failed) {
        appProvider.autoBackupLoadingStatus = LoadingStatus.none;
      }
    });
  }

  Future<void> _loadHistoricalLogs() async {
    if (_isLoadingHistory || _hasLoadedHistory) return;
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final dbLogs = await AutoBackupLogDao.getLogs(limit: 50);
      _mergeLogs(dbLogs);
    } catch (_) {
      _mergedLogs = List.from(appProvider.autoBackupLogs);
    }

    setState(() {
      _isLoadingHistory = false;
      _hasLoadedHistory = true;
    });
  }

  void _mergeLogs(List<AutoBackupLog> dbLogs) {
    final inMemoryLogs = appProvider.autoBackupLogs;
    final List<AutoBackupLog> result = [];
    final Set<int> seenDbIds = {};

    for (final log in inMemoryLogs) {
      result.add(log);
      if (log.id > 0) seenDbIds.add(log.id);
    }

    for (final log in dbLogs) {
      if (!seenDbIds.contains(log.id)) {
        result.add(log);
      }
    }

    result.sort((a, b) => b.startTimestamp.compareTo(a.startTimestamp));
    _mergedLogs = result;
  }

  @override
  Widget build(BuildContext context) {
    Widget header = Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      child: _buildHeader(),
    );

    Widget body = _buildLogList();

    if (widget.isOverlay) {
      final overlayHeight = _mergedLogs.isEmpty || !canBackup ? 300.0 : 400.0;
      return Container(
        width: min(400, MediaQuery.sizeOf(context).width - 80),
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
            minHeight: MediaQuery.sizeOf(context).height * 0.3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: _radius,
              bottom: ResponsiveUtil.isWideDevice() ? _radius : Radius.zero,
            ),
            color: ChewieTheme.scaffoldBackgroundColor,
            border: ChewieTheme.responsiveBorder,
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
        if (canBackup && _mergedLogs.isNotEmpty)
          CircleIconButton(
            icon: Icon(LucideIcons.trash2, size: 16, color: _accent),
            onTap: clear,
          ),
      ],
    );
  }

  clear() async {
    final completedIds = _mergedLogs
        .where((log) => log.lastStatus.isCompleted && log.id >= 0)
        .map((log) => log.id)
        .toList();

    appProvider.clearAutoBackupLogs();
    appProvider.autoBackupLoadingStatus = LoadingStatus.none;

    if (completedIds.isNotEmpty) {
      await AutoBackupLogDao.deleteCompletedLogs(completedIds);
    }

    final remainingDbLogs = await AutoBackupLogDao.getLogs(limit: 50);
    _mergeLogs(remainingDbLogs);
    setState(() {});
  }

  Widget _buildLogList() {
    if (!canBackup) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  LucideIcons.keyRound,
                  size: 26,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appLocalizations.haveNotSetBackupPassword,
                style: ChewieTheme.bodyMedium.copyWith(
                  color: ChewieTheme.bodyMedium.color?.withAlpha(150),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              RoundIconTextButton(
                height: 38,
                text: appLocalizations.goToSetBackupPassword,
                background: _accent,
                onPressed: () {
                  if (widget.isOverlay) {
                    RouteUtil.pushDialogRoute(
                        context, const SettingNavigationScreen(initPageIndex: 3));
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
        ),
      );
    }

    if (_isLoadingHistory) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_mergedLogs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: EmptyPlaceholder(
            text: appLocalizations.noBackupLogs, topPadding: 10),
      );
    }

    if (widget.isOverlay) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _mergedLogs.length,
            (index) => BackupLogItem(
              log: _mergedLogs[index],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
      shrinkWrap: true,
      itemCount: _mergedLogs.length,
      itemBuilder: (context, index) {
        return BackupLogItem(
          log: _mergedLogs[index],
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

  static final DateFormat _timeFormat = DateFormat("HH:mm:ss");
  static final DateFormat _dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm");

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.log.lastStatus.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            expanded = !expanded;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ChewieTheme.canvasColor,
            borderRadius: ChewieDimens.borderRadius12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.log.triggerType.icon,
                      size: 15,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.log.triggerType.label,
                          style: ChewieTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_dateTimeFormat.format(DateTime.fromMillisecondsSinceEpoch(widget.log.startTimestamp))}  ·  ${widget.log.type.label}',
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
                  RoundIconTextButton(
                    radius: 5,
                    height: 24,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    text: widget.log.lastStatusItem.labelShort,
                    textStyle:
                        ChewieTheme.labelSmall.apply(color: Colors.white),
                    background: statusColor,
                  ),
                  const SizedBox(width: 4),
                  CircleIconButton(
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: ChewieTheme.labelSmall.color),
                    onTap: () {
                      setState(() {
                        expanded = !expanded;
                      });
                    },
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10, left: 4),
                        child: _buildStatusTimeline(),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.log.status.length, (i) {
        final statusItem = widget.log.status[i];
        final isLast = i == widget.log.status.length - 1;
        final dotColor = statusItem.status.color;
        final timeStr = _timeFormat
            .format(DateTime.fromMillisecondsSinceEpoch(statusItem.timestamp));

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 16,
                child: Column(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1,
                          color: ChewieTheme.dividerColor,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                timeStr,
                style: ChewieTheme.labelSmall.copyWith(
                  color: ChewieTheme.bodyMedium.color?.withAlpha(120),
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                  child: Text(
                    statusItem.label(widget.log),
                    style: ChewieTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
