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

import 'package:flutter/cupertino.dart';

import '../l10n/l10n.dart';

const defaultMaxBackupCount = 100;

const maxBackupCountThrehold = 500;

const maxBytesLength = 1000;

const double autoCopyNextCodeProgressThrehold = 0.25;
const int defaultHOTPPeriod = 15;
const String placeholderText = "*";
const String hotpPlaceholderText = "*";

const appLicense = "GPL-3.0";

String shareAppText = appLocalizations.shareAppText(cloudotpOfficialWebsite);
const String feedbackEmail = "2014027378@qq.com";
String feedbackSubject = appLocalizations.feedbackSubject;
const String feedbackBody = "";
const List<Locale> websiteSupportLocales = [Locale("en"), Locale("zh", "CN")];
String cloudotpOfficialWebsite = "https://otp.cloudchewie.com";
const String defaultDownloadsWebsite =
    "https://apps.cloudchewie.com/cloudotp/downloads";
const String downloadsWebsite =
    "https://apps.cloudchewie.com/{locale}/cloudotp/downloads";
const String sqlcipherLearnMore = "https://otp.cloudchewie.com/docs/sqlcipher";
const String telegramLink = "https://t.me/CloudOTP_official";
const String privacyPolicyWebsite = "https://otp.cloudchewie.com/privacy";
const String serviceTermWebsite = "https://otp.cloudchewie.com/service-term";

RegExp otpauthMigrationReg =
    RegExp(r"^otpauth-migration://offline\?data=(.*)$");
RegExp otpauthReg = RegExp(r"^otpauth://([a-z]+)/([^?]*)(.*)$");
RegExp motpReg = RegExp(r"^motp://([^?]+)\?secret=([a-fA-F\d]+)(.*)$");
RegExp cloudotpauthMigrationReg =
    RegExp(r"^cloudotpauth-migration://offline\?tokens=(.*)$");
RegExp cloudotpauthCategoryMigrationReg =
    RegExp(r"^cloudotpauth-migration://offline\?categories=(.*)$");

const double macosTitleBarLeftMargin = 92;
