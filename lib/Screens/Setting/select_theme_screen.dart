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
import 'package:cloudotp/Screens/Setting/theme_editor_screen.dart';
import 'package:cloudotp/Utils/app_provider.dart';
import 'package:cloudotp/Utils/theme_util.dart';
import 'package:cloudotp/Widgets/BottomSheet/color_picker_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../l10n/l10n.dart';

class SelectThemeScreen extends BaseSettingScreen {
  const SelectThemeScreen({super.key});

  static const String routeName = "/setting/theme";

  @override
  State<SelectThemeScreen> createState() => _SelectThemeScreenState();
}

class _SelectThemeScreenState extends BaseDynamicState<SelectThemeScreen>
    with TickerProviderStateMixin {
  int _selectedLightIndex = ChewieHiveUtil.getLightThemeIndex();
  int _selectedDarkIndex = ChewieHiveUtil.getDarkThemeIndex();
  int _lightPrimaryColorIndex = ChewieHiveUtil.getLightThemePrimaryColorIndex();
  int _darkPrimaryColorIndex = ChewieHiveUtil.getDarkThemePrimaryColorIndex();

  static const List<Color> _presetAccentColors = [
    Color(0xFF11b566),
    Color(0xFF2196F3),
    Color(0xFF009688),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFFFF5722),
    Color(0xFF795548),
    Color(0xFF607D8B),
    Color(0xFFFF9800),
    Color(0xFF4CAF50),
    Color(0xFF3F51B5),
  ];

  @override
  Widget build(BuildContext context) {
    return ItemBuilder.buildSettingScreen(
      context: context,
      title: appLocalizations.selectTheme,
      showTitleBar: widget.showTitleBar,
      showBack: true,
      padding: widget.padding,
      onTapBack: () {
        DialogNavigatorHelper.responsivePopPage();
      },
      children: [
        CaptionItem(
          title: appLocalizations.lightTheme,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      children: _buildLightThemeList(),
                    ),
                  ),
                ),
              ),
            ),
            _buildAccentColorPalette(isDark: false),
          ],
        ),
        CaptionItem(
          title: appLocalizations.darkTheme,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: IntrinsicHeight(
                    child: Row(
                      children: _buildDarkThemeList(),
                    ),
                  ),
                ),
              ),
            ),
            _buildAccentColorPalette(isDark: true),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  List<Widget> _buildLightThemeList() {
    final builtInCount = ChewieThemeColorData.defaultLightThemes.length;
    final customThemes = appProvider.customLightThemes;
    var list = List<Widget>.generate(
      builtInCount,
      (index) => ThemeItem(
        index: index,
        groupIndex: _selectedLightIndex,
        themeColorData: ChewieThemeColorData.defaultLightThemes[index],
        onChanged: (index) {
          setState(() {
            _selectedLightIndex = index ?? 0;
            appProvider.setLightTheme(index ?? 0);
          });
        },
      ),
    );
    if (customThemes.isNotEmpty) {
      list.add(_buildVerticalDivider());
    }
    for (int i = 0; i < customThemes.length; i++) {
      final globalIndex = builtInCount + i;
      list.add(_wrapWithContextMenu(
        isDark: false,
        customIndex: i,
        child: ThemeItem(
          index: globalIndex,
          groupIndex: _selectedLightIndex,
          themeColorData: customThemes[i],
          onChanged: (index) {
            setState(() {
              _selectedLightIndex = index ?? 0;
              appProvider.setLightTheme(index ?? 0);
            });
          },
          onLongPress: ResponsiveUtil.isDesktop()
              ? null
              : () => _showCustomThemeOptions(false, i),
        ),
      ));
    }
    list.add(_buildVerticalDivider());
    list.add(EmptyThemeItem(onTap: () => _createNewTheme(false)));
    return list;
  }

  List<Widget> _buildDarkThemeList() {
    final builtInCount = ChewieThemeColorData.defaultDarkThemes.length;
    final customThemes = appProvider.customDarkThemes;
    var list = List<Widget>.generate(
      builtInCount,
      (index) => ThemeItem(
        index: index,
        groupIndex: _selectedDarkIndex,
        themeColorData: ChewieThemeColorData.defaultDarkThemes[index],
        onChanged: (index) {
          setState(() {
            _selectedDarkIndex = index ?? 0;
            appProvider.setDarkTheme(index ?? 0);
          });
        },
      ),
    );
    if (customThemes.isNotEmpty) {
      list.add(_buildVerticalDivider());
    }
    for (int i = 0; i < customThemes.length; i++) {
      final globalIndex = builtInCount + i;
      list.add(_wrapWithContextMenu(
        isDark: true,
        customIndex: i,
        child: ThemeItem(
          index: globalIndex,
          groupIndex: _selectedDarkIndex,
          themeColorData: customThemes[i],
          onChanged: (index) {
            setState(() {
              _selectedDarkIndex = index ?? 0;
              appProvider.setDarkTheme(index ?? 0);
            });
          },
          onLongPress: ResponsiveUtil.isDesktop()
              ? null
              : () => _showCustomThemeOptions(true, i),
        ),
      ));
    }
    list.add(_buildVerticalDivider());
    list.add(EmptyThemeItem(onTap: () => _createNewTheme(true)));
    return list;
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.only(
        left: 0,
        right: 10,
        top: 10,
        bottom: 40,
      ),
      color: ChewieTheme.dividerColor,
    );
  }

  Widget _wrapWithContextMenu({
    required bool isDark,
    required int customIndex,
    required Widget child,
  }) {
    return ContextMenuRegion(
      enable: ResponsiveUtil.isDesktop(),
      enableOnLongPress: false,
      contextMenu: _buildCustomThemeContextMenu(isDark, customIndex),
      child: child,
    );
  }

  FlutterContextMenu _buildCustomThemeContextMenu(
      bool isDark, int customIndex) {
    final themes =
        isDark ? appProvider.customDarkThemes : appProvider.customLightThemes;
    final theme = themes[customIndex];
    return FlutterContextMenu(
      entries: [
        FlutterContextMenuItem(
          appLocalizations.editTheme,
          iconData: LucideIcons.pencilLine,
          onPressed: () {
            _navigateToEditor(theme, isDark, editIndex: customIndex);
          },
        ),
        FlutterContextMenuItem(
          appLocalizations.duplicateTheme,
          iconData: LucideIcons.copy,
          onPressed: () {
            final copy = theme.copyWith(
              id: ChewieThemeColorData.generateId(),
              name: '${theme.name} (copy)',
            );
            if (isDark) {
              appProvider.addCustomDarkTheme(copy);
            } else {
              appProvider.addCustomLightTheme(copy);
            }
            setState(() {});
          },
        ),
        FlutterContextMenuItem.divider(),
        FlutterContextMenuItem(
          appLocalizations.exportToClipboard,
          iconData: LucideIcons.clipboardCopy,
          onPressed: () {
            ThemeUtil.exportToClipboard(context, theme);
            IToast.showTop(appLocalizations.themeExportSuccess);
          },
        ),
        FlutterContextMenuItem(
          appLocalizations.exportToFile,
          iconData: LucideIcons.save,
          onPressed: () async {
            final ok = await ThemeUtil.exportToFile(theme);
            if (ok) IToast.showTop(appLocalizations.themeExportSuccess);
          },
        ),
        FlutterContextMenuItem.divider(),
        FlutterContextMenuItem(
          appLocalizations.deleteTheme,
          iconData: LucideIcons.trash2,
          status: MenuItemStatus.error,
          onPressed: () {
            DialogBuilder.showConfirmDialog(
              context,
              title: appLocalizations.deleteTheme,
              message: appLocalizations.deleteThemeConfirm,
              onTapConfirm: () {
                if (isDark) {
                  appProvider.deleteCustomDarkTheme(customIndex);
                } else {
                  appProvider.deleteCustomLightTheme(customIndex);
                }
                setState(() {
                  _selectedLightIndex = ChewieHiveUtil.getLightThemeIndex();
                  _selectedDarkIndex = ChewieHiveUtil.getDarkThemeIndex();
                });
              },
            );
          },
        ),
      ],
    );
  }

  void _createNewTheme(bool isDark) {
    final allThemes = isDark
        ? ChewieThemeColorData.defaultDarkThemes
        : ChewieThemeColorData.defaultLightThemes;
    final customThemes =
        isDark ? appProvider.customDarkThemes : appProvider.customLightThemes;

    BottomSheetBuilder.showBottomSheet(
      context,
      responsive: true,
      (ctx) => _MenuListSheet(
        title: appLocalizations.chooseBaseTheme,
        items: [
          ...allThemes.map((theme) => _MenuAction(
                label: theme.i18nName,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _navigateToEditor(theme, isDark);
                },
              )),
          ...customThemes.map((theme) => _MenuAction(
                label: theme.name,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _navigateToEditor(theme, isDark);
                },
              )),
          _MenuAction(isDivider: true),
          _MenuAction(
            label: appLocalizations.importFromClipboard,
            icon: Icons.content_paste_rounded,
            onTap: () {
              Navigator.of(ctx).pop();
              _importFromClipboard(isDark);
            },
          ),
          _MenuAction(
            label: appLocalizations.importFromFile,
            icon: Icons.file_open_outlined,
            onTap: () {
              Navigator.of(ctx).pop();
              _importFromFile(isDark);
            },
          ),
        ],
      ),
    );
  }

  void _navigateToEditor(ChewieThemeColorData baseTheme, bool isDark,
      {int? editIndex}) {
    RouteUtil.pushDialogRoute(
      context,
      ThemeEditorScreen(
        baseTheme: baseTheme,
        isDarkMode: isDark,
        editIndex: editIndex,
      ),
      onThen: (_) {
        setState(() {
          _selectedLightIndex = ChewieHiveUtil.getLightThemeIndex();
          _selectedDarkIndex = ChewieHiveUtil.getDarkThemeIndex();
        });
      },
    );
  }

  void _showCustomThemeOptions(bool isDark, int customIndex) {
    final themes =
        isDark ? appProvider.customDarkThemes : appProvider.customLightThemes;
    final theme = themes[customIndex];

    BottomSheetBuilder.showBottomSheet(
      context,
      responsive: true,
      (ctx) => _MenuListSheet(
        title: theme.name,
        items: [
          _MenuAction(
            label: appLocalizations.editTheme,
            icon: Icons.edit_outlined,
            onTap: () {
              Navigator.of(ctx).pop();
              _navigateToEditor(theme, isDark, editIndex: customIndex);
            },
          ),
          _MenuAction(
            label: appLocalizations.duplicateTheme,
            icon: Icons.copy_outlined,
            onTap: () {
              Navigator.of(ctx).pop();
              final copy = theme.copyWith(
                id: ChewieThemeColorData.generateId(),
                name: '${theme.name} (copy)',
              );
              if (isDark) {
                appProvider.addCustomDarkTheme(copy);
              } else {
                appProvider.addCustomLightTheme(copy);
              }
              setState(() {});
            },
          ),
          _MenuAction(isDivider: true),
          _MenuAction(
            label: appLocalizations.exportToClipboard,
            icon: Icons.content_copy_outlined,
            onTap: () {
              Navigator.of(ctx).pop();
              ThemeUtil.exportToClipboard(context, theme);
              IToast.showTop(appLocalizations.themeExportSuccess);
            },
          ),
          _MenuAction(
            label: appLocalizations.exportToFile,
            icon: Icons.save_outlined,
            onTap: () async {
              Navigator.of(ctx).pop();
              final ok = await ThemeUtil.exportToFile(theme);
              if (ok) IToast.showTop(appLocalizations.themeExportSuccess);
            },
          ),
          _MenuAction(isDivider: true),
          _MenuAction(
            label: appLocalizations.deleteTheme,
            icon: Icons.delete_outline,
            isDestructive: true,
            onTap: () {
              Navigator.of(ctx).pop();
              DialogBuilder.showConfirmDialog(
                context,
                title: appLocalizations.deleteTheme,
                message: appLocalizations.deleteThemeConfirm,
                onTapConfirm: () {
                  if (isDark) {
                    appProvider.deleteCustomDarkTheme(customIndex);
                  } else {
                    appProvider.deleteCustomLightTheme(customIndex);
                  }
                  setState(() {
                    _selectedLightIndex = ChewieHiveUtil.getLightThemeIndex();
                    _selectedDarkIndex = ChewieHiveUtil.getDarkThemeIndex();
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _importFromClipboard(bool isDark) async {
    final theme = await ThemeUtil.importFromClipboard();
    if (theme == null) {
      IToast.showTop(appLocalizations.themeImportFailed);
      return;
    }
    _addImportedTheme(theme, isDark);
  }

  Future<void> _importFromFile(bool isDark) async {
    final theme = await ThemeUtil.importFromFile();
    if (theme == null) {
      IToast.showTop(appLocalizations.themeImportFailed);
      return;
    }
    _addImportedTheme(theme, isDark);
  }

  void _addImportedTheme(ChewieThemeColorData theme, bool isDark) {
    final imported = theme.copyWith(
      isDarkMode: isDark,
      id: ChewieThemeColorData.generateId(),
    );
    if (isDark) {
      appProvider.addCustomDarkTheme(imported);
    } else {
      appProvider.addCustomLightTheme(imported);
    }
    IToast.showTop(appLocalizations.themeImportSuccess);
    setState(() {});
  }

  Widget _buildAccentColorPalette({required bool isDark}) {
    final selectedIndex =
        isDark ? _darkPrimaryColorIndex : _lightPrimaryColorIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildAccentCircle(
            color: null,
            label: appLocalizations.resetToDefault,
            isSelected: selectedIndex == 0,
            onTap: () {
              setState(() {
                if (isDark) {
                  _darkPrimaryColorIndex = 0;
                  appProvider.setDarkPrimaryColorOverride(null, 0);
                } else {
                  _lightPrimaryColorIndex = 0;
                  appProvider.setLightPrimaryColorOverride(null, 0);
                }
              });
            },
          ),
          for (int i = 0; i < _presetAccentColors.length; i++)
            _buildAccentCircle(
              color: _presetAccentColors[i],
              isSelected: selectedIndex == i + 1,
              onTap: () {
                setState(() {
                  final paletteIndex = i + 1;
                  if (isDark) {
                    _darkPrimaryColorIndex = paletteIndex;
                    appProvider.setDarkPrimaryColorOverride(
                        _presetAccentColors[i], paletteIndex);
                  } else {
                    _lightPrimaryColorIndex = paletteIndex;
                    appProvider.setLightPrimaryColorOverride(
                        _presetAccentColors[i], paletteIndex);
                  }
                });
              },
            ),
          _buildAccentCircle(
            color: null,
            icon: Icons.colorize,
            label: appLocalizations.customColor,
            isSelected: selectedIndex == _presetAccentColors.length + 1,
            onTap: () {
              final currentColor = isDark
                  ? (ChewieHiveUtil.getCustomDarkPrimaryColor() ??
                      ChewieTheme.primaryColor)
                  : (ChewieHiveUtil.getCustomLightPrimaryColor() ??
                      ChewieTheme.primaryColor);
              ColorPickerBottomSheet.show(
                context,
                initialColor: currentColor,
                title: appLocalizations.customColor,
                onColorChanged: (color) {
                  setState(() {
                    final paletteIndex = _presetAccentColors.length + 1;
                    if (isDark) {
                      _darkPrimaryColorIndex = paletteIndex;
                      appProvider.setDarkPrimaryColorOverride(
                          color, paletteIndex);
                    } else {
                      _lightPrimaryColorIndex = paletteIndex;
                      appProvider.setLightPrimaryColorOverride(
                          color, paletteIndex);
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccentCircle({
    Color? color,
    IconData? icon,
    String? label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: label ?? '',
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? ChewieTheme.primaryColor
                  : ChewieTheme.dividerColor,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 18, color: ChewieTheme.iconColor)
              : (color == null
                  ? Icon(Icons.format_color_reset,
                      size: 18, color: ChewieTheme.iconColor)
                  : (isSelected
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null)),
        ),
      ),
    );
  }
}

class _MenuAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDivider;
  final bool isDestructive;

  _MenuAction({
    this.label = '',
    this.icon,
    this.onTap,
    this.isDivider = false,
    this.isDestructive = false,
  });
}

class _MenuListSheet extends StatelessWidget {
  final String title;
  final List<_MenuAction> items;

  const _MenuListSheet({required this.title, required this.items});

  static const Radius _radius = ChewieDimens.defaultRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      child: Wrap(
        runAlignment: WrapAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                  top: _radius,
                  bottom:
                      ResponsiveUtil.isWideDevice() ? _radius : Radius.zero),
              color: ChewieTheme.scaffoldBackgroundColor,
              border: ChewieTheme.border,
              boxShadow: ChewieTheme.defaultBoxShadow,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    child: Text(title, style: ChewieTheme.titleLarge),
                  ),
                  ...items.map((item) {
                    if (item.isDivider) {
                      return const MyDivider(
                        vertical: 8,
                        horizontal: 4,
                        width: 1,
                      );
                    }
                    return InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(item.icon,
                                  size: 22,
                                  color: item.isDestructive
                                      ? ChewieTheme.errorColor
                                      : ChewieTheme.iconColor),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Text(
                                item.label,
                                style: ChewieTheme.bodyLarge.copyWith(
                                  color: item.isDestructive
                                      ? ChewieTheme.errorColor
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
