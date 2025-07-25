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

import 'dart:math';

import 'package:flutter/material.dart';

import 'package:awesome_chewie/awesome_chewie.dart';

class ItemBuilder {
  static Widget buildSettingScreen({
    required BuildContext context,
    required String title,
    required bool showTitleBar,
    required EdgeInsets padding,
    List<Widget> children = const [],
    bool showBack = true,
    Color? backgroundColor,
    double titleLeftMargin = 5,
    bool showBorder = true,
    Function()? onTapBack,
    Widget? overrideBody,
    List<Widget> desktopActions = const [],
    List<Widget> actions = const [],
  }) {
    return Scaffold(
      appBar: showTitleBar
          ? ResponsiveAppBar(
              titleLeftMargin: titleLeftMargin,
              showBack: showBack,
              title: title,
              backgroundColor: backgroundColor,
              showBorder: showBorder,
              onTapBack: onTapBack,
              actions: actions,
              desktopActions: desktopActions,
            )
          : null,
      body: overrideBody ??
          EasyRefresh(
            child: ListView(
              padding: padding,
              children: children,
            ),
          ),
    );
  }

  static PreferredSize buildPreferredSize({
    double height = kToolbarHeight,
    required Widget child,
  }) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: child,
    );
  }

  static MyCachedNetworkImage buildCachedImage({
    required String imageUrl,
    required BuildContext context,
    BoxFit? fit,
    bool showLoading = true,
    double? width,
    double? height,
    double? placeholderHeight,
    Color? placeholderBackground,
    double topPadding = 0,
    double bottomPadding = 0,
    bool simpleError = false,
  }) {
    return MyCachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      simpleError: simpleError,
      height: height,
      placeholderHeight: placeholderHeight,
      placeholderBackground: placeholderBackground,
      topPadding: topPadding,
      bottomPadding: bottomPadding,
      showLoading: showLoading,
    );
  }

  static buildHeroCachedImage({
    required String imageUrl,
    required BuildContext context,
    List<String>? imageUrls,
    BoxFit? fit = BoxFit.cover,
    bool showLoading = true,
    double? width,
    double? height,
    Color? placeholderBackground,
    double topPadding = 0,
    double bottomPadding = 0,
    String? title,
    String? caption,
    String? tagPrefix,
    String? tagSuffix,
  }) {
    imageUrls ??= [imageUrl];
    return ClickableGestureDetector(
      onTap: () {
        RouteUtil.pushDialogRoute(
          context,
          showClose: false,
          fullScreen: true,
          useFade: true,
          HeroPhotoViewScreen(
            tagPrefix: tagPrefix,
            tagSuffix: tagSuffix,
            imageUrls: imageUrls!,
            useMainColor: false,
            title: title,
            captions: [caption ?? ""],
            initIndex: imageUrls.indexOf(imageUrl),
          ),
        );
      },
      child: Hero(
        tag: ChewieUtils.getHeroTag(
            tagSuffix: tagSuffix, tagPrefix: tagPrefix, url: imageUrl),
        child: ItemBuilder.buildCachedImage(
          context: context,
          imageUrl: imageUrl,
          width: width,
          height: height,
          showLoading: showLoading,
          bottomPadding: bottomPadding,
          topPadding: topPadding,
          placeholderBackground: placeholderBackground,
          fit: fit,
        ),
      ),
    );
  }

  static Widget buildLoadingDialog({
    required BuildContext context,
    ScrollPhysics? physics,
    bool shrinkWrap = true,
    ScrollController? scrollController,
    String? text,
    bool showText = true,
    double size = 50,
    double topPadding = 0,
    double bottomPadding = 100,
    bool forceDark = false,
    Color? background,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center,
  }) {
    return Center(
      child: ListView(
        physics: physics,
        shrinkWrap: shrinkWrap,
        controller: scrollController,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topPadding),
              chewieProvider.loadingWidgetBuilder(size, forceDark),
              if (showText) const SizedBox(height: 10),
              if (showText)
                Text(text ?? chewieLocalizations.loading,
                    style: ChewieTheme.labelLarge),
              SizedBox(height: bottomPadding),
            ],
          ),
        ],
      ),
    );
  }

  static buildGroupTile({
    required BuildContext context,
    String title = '',
    required List<String> buttons,
    GroupButtonController? controller,
    EdgeInsets? padding,
    bool disabled = false,
    bool enableDeselect = false,
    bool constraintWidth = true,
    Function(dynamic value, int index, bool isSelected)? onSelected,
  }) {
    return Container(
      color: Colors.transparent,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Text(
                title,
                style: ChewieTheme.titleMedium
                    .apply(fontWeightDelta: 2, fontSizeDelta: -2),
              ),
            ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: ItemBuilder.buildGroupButtons(
              buttons: buttons,
              disabled: disabled,
              controller: controller,
              constraintWidth: constraintWidth,
              radius: 8,
              enableDeselect: enableDeselect,
              mainGroupAlignment: MainGroupAlignment.start,
              onSelected: onSelected,
            ),
          ),
        ],
      ),
    );
  }

  static buildGroupButtons({
    required List<String> buttons,
    GroupButtonController? controller,
    bool enableDeselect = false,
    bool isRadio = true,
    bool constraintWidth = true,
    double radius = 8,
    Function(dynamic value, int index, bool isSelected)? onSelected,
    bool disabled = false,
    MainGroupAlignment mainGroupAlignment = MainGroupAlignment.start,
  }) {
    return GroupButton(
      disabled: disabled,
      isRadio: isRadio,
      enableDeselect: enableDeselect,
      options: GroupButtonOptions(
        mainGroupAlignment: mainGroupAlignment,
      ),
      onSelected: onSelected,
      maxSelected: 1,
      controller: controller,
      buttons: buttons,
      buttonBuilder: (selected, label, context, onTap, __) {
        return SizedBox(
          width: constraintWidth ? 80 : null,
          child: RoundIconTextButton(
            height: 36,
            text: label,
            radius: radius,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            background: selected ? ChewieTheme.primaryColor : null,
            textStyle: ChewieTheme.titleSmall.apply(
                fontWeightDelta: 1, color: selected ? Colors.white : null),
            onPressed: onTap,
          ),
        );
      },
    );
  }

  static Widget editTextContextMenuBuilder(
    contextMenuContext,
    EditableTextState details, {
    required BuildContext context,
  }) {
    Map<ContextMenuButtonType, String> typeToString = {
      ContextMenuButtonType.copy: chewieLocalizations.copy,
      ContextMenuButtonType.cut: chewieLocalizations.cut,
      ContextMenuButtonType.paste: chewieLocalizations.paste,
      ContextMenuButtonType.selectAll: chewieLocalizations.selectAll,
      ContextMenuButtonType.searchWeb: chewieLocalizations.search,
      ContextMenuButtonType.share: chewieLocalizations.share,
      ContextMenuButtonType.lookUp: chewieLocalizations.search,
      ContextMenuButtonType.delete: chewieLocalizations.delete,
      ContextMenuButtonType.liveTextInput: chewieLocalizations.input,
      ContextMenuButtonType.custom: chewieLocalizations.custom,
    };
    List<MyContextMenuItem> items = [];
    // int start = details.textEditingValue.selection.start <= -1
    //     ? 0
    //     : details.textEditingValue.selection.start;
    // int end = details.textEditingValue.selection.end
    //     .clamp(0, details.textEditingValue.text.length);
    // String selectedText = details.textEditingValue.text.substring(start, end);
    for (var e in details.contextMenuButtonItems) {
      if (e.type != ContextMenuButtonType.custom) {
        items.add(
          MyContextMenuItem(
            label: typeToString[e.type] ?? "",
            type: e.type,
            onPressed: () {
              e.onPressed?.call();
            },
          ),
        );
      }
    }
    if (ResponsiveUtil.isMobile()) {
      return MyMobileTextSelectionToolbar.items(
        anchorAbove: details.contextMenuAnchors.primaryAnchor,
        anchorBelow: details.contextMenuAnchors.primaryAnchor,
        backgroundColor: ChewieTheme.canvasColor,
        dividerColor: ChewieTheme.dividerColor,
        items: items,
        itemBuilder: (MyContextMenuItem item) {
          return Text(
            item.label ?? "",
            style: ChewieTheme.titleMedium,
          );
        },
      );
    } else {
      return MyDesktopTextSelectionToolbar(
        anchor: details.contextMenuAnchors.primaryAnchor,
        // decoration: ChewieTheme.defaultDecoration,
        dividerColor: ChewieTheme.dividerColor,
        items: items,
      );
    }
  }
}
