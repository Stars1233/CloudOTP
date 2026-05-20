/*
 * Copyright (c) 2025 Robert-Stackflow.
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

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateLogScreen extends StatefulWidget {
  const UpdateLogScreen({
    super.key,
    this.showTitleBar = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
  });

  final bool showTitleBar;
  final EdgeInsets padding;

  @override
  State<UpdateLogScreen> createState() => _UpdateLogScreenState();
}

class _UpdateLogScreenState extends BaseDynamicState<UpdateLogScreen>
    with TickerProviderStateMixin {
  List<ReleaseItem> releaseItems = [];
  final EasyRefreshController _refreshController = EasyRefreshController();
  String currentVersion = "";
  String latestVersion = "";

  @override
  void initState() {
    super.initState();
    getAppInfo();
  }

  void getAppInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        currentVersion = packageInfo.version;
      });
    });
  }

  Future<void> fetchReleases() async {
    await ChewieUtils.getReleases(
      context: context,
      showLoading: false,
      showUpdateDialog: false,
      showLatestToast: false,
      noUpdateToastText: chewieLocalizations.failedToGetChangelog,
      onGetCurrentVersion: (currentVersion) {
        setState(() {
          this.currentVersion = currentVersion;
        });
      },
      onGetLatestRelease: (latestVersion, latestReleaseItem) {
        setState(() {
          this.latestVersion = latestVersion;
        });
      },
      onGetReleases: (releases) {
        setState(() {
          releaseItems = releases;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showTitleBar
          ? ResponsiveAppBar(
              title: chewieLocalizations.changelog,
              showBack: true,
              onTapBack: () {
                if (ResponsiveUtil.isLandscapeLayout()) {
                  DialogNavigatorHelper.popPage();
                } else {
                  Navigator.pop(context);
                }
              },
              backgroundColor: ResponsiveUtil.isLandscapeLayout()
                  ? ChewieTheme.canvasColor
                  : ChewieTheme.scaffoldBackgroundColor,
            )
          : null,
      body: EasyRefresh(
        controller: _refreshController,
        refreshOnStart: true,
        onRefresh: () async {
          await fetchReleases();
        },
        child: ListView.builder(
          padding: widget.padding
              .add(const EdgeInsets.symmetric(horizontal: 4, vertical: 10)),
          itemBuilder: (context, index) => _buildItem(
            releaseItems[index],
            index,
            index == releaseItems.length - 1,
          ),
          itemCount: releaseItems.length,
        ),
      ),
    );
  }

  Widget _buildItem(ReleaseItem item, int index, bool isLast) {
    final isCurrent = ChewieUtils.compareVersion(
            item.tagName.replaceAll(RegExp(r'[a-zA-Z]'), ''), currentVersion) ==
        0;
    final isLatest = index == 0;

    final releaseDate =
        item.publishedAt != null ? TimeUtil.formatDate(item.publishedAt!) : "";

    final accent = isCurrent ? ChewieTheme.primaryColor : ChewieTheme.iconColor;

    return Stack(
      children: [
        if (!isLast)
          Positioned(
            left: 9,
            top: 26,
            bottom: 0,
            child: Container(
              width: 1.5,
              color: ChewieTheme.dividerColor,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? accent : accent.withAlpha(60),
                  border: Border.all(
                    color: isCurrent ? accent : ChewieTheme.dividerColor,
                    width: 2,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms).scale(delay: 30.ms),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ChewieTheme.canvasColor,
                borderRadius: ChewieDimens.borderRadius12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isLatest
                              ? LucideIcons.sparkles
                              : LucideIcons.tag,
                          size: 15,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.tagName,
                                  style: ChewieTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isCurrent) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: accent.withAlpha(25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      chewieLocalizations.currentVersion,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (releaseDate.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                releaseDate,
                                style: ChewieTheme.bodySmall.copyWith(
                                  color: ChewieTheme.bodyMedium.color
                                      ?.withAlpha(120),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      CircleIconButton(
                        icon: Icon(
                          LucideIcons.externalLink,
                          size: 14,
                          color: ChewieTheme.iconColor,
                        ),
                        onTap: () {
                          UriUtil.launchUrlUri(context, item.htmlUrl);
                        },
                      ),
                    ],
                  ),
                  if ((item.body ?? "").isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ChewieTheme.scaffoldBackgroundColor,
                          borderRadius: ChewieDimens.borderRadius8,
                        ),
                        child: SelectableAreaWrapper(
                          focusNode: FocusNode(),
                          child: CustomMarkdownWidget(
                            item.body ?? "",
                            baseStyle: ChewieTheme.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          ],
        ),
      ],
    );
  }
}
