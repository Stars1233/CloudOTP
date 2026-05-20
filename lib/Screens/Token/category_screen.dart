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
import 'package:cloudotp/Database/token_category_binding_dao.dart';
import 'package:cloudotp/Models/opt_token.dart';
import 'package:cloudotp/Utils/app_provider.dart';
import 'package:cloudotp/Widgets/BottomSheet/select_token_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../Database/category_dao.dart';
import '../../Models/token_category.dart';
import '../../l10n/l10n.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
  });

  static const String routeName = "/token/category";

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends BaseDynamicState<CategoryScreen>
    with TickerProviderStateMixin {
  List<TokenCategory> categories = [];
  Map<String, List<OtpToken>> _categoryTokens = {};

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  getCategories() async {
    await CategoryDao.listCategories().then((value) {
      setState(() {
        categories = value;
      });
      _loadTokensForCategories();
    });
  }

  Future<void> _loadTokensForCategories() async {
    final Map<String, List<OtpToken>> result = {};
    for (final category in categories) {
      result[category.uid] = await BindingDao.getTokens(category.uid);
    }
    setState(() {
      _categoryTokens = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: ResponsiveAppBar(
        title: appLocalizations.category,
        showBorder: true,
        showBack: !ResponsiveUtil.isLandscapeLayout(),
        titleLeftMargin: ResponsiveUtil.isLandscapeLayout() ? 15 : 5,
        desktopActions: [
          ToolButton(
            context: context,
            icon: LucideIcons.plus,
            buttonSize: const Size(32, 32),
            onPressed: _add,
          ),
        ],
        actions: [
          CircleIconButton(
            icon: Icon(LucideIcons.plus, color: ChewieTheme.iconColor),
            onTap: _add,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(),
      ),
    );
  }

  _add() {
    InputValidateAsyncController validateAsyncController =
        InputValidateAsyncController(
      validator: (text) async {
        if (text.isEmpty) {
          return appLocalizations.categoryNameCannotBeEmpty;
        }
        if (await CategoryDao.isCategoryExist(text)) {
          return appLocalizations.categoryNameDuplicate;
        }
        return null;
      },
      controller: TextEditingController(),
    );
    GlobalKey<InputBottomSheetState> key = GlobalKey();
    BottomSheetBuilder.showBottomSheet(context, responsive: true, (context) {
      return InputBottomSheet(
        key: key,
        title: appLocalizations.addCategory,
        hint: appLocalizations.inputCategory,
        validateAsyncController: validateAsyncController,
        style: InputItemStyle(
          maxLength: 32,
        ),
        onValidConfirm: (text) async {
          TokenCategory category = TokenCategory.title(title: text);
          await CategoryDao.insertCategory(category);
          categories.add(category);
          _categoryTokens[category.uid] = [];
          setState(() {});
          homeScreenState?.refreshCategories();
        },
      );
    });
  }

  _buildBody() {
    if (categories.isEmpty) {
      return EasyRefresh(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          children: [
            EmptyPlaceholder(text: appLocalizations.noCategory),
          ],
        ),
      );
    }
    return _buildGrid();
  }

  Widget _buildGrid() {
    return EasyRefresh(
      child: ReorderableGridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 30),
        gridDelegate: const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 480,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          preferredHeight: 72,
        ),
        cacheExtent: 9999,
        itemCount: categories.length,
        onReorder: _onReorder,
        proxyDecorator:
            (Widget child, int index, Animation<double> animation) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: ChewieTheme.defaultBoxShadow,
            ),
            child: child,
          );
        },
        itemBuilder: (context, index) {
          return _buildCategoryItem(categories[index]);
        },
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    TokenCategory oldCategory = categories[oldIndex];
    categories.removeAt(oldIndex);
    categories.insert(newIndex, oldCategory);
    for (int i = 0; i < categories.length; i++) {
      categories[i].seq = i;
    }
    CategoryDao.updateCategories(categories, backup: true);
    setState(() {});
    homeScreenState?.refreshCategories();
  }

  String _tokenSummary(TokenCategory category) {
    final tokens = _categoryTokens[category.uid] ?? [];
    if (tokens.isEmpty) return appLocalizations.noToken;
    final names = tokens.map((t) => t.issuer).take(3).toList();
    if (tokens.length > 3) {
      return '${names.join(', ')} ...';
    }
    return names.join(', ');
  }

  int _tokenCount(TokenCategory category) {
    return _categoryTokens[category.uid]?.length ?? 0;
  }

  Widget _buildCategoryItem(TokenCategory category) {
    final accent = ChewieTheme.primaryColor;
    final count = _tokenCount(category);
    final summary = _tokenSummary(category);
    return Container(
      key: ValueKey("${category.id}${category.title}"),
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
              color: accent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.shapes, size: 17, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.title,
                        style: ChewieTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  summary,
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
            icon:
                Icon(LucideIcons.pencil, size: 16, color: ChewieTheme.iconColor),
            onTap: () => _editCategory(category),
          ),
          CircleIconButton(
            icon: Icon(LucideIcons.listChecks,
                size: 16, color: ChewieTheme.iconColor),
            onTap: () => _editTokens(category),
          ),
          CircleIconButton(
            icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
            onTap: () => _deleteCategory(category),
          ),
        ],
      ),
    );
  }

  void _editCategory(TokenCategory category) {
    InputValidateAsyncController validateAsyncController =
        InputValidateAsyncController(
      validator: (text) async {
        if (text.isEmpty) {
          return appLocalizations.categoryNameCannotBeEmpty;
        }
        if (text != category.title &&
            await CategoryDao.isCategoryExist(text)) {
          return appLocalizations.categoryNameDuplicate;
        }
        return null;
      },
      controller: TextEditingController(),
    );
    BottomSheetBuilder.showBottomSheet(
      context,
      responsive: true,
      (context) => InputBottomSheet(
        title: appLocalizations.editCategoryName,
        hint: appLocalizations.inputCategory,
        style: InputItemStyle(
          maxLength: 32,
        ),
        text: category.title,
        validateAsyncController: validateAsyncController,
        onValidConfirm: (text) async {
          category.title = text;
          await CategoryDao.updateCategory(category);
          setState(() {});
          homeScreenState?.refreshCategories();
        },
      ),
    );
  }

  void _editTokens(TokenCategory category) {
    BottomSheetBuilder.showBottomSheet(
      context,
      responsive: true,
      (context) => SelectTokenBottomSheet(
        category: category,
        onChanged: () {
          _loadTokensForCategories();
        },
      ),
    );
  }

  void _deleteCategory(TokenCategory category) {
    DialogBuilder.showConfirmDialog(
      context,
      title: appLocalizations.deleteCategory,
      message: appLocalizations.deleteCategoryHint(category.title),
      confirmButtonText: appLocalizations.confirm,
      cancelButtonText: appLocalizations.cancel,
      onTapConfirm: () async {
        await CategoryDao.deleteCategory(category);
        IToast.showTop(
            appLocalizations.deleteCategorySuccess(category.title));
        categories.remove(category);
        _categoryTokens.remove(category.uid);
        setState(() {});
        homeScreenState?.refreshCategories();
      },
      onTapCancel: () {},
    );
  }
}
