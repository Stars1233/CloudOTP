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
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../Utils/app_provider.dart';
import '../l10n/l10n.dart';

class FeatureShowcaseScreen extends StatefulWidget {
  final bool isDialog;

  const FeatureShowcaseScreen({super.key, this.isDialog = false});

  static const String routeName = "/feature/showcase";

  /// Show as a compact dialog suitable for landscape/desktop layouts.
  static void showAsDialog(BuildContext context) {
    DialogBuilder.showPageDialog(
      context,
      preferMinWidth: 460,
      preferMinHeight: 640,
      child: const FeatureShowcaseScreen(isDialog: true),
    );
  }

  @override
  State<FeatureShowcaseScreen> createState() => _FeatureShowcaseScreenState();
}

class _FeatureShowcaseScreenState
    extends BaseDynamicState<FeatureShowcaseScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page accent colors
  static const Color _tokenColor = Color(0xFF4A6CF7);
  static const Color _cloudColor = Color(0xFF42A5F5);
  static const Color _iconColor = Color(0xFFFF7043);
  static const Color _securityColor = Color(0xFF66BB6A);
  static const Color _platformColor = Color(0xFF26C6DA);
  static const Color _migrationColor = Color(0xFFAB47BC);
  static const Color _convenienceColor = Color(0xFFFFA726);
  static const Color _customizeColor = Color(0xFFEC407A);

  late final List<({Color color, Widget Function() build})> _pages = [
    (color: _tokenColor, build: _buildTokenPage),
    (color: _platformColor, build: _buildPlatformPage),
    (color: _cloudColor, build: _buildCloudPage),
    (color: _iconColor, build: _buildIconPage),
    (color: _securityColor, build: _buildSecurityPage),
    (color: _migrationColor, build: _buildImportExportPage),
    (color: _convenienceColor, build: _buildConveniencePage),
    (color: _customizeColor, build: _buildCustomizePage),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index].build(),
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(_pages.length),
        const SizedBox(height: 16),
        _buildStartTourButton(),
        SizedBox(height: widget.isDialog
            ? 16
            : MediaQuery.of(context).padding.bottom + 24),
      ],
    );

    if (widget.isDialog) {
      return body;
    }

    return Scaffold(
      backgroundColor: ChewieTheme.scaffoldBackgroundColor,
      appBar: ResponsiveAppBar(
        title: appLocalizations.featureShowcaseTitle,
        showBack: true,
        showBorder: false,
      ),
      body: body,
    );
  }

  // ============================================================
  // Shared components
  // ============================================================

  Widget _buildHero({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withAlpha(50),
                color.withAlpha(15),
              ],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(70), width: 1),
          ),
          child: Icon(icon, size: 34, color: color),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: ChewieTheme.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            subtitle,
            style: ChewieTheme.bodyMedium.copyWith(
              color: ChewieTheme.bodyMedium.color?.withAlpha(170),
              fontSize: 12.5,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Each page: hero + content centered together as one block.
  Widget _buildPage({
    required Widget hero,
    required Widget content,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    hero,
                    const SizedBox(height: 20),
                    content,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(IconData icon, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Page 1 — Multi-Token Support
  // ============================================================

  Widget _buildTokenPage() {
    final types = [
      ('TOTP', appLocalizations.featureTokenTOTPDesc, LucideIcons.clock),
      ('HOTP', appLocalizations.featureTokenHOTPDesc, LucideIcons.hash),
      ('MOTP', appLocalizations.featureTokenMOTPDesc, LucideIcons.smartphone),
      ('Steam', appLocalizations.featureTokenSteamDesc, LucideIcons.gamepad2),
      ('Yandex', appLocalizations.featureTokenYandexDesc, LucideIcons.atSign),
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.keyRound,
        color: _tokenColor,
        title: appLocalizations.featureTokenTitle,
        subtitle: appLocalizations.featureTokenDescription,
      ),
      content: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: types
                .map((t) => _buildTokenTypeCard(t.$1, t.$2, t.$3))
                .toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip(label: 'SHA1', color: _tokenColor),
              _buildChip(label: 'SHA256', color: _tokenColor),
              _buildChip(label: 'SHA512', color: _tokenColor),
              _buildChip(label: '5–8 digits', color: _tokenColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenTypeCard(String name, String desc, IconData icon) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: _tokenColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _tokenColor.withAlpha(50), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: _tokenColor),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ChewieTheme.titleLarge.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              fontSize: 10.5,
              color: ChewieTheme.bodyMedium.color?.withAlpha(160),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 2 — Platforms
  // ============================================================

  Widget _buildPlatformPage() {
    final platforms = [
      (LucideIcons.smartphone, 'Android'),
      (LucideIcons.smartphone, 'iOS'),
      (LucideIcons.monitor, 'Windows'),
      (LucideIcons.laptop, 'macOS'),
      (LucideIcons.monitor, 'Linux'),
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.layoutPanelTop,
        color: _platformColor,
        title: appLocalizations.featurePlatformTitle,
        subtitle: appLocalizations.featurePlatformDescription,
      ),
      content: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: platforms
                .map((p) => _buildPlatformCard(p.$1, p.$2))
                .toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip(
                label: appLocalizations.featurePlatformSync,
                color: _platformColor,
                icon: LucideIcons.refreshCw,
              ),
              _buildChip(
                label: appLocalizations.featurePlatformResponsive,
                color: _platformColor,
                icon: LucideIcons.maximize2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformCard(IconData icon, String name) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _platformColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _platformColor.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: _platformColor),
          const SizedBox(height: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ChewieTheme.titleLarge.color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 3 — Cloud Backup
  // ============================================================

  Widget _buildCloudPage() {
    final services = [
      'WebDAV',
      'OneDrive',
      'Google Drive',
      'Dropbox',
      'S3',
      'Huawei Cloud',
      'Box',
      'Aliyun Drive',
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.cloudUpload,
        color: _cloudColor,
        title: appLocalizations.featureCloudTitle,
        subtitle: appLocalizations.featureCloudDescription,
      ),
      content: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: services
                .map((s) => _buildChip(
                      label: s,
                      color: _cloudColor,
                      icon: LucideIcons.cloud,
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: _cloudColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _cloudColor.withAlpha(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBadge(
                    LucideIcons.refreshCw,
                    appLocalizations.featureCloudAuto,
                    _cloudColor),
                _buildBadge(
                    LucideIcons.lock,
                    appLocalizations.featureCloudEncrypted,
                    _cloudColor),
                _buildBadge(
                    LucideIcons.fileText,
                    appLocalizations.featureCloudLog,
                    _cloudColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Page 4 — Smart Icons
  // ============================================================

  Widget _buildIconPage() {
    final brands = [
      'google.png',
      'github.png',
      'microsoft.png',
      'apple.png',
      'amazon.png',
      'discord.png',
      'steam.png',
      'slack.png',
      'dropbox.png',
      'paypal.png',
      'netflix.png',
      'spotify.png',
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.image,
        color: _iconColor,
        title: appLocalizations.featureIconTitle,
        subtitle: appLocalizations.featureIconDescription(2500),
      ),
      content: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
              children: brands.map(_buildBrandIcon).toList(),
            ),
          ),
          const SizedBox(height: 18),
          _buildChip(
            label: '2500+',
            color: _iconColor,
            icon: LucideIcons.sparkles,
          ),
        ],
      ),
    );
  }

  Widget _buildBrandIcon(String filename) {
    return Container(
      decoration: BoxDecoration(
        color: ChewieTheme.canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ChewieTheme.borderColor),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        'assets/brand/$filename',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(LucideIcons.image, color: _iconColor, size: 18),
      ),
    );
  }

  // ============================================================
  // Page 5 — Security (+ Open Source)
  // ============================================================

  Widget _buildSecurityPage() {
    final features = [
      (LucideIcons.databaseBackup, appLocalizations.featureSecurityEncryption),
      (LucideIcons.fingerprint, appLocalizations.featureSecurityBiometric),
      (LucideIcons.lockKeyhole, appLocalizations.featureSecurityGesture),
      (LucideIcons.timer, appLocalizations.featureSecurityAutoLock),
      (LucideIcons.eyeOff, appLocalizations.featureSecuritySafeMode),
      (LucideIcons.shieldEllipsis,
          appLocalizations.featureSecurityBackupEncrypt),
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.shieldCheck,
        color: _securityColor,
        title: appLocalizations.featureSecurityTitle,
        subtitle: appLocalizations.featureSecurityDescription,
      ),
      content: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 3.4,
              children: features
                  .map((f) => _buildSecurityItem(f.$1, f.$2))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Open source highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _securityColor.withAlpha(40),
                  _securityColor.withAlpha(15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _securityColor.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.github, size: 18, color: _securityColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    appLocalizations.featureSecurityOpenSource,
                    style: TextStyle(
                      color: _securityColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip(
                label: 'AES-256-GCM',
                color: _securityColor,
                icon: LucideIcons.lock,
              ),
              _buildChip(
                label: 'Argon2',
                color: _securityColor,
                icon: LucideIcons.key,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _securityColor.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _securityColor.withAlpha(45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _securityColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: ChewieTheme.titleLarge.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 6 — Import & Export
  // ============================================================

  Widget _buildImportExportPage() {
    final imports = [
      'Google Auth',
      'Aegis',
      '2FAS',
      'Bitwarden',
      'andOTP',
      'Ente Auth',
      'FreeOTP+',
      'TOTP Auth',
      'WinAuth',
    ];
    final exports = [
      appLocalizations.featureExportEncrypted,
      appLocalizations.featureExportUri,
      appLocalizations.featureExportCloudOTPQR,
      appLocalizations.featureExportGoogleQR,
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.arrowLeftRight,
        color: _migrationColor,
        title: appLocalizations.featureImportExportTitle,
        subtitle: appLocalizations.featureImportExportDescription,
      ),
      content: Column(
        children: [
          _buildSectionLabel(
            LucideIcons.download,
            appLocalizations.featureImportSection,
            _migrationColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: imports
                .map((s) => _buildChip(label: s, color: _migrationColor))
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip(
                label: appLocalizations.featureImportScan,
                color: _migrationColor,
                icon: LucideIcons.scanLine,
              ),
              _buildChip(
                label: appLocalizations.featureImportClipboard,
                color: _migrationColor,
                icon: LucideIcons.clipboard,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionLabel(
            LucideIcons.upload,
            appLocalizations.featureExportSection,
            _migrationColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: exports
                .map((s) => _buildChip(
                      label: s,
                      color: _migrationColor,
                      icon: s.contains('QR') ||
                              s.contains('二维') ||
                              s.contains('二維') ||
                              s.contains('QR')
                          ? LucideIcons.qrCode
                          : LucideIcons.fileText,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 7 — Convenience
  // ============================================================

  Widget _buildConveniencePage() {
    final features = [
      (LucideIcons.search, appLocalizations.featureQuickSearch),
      (LucideIcons.arrowUpDown, appLocalizations.featureSort),
      (LucideIcons.shapes, appLocalizations.featureCategories),
      (LucideIcons.listChecks, appLocalizations.featureMultiSelect),
      (LucideIcons.pin, appLocalizations.featurePinTop),
      (LucideIcons.arrowLeftRight, appLocalizations.featureSwipe),
      (LucideIcons.move, appLocalizations.featureDragReorder),
      (LucideIcons.copy, appLocalizations.featureAutoCopy),
      (LucideIcons.qrCode, appLocalizations.featureQRScanner),
    ];
    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.zap,
        color: _convenienceColor,
        title: appLocalizations.featureConvenienceTitle,
        subtitle: appLocalizations.featureConvenienceDescription,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
          children: features
              .map((f) => _buildConvenienceCard(f.$1, f.$2))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildConvenienceCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: _convenienceColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _convenienceColor.withAlpha(50)),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: _convenienceColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: ChewieTheme.titleLarge.color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Page 8 — Customization (+ custom themes)
  // ============================================================

  Widget _buildCustomizePage() {
    const themeColors = [
      Color(0xFF009BFF),
      Color(0xFF3790A4),
      Color(0xFFF588A8),
      Color(0xFF11B667),
      Color(0xFF454D66),
      Color(0xFF272643),
      Color(0xFFE74645),
      Color(0xFF361D32),
      Color(0xFFF8BE5F),
      Color(0xFF0084FF),
    ];

    return _buildPage(
      hero: _buildHero(
        icon: LucideIcons.palette,
        color: _customizeColor,
        title: appLocalizations.featureCustomizeTitle,
        subtitle: appLocalizations.featureCustomizeDescription,
      ),
      content: Column(
        children: [
          _buildSectionLabel(
            LucideIcons.droplet,
            appLocalizations.featureThemeColors,
            _customizeColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: themeColors
                .map((c) => Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: ChewieTheme.borderColor, width: 1),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          _buildChip(
            label: appLocalizations.featureCustomThemeEditor,
            color: _customizeColor,
            icon: LucideIcons.pencilLine,
          ),
          const SizedBox(height: 14),
          _buildSectionLabel(
            LucideIcons.layoutGrid,
            appLocalizations.featureLayoutStyles,
            _customizeColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLayoutPreview(
                  LucideIcons.layoutGrid, appLocalizations.simpleLayoutType),
              _buildLayoutPreview(LucideIcons.layoutDashboard,
                  appLocalizations.compactLayoutType),
              _buildLayoutPreview(LucideIcons.layoutTemplate,
                  appLocalizations.spotlightLayoutType),
              _buildLayoutPreview(
                  LucideIcons.layoutList, appLocalizations.listLayoutType),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildChip(
                  label: appLocalizations.featureGlassEffect,
                  color: _customizeColor,
                  icon: LucideIcons.sparkles),
              _buildChip(
                  label: appLocalizations.featureCustomFont,
                  color: _customizeColor,
                  icon: LucideIcons.type),
              _buildChip(
                  label: appLocalizations.featureMultiLang,
                  color: _customizeColor,
                  icon: LucideIcons.languages),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutPreview(IconData icon, String label) {
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _customizeColor.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _customizeColor.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _customizeColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: _customizeColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Indicators & Buttons
  // ============================================================

  Widget _buildPageIndicator(int total) {
    final activeColor = _pages[_currentPage].color;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 18 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor
                : activeColor.withAlpha(50),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildStartTourButton() {
    if (!ResponsiveUtil.isMobile() || widget.isDialog) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              homeScreenState?.showCoachMark();
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: _pages[_currentPage].color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            appLocalizations.featureShowcaseStartTour,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
