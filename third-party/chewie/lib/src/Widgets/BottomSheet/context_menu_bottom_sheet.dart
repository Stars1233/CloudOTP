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

import 'package:flutter/material.dart';

import 'package:awesome_chewie/awesome_chewie.dart';

class ContextMenuBottomSheet extends StatefulWidget {
  const ContextMenuBottomSheet({
    super.key,
    required this.menu,
  });

  final FlutterContextMenu menu;

  @override
  ContextMenuBottomSheetState createState() => ContextMenuBottomSheetState();
}

class ContextMenuBottomSheetState extends State<ContextMenuBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  Radius radius = ChewieDimens.defaultRadius;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ChewieTheme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: radius,
              bottom: ResponsiveUtil.isWideDevice() ? radius : Radius.zero,
            ),
            border: ChewieTheme.responsiveBorder,
            boxShadow: ChewieTheme.defaultBoxShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!ResponsiveUtil.isWideDevice())
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(height: 36),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: ChewieTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    14, ResponsiveUtil.isWideDevice() ? 14 : 0, 14, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var config in widget.menu.entries)
                      _buildConfigItem(
                        config as FlutterContextMenuItem,
                        config == widget.menu.entries.first,
                        config == widget.menu.entries.last,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildConfigItem(
    FlutterContextMenuItem? config, [
    bool isFirst = false,
    bool isLast = false,
  ]) {
    Color? textColor;
    if (config == null || config.type == MenuItemType.divider) {
      return const MyDivider(width: 1.5, vertical: 4, horizontal: 4);
    } else {
      Color iconColor = ChewieTheme.primaryColor;
      switch (config.status) {
        case MenuItemStatus.success:
          textColor = ChewieTheme.successColor;
          iconColor = ChewieTheme.successColor;
          break;
        case MenuItemStatus.warning:
          textColor = ChewieTheme.warningColor;
          iconColor = ChewieTheme.warningColor;
          break;
        case MenuItemStatus.error:
          textColor = ChewieTheme.errorColor;
          iconColor = ChewieTheme.errorColor;
          break;
        default:
          textColor = null;
          iconColor = ChewieTheme.primaryColor;
          break;
      }
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          config.onPressed?.call();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: ChewieTheme.canvasColor,
            borderRadius: ChewieDimens.borderRadius12,
          ),
          child: Row(
            children: [
              if (config.type != MenuItemType.checkbox &&
                  config.iconData != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(config.iconData, size: 17, color: iconColor),
                ),
                const SizedBox(width: 12),
              ],
              if (config.type == MenuItemType.checkbox && config.checked) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(Icons.check_rounded, size: 17, color: iconColor),
                ),
                const SizedBox(width: 12),
              ],
              if (config.type == MenuItemType.checkbox && !config.checked) ...[
                const SizedBox(width: 34, height: 34),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  config.label,
                  style: ChewieTheme.bodyLarge.apply(color: textColor),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
