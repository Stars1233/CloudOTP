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

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:cloudotp/Screens/Setting/base_setting_screen.dart';
import 'package:cloudotp/Utils/app_provider.dart';
import 'package:cloudotp/Widgets/BottomSheet/color_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';

class ThemeEditorScreen extends BaseSettingScreen {
  final ChewieThemeColorData baseTheme;
  final bool isDarkMode;
  final int? editIndex;

  const ThemeEditorScreen({
    super.key,
    required this.baseTheme,
    required this.isDarkMode,
    this.editIndex,
  });

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends BaseDynamicState<ThemeEditorScreen>
    with TickerProviderStateMixin {
  late ChewieThemeColorData _theme;
  late TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();
  bool get _isEditing => widget.editIndex != null;

  @override
  void initState() {
    super.initState();
    _theme = widget.baseTheme.copyWith(
      isDarkMode: widget.isDarkMode,
    );
    _nameController = TextEditingController(
      text: _isEditing ? _theme.name : '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      IToast.showTop(appLocalizations.themeNameEmpty);
      return;
    }
    _theme.name = name;
    if (!_isEditing) {
      _theme.id = ChewieThemeColorData.generateId();
    }
    if (widget.isDarkMode) {
      if (_isEditing) {
        appProvider.updateCustomDarkTheme(widget.editIndex!, _theme);
      } else {
        appProvider.addCustomDarkTheme(_theme);
        final newIndex = ChewieThemeColorData.defaultDarkThemes.length +
            appProvider.customDarkThemes.length -
            1;
        appProvider.setDarkTheme(newIndex);
      }
    } else {
      if (_isEditing) {
        appProvider.updateCustomLightTheme(widget.editIndex!, _theme);
      } else {
        appProvider.addCustomLightTheme(_theme);
        final newIndex = ChewieThemeColorData.defaultLightThemes.length +
            appProvider.customLightThemes.length -
            1;
        appProvider.setLightTheme(newIndex);
      }
    }
    DialogNavigatorHelper.responsivePopPage();
  }

  void _updateColor(String field, Color color) {
    setState(() {
      switch (field) {
        case 'scaffoldBackgroundColor':
          _theme = _theme.copyWith(scaffoldBackgroundColor: color);
        case 'canvasColor':
          _theme = _theme.copyWith(canvasColor: color);
        case 'cardColor':
          _theme = _theme.copyWith(cardColor: color);
        case 'textColor':
          _theme = _theme.copyWith(textColor: color);
        case 'textLightGreyColor':
          _theme = _theme.copyWith(textLightGreyColor: color);
        case 'textDarkGreyColor':
          _theme = _theme.copyWith(textDarkGreyColor: color);
        case 'hintColor':
          _theme = _theme.copyWith(hintColor: color);
        case 'primaryColor':
          _theme = _theme.copyWith(primaryColor: color);
        case 'indicatorColor':
          _theme = _theme.copyWith(indicatorColor: color);
        case 'cursorColor':
          _theme = _theme.copyWith(cursorColor: color);
        case 'textSelectionColor':
          _theme = _theme.copyWith(textSelectionColor: color);
        case 'textSelectionHandleColor':
          _theme = _theme.copyWith(textSelectionHandleColor: color);
        case 'buttonPrimaryColor':
          _theme = _theme.copyWith(buttonPrimaryColor: color);
        case 'buttonSecondaryColor':
          _theme = _theme.copyWith(buttonSecondaryColor: color);
        case 'buttonHoverColor':
          _theme = _theme.copyWith(buttonHoverColor: color);
        case 'buttonLightHoverColor':
          _theme = _theme.copyWith(buttonLightHoverColor: color);
        case 'buttonDisabledColor':
          _theme = _theme.copyWith(buttonDisabledColor: color);
        case 'appBarBackgroundColor':
          _theme = _theme.copyWith(appBarBackgroundColor: color);
        case 'appBarSurfaceTintColor':
          _theme = _theme.copyWith(appBarSurfaceTintColor: color);
        case 'appBarShadowColor':
          _theme = _theme.copyWith(appBarShadowColor: color);
        case 'hoverColor':
          _theme = _theme.copyWith(hoverColor: color);
        case 'splashColor':
          _theme = _theme.copyWith(splashColor: color);
        case 'highlightColor':
          _theme = _theme.copyWith(highlightColor: color);
        case 'shadowColor':
          _theme = _theme.copyWith(shadowColor: color);
        case 'dividerColor':
          _theme = _theme.copyWith(dividerColor: color);
        case 'borderColor':
          _theme = _theme.copyWith(borderColor: color);
        case 'iconColor':
          _theme = _theme.copyWith(iconColor: color);
        case 'scrollBarThumbColor':
          _theme = _theme.copyWith(scrollBarThumbColor: color);
        case 'scrollBarThumbHoverColor':
          _theme = _theme.copyWith(scrollBarThumbHoverColor: color);
        case 'scrollBarTrackColor':
          _theme = _theme.copyWith(scrollBarTrackColor: color);
        case 'scrollBarTrackHoverColor':
          _theme = _theme.copyWith(scrollBarTrackHoverColor: color);
        case 'successColor':
          _theme = _theme.copyWith(successColor: color);
        case 'warningColor':
          _theme = _theme.copyWith(warningColor: color);
        case 'errorColor':
          _theme = _theme.copyWith(errorColor: color);
      }
    });
  }

  Color _getColor(String field) {
    switch (field) {
      case 'scaffoldBackgroundColor':
        return _theme.scaffoldBackgroundColor;
      case 'canvasColor':
        return _theme.canvasColor;
      case 'cardColor':
        return _theme.cardColor;
      case 'textColor':
        return _theme.textColor;
      case 'textLightGreyColor':
        return _theme.textLightGreyColor;
      case 'textDarkGreyColor':
        return _theme.textDarkGreyColor;
      case 'hintColor':
        return _theme.hintColor;
      case 'primaryColor':
        return _theme.primaryColor;
      case 'indicatorColor':
        return _theme.indicatorColor;
      case 'cursorColor':
        return _theme.cursorColor;
      case 'textSelectionColor':
        return _theme.textSelectionColor;
      case 'textSelectionHandleColor':
        return _theme.textSelectionHandleColor;
      case 'buttonPrimaryColor':
        return _theme.buttonPrimaryColor;
      case 'buttonSecondaryColor':
        return _theme.buttonSecondaryColor;
      case 'buttonHoverColor':
        return _theme.buttonHoverColor;
      case 'buttonLightHoverColor':
        return _theme.buttonLightHoverColor;
      case 'buttonDisabledColor':
        return _theme.buttonDisabledColor;
      case 'appBarBackgroundColor':
        return _theme.appBarBackgroundColor;
      case 'appBarSurfaceTintColor':
        return _theme.appBarSurfaceTintColor;
      case 'appBarShadowColor':
        return _theme.appBarShadowColor;
      case 'hoverColor':
        return _theme.hoverColor;
      case 'splashColor':
        return _theme.splashColor;
      case 'highlightColor':
        return _theme.highlightColor;
      case 'shadowColor':
        return _theme.shadowColor;
      case 'dividerColor':
        return _theme.dividerColor;
      case 'borderColor':
        return _theme.borderColor;
      case 'iconColor':
        return _theme.iconColor;
      case 'scrollBarThumbColor':
        return _theme.scrollBarThumbColor;
      case 'scrollBarThumbHoverColor':
        return _theme.scrollBarThumbHoverColor;
      case 'scrollBarTrackColor':
        return _theme.scrollBarTrackColor;
      case 'scrollBarTrackHoverColor':
        return _theme.scrollBarTrackHoverColor;
      case 'successColor':
        return _theme.successColor;
      case 'warningColor':
        return _theme.warningColor;
      case 'errorColor':
        return _theme.errorColor;
      default:
        return Colors.white;
    }
  }

  Widget _buildColorGroup(
    String title,
    List<Widget> children, {
    bool initiallyExpanded = false,
  }) {
    return CaptionItem(
      title: title,
      initiallyExpanded: initiallyExpanded,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 3,
            bottom: 3,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildColorRow(String field, String label) {
    final color = _getColor(field);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        ColorPickerBottomSheet.show(
          context,
          initialColor: color,
          title: label,
          onColorChanged: (newColor) => _updateColor(field, newColor),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ChewieTheme.dividerColor, width: 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: ChewieTheme.bodyMedium),
            ),
            Text(
              '#${color.toHex().substring(3).toUpperCase()}',
              style: ChewieTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ItemBuilder.buildSettingScreen(
      context: context,
      title: appLocalizations.themeEditor,
      showTitleBar: widget.showTitleBar,
      showBack: true,
      padding: widget.padding,
      onTapBack: () => DialogNavigatorHelper.responsivePopPage(),
      actions: [
        CircleIconButton(
          icon: Icon(
            LucideIcons.check,
            color: ChewieTheme.iconColor,
          ),
          onTap: _save,
        ),
      ],
      desktopActions: [
        ToolButton(
          context: context,
          icon: LucideIcons.check,
          buttonSize: const Size(32, 32),
          onPressed: _save,
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: InputItem(
            controller: _nameController,
            focusNode: _nameFocusNode,
            title: appLocalizations.themeName,
            hint: appLocalizations.themeNameHint,
            textInputAction: TextInputAction.done,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: _ThemePreview(theme: _theme),
        ),
        _buildColorGroup(
          appLocalizations.colorGroupBackground,
          [
            _buildColorRow('scaffoldBackgroundColor', 'Scaffold Background'),
            _buildColorRow('canvasColor', 'Canvas'),
            _buildColorRow('cardColor', 'Card'),
          ],
          initiallyExpanded: true,
        ),
        _buildColorGroup(
          appLocalizations.colorGroupText,
          [
            _buildColorRow('textColor', 'Text'),
            _buildColorRow('textLightGreyColor', 'Text Light Grey'),
            _buildColorRow('textDarkGreyColor', 'Text Dark Grey'),
            _buildColorRow('hintColor', 'Hint'),
          ],
        ),
        _buildColorGroup(
          appLocalizations.colorGroupAccent,
          [
            _buildColorRow('primaryColor', 'Primary'),
            _buildColorRow('indicatorColor', 'Indicator'),
            _buildColorRow('cursorColor', 'Cursor'),
            _buildColorRow('textSelectionColor', 'Text Selection'),
            _buildColorRow('textSelectionHandleColor', 'Selection Handle'),
          ],
        ),
        _buildColorGroup(
          appLocalizations.colorGroupButtons,
          [
            _buildColorRow('buttonPrimaryColor', 'Primary Button'),
            _buildColorRow('buttonSecondaryColor', 'Secondary Button'),
            _buildColorRow('buttonHoverColor', 'Button Hover'),
            _buildColorRow('buttonLightHoverColor', 'Button Light Hover'),
            _buildColorRow('buttonDisabledColor', 'Button Disabled'),
          ],
        ),
        _buildColorGroup(
          appLocalizations.colorGroupAppBar,
          [
            _buildColorRow('appBarBackgroundColor', 'AppBar Background'),
            _buildColorRow('appBarSurfaceTintColor', 'AppBar Surface Tint'),
            _buildColorRow('appBarShadowColor', 'AppBar Shadow'),
          ],
        ),
        _buildColorGroup(
          appLocalizations.colorGroupSurfaces,
          [
            _buildColorRow('hoverColor', 'Hover'),
            _buildColorRow('splashColor', 'Splash'),
            _buildColorRow('highlightColor', 'Highlight'),
            _buildColorRow('shadowColor', 'Shadow'),
            _buildColorRow('dividerColor', 'Divider'),
            _buildColorRow('borderColor', 'Border'),
            _buildColorRow('iconColor', 'Icon'),
          ],
        ),
        _buildColorGroup(
          appLocalizations.colorGroupScrollbar,
          [
            _buildColorRow('scrollBarThumbColor', 'Thumb'),
            _buildColorRow('scrollBarThumbHoverColor', 'Thumb Hover'),
            _buildColorRow('scrollBarTrackColor', 'Track'),
            _buildColorRow('scrollBarTrackHoverColor', 'Track Hover'),
          ],
        ),
        _buildColorGroup(
          appLocalizations.colorGroupStatus,
          [
            _buildColorRow('successColor', 'Success'),
            _buildColorRow('warningColor', 'Warning'),
            _buildColorRow('errorColor', 'Error'),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _ThemePreview extends StatelessWidget {
  final ChewieThemeColorData theme;

  const _ThemePreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAppBar(),
            Container(
              color: theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildListCard(),
                  const SizedBox(height: 10),
                  _buildButtonRow(),
                  const SizedBox(height: 10),
                  _buildStatusRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: theme.appBarBackgroundColor,
      child: Row(
        children: [
          Icon(LucideIcons.chevronLeft, size: 18, color: theme.iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Preview',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
            ),
          ),
          Icon(LucideIcons.ellipsis, size: 18, color: theme.iconColor),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    return Container(
      decoration: BoxDecoration(
        color: theme.canvasColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _buildListTile(LucideIcons.user, 'Title Text', 'Description text'),
          Divider(height: 1, color: theme.dividerColor, indent: 42),
          _buildListTile(LucideIcons.settings, 'Second Item', 'Detail info'),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.splashColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 15, color: theme.primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textLightGreyColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight,
              size: 14, color: theme.textDarkGreyColor),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.buttonPrimaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              'Primary',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.canvasColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: theme.buttonSecondaryColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.borderColor, width: 0.5),
            ),
            alignment: Alignment.center,
            child: Text(
              'Secondary',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.textColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            color: theme.buttonDisabledColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Disabled',
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusDot(theme.successColor, 'Success'),
          _buildStatusDot(theme.warningColor, 'Warning'),
          _buildStatusDot(theme.errorColor, 'Error'),
          _buildStatusDot(theme.primaryColor, 'Primary'),
        ],
      ),
    );
  }

  Widget _buildStatusDot(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: theme.textLightGreyColor),
        ),
      ],
    );
  }
}
