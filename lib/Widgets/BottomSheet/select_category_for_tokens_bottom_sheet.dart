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
import 'package:cloudotp/Screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../../Database/category_dao.dart';
import '../../Models/opt_token.dart';
import '../../Models/token_category.dart';
import '../../l10n/l10n.dart';

class SelectCategoryForTokensBottomSheet extends StatefulWidget {
  const SelectCategoryForTokensBottomSheet({
    super.key,
    required this.tokens,
    required this.onCompleted,
  });

  final List<OtpToken> tokens;
  final VoidCallback onCompleted;

  @override
  State<SelectCategoryForTokensBottomSheet> createState() =>
      _SelectCategoryForTokensBottomSheetState();
}

class _SelectCategoryForTokensBottomSheetState
    extends BaseDynamicState<SelectCategoryForTokensBottomSheet> {
  List<TokenCategory> categories = [];
  GroupButtonController controller = GroupButtonController();

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
    });
  }

  Radius radius = ChewieDimens.defaultRadius;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runAlignment: WrapAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
                top: radius,
                bottom: ResponsiveUtil.isWideDevice() ? radius : Radius.zero),
            color: ChewieTheme.scaffoldBackgroundColor,
            border: ChewieTheme.border,
            boxShadow: ChewieTheme.defaultBoxShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildButtons(),
              _buildFooter(),
            ],
          ),
        ),
      ],
    );
  }

  _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.vertical(top: radius)),
      child: Text(
        textAlign: TextAlign.center,
        appLocalizations.setCategoryForTokens(widget.tokens.length),
        style: ChewieTheme.titleLarge,
      ),
    );
  }

  _buildButtons() {
    return categories.isNotEmpty
        ? ItemBuilder.buildGroupButtons(
            isRadio: false,
            enableDeselect: true,
            constraintWidth: false,
            buttons: categories.map((e) => e.title).toList(),
            controller: controller,
            radius: 8,
          )
        : EmptyPlaceholder(
            text: appLocalizations.noCategory,
            onTap: () {
              HomeScreenState.addCategory(
                context,
                onAdded: (category) {
                  setState(() {
                    categories.add(category);
                  });
                },
              );
            },
          );
  }

  _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(flex: 2, child: SizedBox(height: 50)),
          if (categories.isNotEmpty)
            Expanded(
              flex: 1,
              child: RoundIconTextButton(
                background: ChewieTheme.primaryColor,
                text: appLocalizations.save,
                onPressed: () async {
                  List<int> selectedIndexes =
                      controller.selectedIndexes.toList();
                  List<String> selectedCategoryUids =
                      selectedIndexes.map((e) => categories[e].uid).toList();
                  Navigator.of(context).pop();
                  for (OtpToken token in widget.tokens) {
                    List<String> existingUids =
                        await BindingDao.getCategoryUids(token.uid);
                    List<String> newUids = selectedCategoryUids
                        .where((uid) => !existingUids.contains(uid))
                        .toList();
                    if (newUids.isNotEmpty) {
                      await BindingDao.bingdingsForToken(token.uid, newUids);
                    }
                  }
                  IToast.showTop(appLocalizations.saveSuccess);
                  widget.onCompleted();
                },
                fontSizeDelta: 2,
              ),
            ),
        ],
      ),
    );
  }
}
