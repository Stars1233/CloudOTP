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

import 'package:cloudotp/Models/token_category_binding.dart';

import '../../Models/opt_token.dart';
import '../../Models/token_category.dart';
import '../../Screens/Token/import_preview_screen.dart';

enum DecryptResult {
  success,
  noFileInZip,
  invalidPasswordOrDataCorrupted,
}

abstract class BaseTokenImporter {
  Future<void> importFromPath(
    String path, {
    bool showLoading = true,
  });

  static importResult(ImporterResult res) async {
    for (TokenCategoryBinding binding in res.bindings) {
      res.categories
          .where((element) => element.uid == binding.categoryUid)
          .forEach((element) {
        element.bindings.add(binding.tokenUid);
      });
    }
    ImportPreviewScreen.show(
      tokens: res.tokens,
      categories: res.categories,
      errors: res.errors,
    );
  }
}

class ImporterResult {
  final List<OtpToken> tokens;
  final List<TokenCategory> categories;
  final List<TokenCategoryBinding> bindings;
  final List<ImportTokenError> errors;

  ImporterResult(this.tokens, this.categories, this.bindings,
      [this.errors = const []]);
}

class ImportTokenError {
  final String issuer;
  final String account;
  final String reason;

  ImportTokenError({
    required this.issuer,
    required this.account,
    required this.reason,
  });
}
