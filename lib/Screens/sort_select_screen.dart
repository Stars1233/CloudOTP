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
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../Utils/app_provider.dart';
import '../l10n/l10n.dart';
import 'home_screen.dart';

class SortSelectScreen extends StatefulWidget {
  final bool isOverlay;

  const SortSelectScreen({super.key, this.isOverlay = false});

  static void show(BuildContext context) {
    if (ResponsiveUtil.isLandscapeLayout()) {
      BottomSheetBuilder.showGenericContextMenu(
        context,
        const SortSelectScreen(isOverlay: true),
      );
    } else {
      BottomSheetBuilder.showBottomSheet(
        context,
        (ctx) => const SortSelectScreen(),
        responsive: true,
      );
    }
  }

  @override
  State<SortSelectScreen> createState() => _SortSelectScreenState();
}

class _SortSelectScreenState extends BaseDynamicState<SortSelectScreen> {
  Color get _accent => ChewieTheme.primaryColor;

  Radius get _radius => ChewieDimens.defaultRadius;

  List<({String label, List<OrderType> types})> _groups() => [
        (
          label: appLocalizations.sortGroupDefault,
          types: [OrderType.Default],
        ),
        (
          label: appLocalizations.sortGroupAlphabetical,
          types: [
            OrderType.AlphabeticalASC,
            OrderType.AlphabeticalDESC,
          ],
        ),
        (
          label: appLocalizations.sortGroupCopyTimes,
          types: [
            OrderType.CopyTimesDESC,
            OrderType.CopyTimesASC,
          ],
        ),
        (
          label: appLocalizations.sortGroupLastCopy,
          types: [
            OrderType.LastCopyTimeDESC,
            OrderType.LastCopyTimeASC,
          ],
        ),
        (
          label: appLocalizations.sortGroupCreate,
          types: [
            OrderType.CreateTimeDESC,
            OrderType.CreateTimeASC,
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final groups = _groups();

    Widget header = Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
      child: _buildHeader(),
    );

    if (widget.isOverlay) {
      final leftGroups = groups.sublist(0, 3);
      final rightGroups = groups.sublist(3);
      return Container(
        width: min(480, MediaQuery.sizeOf(context).width - 80),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildGroupColumn(leftGroups)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildGroupColumn(rightGroups)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in groups)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
            child: _buildGroup(g),
          ),
        const SizedBox(height: 12),
      ],
    );

    return Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Container(
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
            children: [header, body],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupColumn(
      List<({String label, List<OrderType> types})> groups) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final g in groups)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _buildGroup(g),
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
          child: Icon(LucideIcons.arrowUpDown, color: _accent, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocalizations.sortType,
                style: ChewieTheme.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 1),
              Text(
                appLocalizations.sortTypeSubtitle,
                style: ChewieTheme.bodySmall.copyWith(
                  color: ChewieTheme.bodyMedium.color?.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroup(({String label, List<OrderType> types}) group) {
    final currentType = homeScreenState?.orderType;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            group.label,
            style: ChewieTheme.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: ChewieTheme.bodyMedium.color?.withAlpha(150),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: ChewieTheme.canvasColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ChewieTheme.borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < group.types.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    indent: 44,
                    color: ChewieTheme.borderColor.withAlpha(120),
                  ),
                _buildSortItem(group.types[i], group.types[i] == currentType),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortItem(OrderType type, bool selected) {
    return GestureDetector(
      onTap: () {
        homeScreenState?.changeOrderType(type: type);
        if (!widget.isOverlay) {
          Navigator.pop(context);
        } else {
          setState(() {});
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: selected
                    ? _accent.withAlpha(30)
                    : ChewieTheme.scaffoldBackgroundColor.withAlpha(150),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                type.icon,
                size: 14,
                color: selected
                    ? _accent
                    : ChewieTheme.titleLarge.color?.withAlpha(180),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                type.title,
                style: ChewieTheme.bodyMedium.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? _accent : ChewieTheme.titleLarge.color,
                ),
              ),
            ),
            if (selected) Icon(LucideIcons.check, size: 16, color: _accent),
          ],
        ),
      ),
    );
  }
}
