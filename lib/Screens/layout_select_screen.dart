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

class LayoutSelectScreen extends StatefulWidget {
  final bool isOverlay;

  const LayoutSelectScreen({super.key, this.isOverlay = false});

  static void show(BuildContext context) {
    if (ResponsiveUtil.isLandscapeLayout()) {
      BottomSheetBuilder.showGenericContextMenu(
        context,
        const LayoutSelectScreen(isOverlay: true),
      );
    } else {
      BottomSheetBuilder.showBottomSheet(
        context,
        (ctx) => const LayoutSelectScreen(),
        responsive: true,
      );
    }
  }

  @override
  State<LayoutSelectScreen> createState() => _LayoutSelectScreenState();
}

class _LayoutSelectScreenState extends BaseDynamicState<LayoutSelectScreen> {
  Color get _accent => ChewieTheme.primaryColor;

  Radius get _radius => ChewieDimens.defaultRadius;

  @override
  Widget build(BuildContext context) {
    final currentType = homeScreenState?.layoutType ?? LayoutType.Simple;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildGrid(currentType),
        ],
      ),
    );

    if (widget.isOverlay) {
      return Container(
        width: min(300, MediaQuery.sizeOf(context).width - 80),
        decoration: BoxDecoration(
          color: ChewieTheme.scaffoldBackgroundColor,
          borderRadius: ChewieDimens.borderRadius8,
          border: ChewieTheme.border,
          boxShadow: ChewieTheme.defaultBoxShadow,
        ),
        child: content,
      );
    }

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
          child: content,
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
          child: Icon(LucideIcons.layoutGrid, color: _accent, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appLocalizations.layoutType,
                style: ChewieTheme.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 1),
              Text(
                appLocalizations.layoutTypeSubtitle,
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

  Widget _buildGrid(LayoutType currentType) {
    final values = LayoutType.values;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
                child: _buildLayoutCard(values[0], values[0] == currentType)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildLayoutCard(values[1], values[1] == currentType)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _buildLayoutCard(values[2], values[2] == currentType)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildLayoutCard(values[3], values[3] == currentType)),
          ],
        ),
      ],
    );
  }

  Widget _buildLayoutCard(LayoutType type, bool selected) {
    return GestureDetector(
      onTap: () {
        homeScreenState?.changeLayoutType(type);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? _accent.withAlpha(22) : ChewieTheme.canvasColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _accent : ChewieTheme.borderColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ChewieTheme.scaffoldBackgroundColor.withAlpha(160),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(6),
                child: _buildPreview(type),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(type.icon,
                    size: 14,
                    color: selected
                        ? _accent
                        : ChewieTheme.titleLarge.color?.withAlpha(180)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    type.title,
                    style: ChewieTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? _accent : ChewieTheme.titleLarge.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (selected)
                  Icon(LucideIcons.check, size: 14, color: _accent),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(LayoutType type) {
    switch (type) {
      case LayoutType.Simple:
        return _gridPreview(crossAxis: 2, rows: 2, itemHeight: 12);
      case LayoutType.Compact:
        return _gridPreview(crossAxis: 2, rows: 3, itemHeight: 8);
      case LayoutType.Spotlight:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _previewBar(height: 18, widthFactor: 0.85),
            const SizedBox(height: 3),
            _previewBar(height: 12, widthFactor: 0.85),
          ],
        );
      case LayoutType.List:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: _previewBar(height: 5, widthFactor: 1),
            ),
          ),
        );
    }
  }

  Widget _gridPreview({
    required int crossAxis,
    required int rows,
    required double itemHeight,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(rows, (r) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.5),
          child: Row(
            children: List.generate(crossAxis, (c) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: c == crossAxis - 1 ? 0 : 3),
                  height: itemHeight,
                  decoration: BoxDecoration(
                    color: _accent.withAlpha(70),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _previewBar({required double height, required double widthFactor}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: _accent.withAlpha(70),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
