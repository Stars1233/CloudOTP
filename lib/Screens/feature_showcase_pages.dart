import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../l10n/l10n.dart';

mixin FeatureShowcasePages {
  static const Color tokenColor = Color(0xFF4A6CF7);
  static const Color cloudColor = Color(0xFF42A5F5);
  static const Color iconColor = Color(0xFFFF7043);
  static const Color securityColor = Color(0xFF66BB6A);
  static const Color platformColor = Color(0xFF26C6DA);
  static const Color migrationColor = Color(0xFFAB47BC);
  static const Color convenienceColor = Color(0xFFFFA726);
  static const Color customizeColor = Color(0xFFEC407A);

  List<({Color color, Widget Function() build})> get featurePages => [
        (color: tokenColor, build: buildTokenPage),
        (color: platformColor, build: buildPlatformPage),
        (color: cloudColor, build: buildCloudPage),
        (color: iconColor, build: buildIconPage),
        (color: securityColor, build: buildSecurityPage),
        (color: migrationColor, build: buildImportExportPage),
        (color: convenienceColor, build: buildConveniencePage),
        (color: customizeColor, build: buildCustomizePage),
      ];

  Widget buildHero({
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

  Widget buildChip({
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
            style: ChewieTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget buildSectionLabel(IconData icon, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: ChewieTheme.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // Page 1 — Multi-Token Support
  Widget buildTokenPage() {
    final types = [
      ('TOTP', appLocalizations.featureTokenTOTPDesc, LucideIcons.clock),
      ('HOTP', appLocalizations.featureTokenHOTPDesc, LucideIcons.hash),
      ('MOTP', appLocalizations.featureTokenMOTPDesc, LucideIcons.smartphone),
      ('Steam', appLocalizations.featureTokenSteamDesc, LucideIcons.gamepad2),
      ('Yandex', appLocalizations.featureTokenYandexDesc, LucideIcons.atSign),
    ];
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.keyRound,
        color: tokenColor,
        title: appLocalizations.featureTokenTitle,
        subtitle: appLocalizations.featureTokenDescription,
      ),
      content: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children:
                types.map((t) => _buildTokenTypeCard(t.$1, t.$2, t.$3)).toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              buildChip(label: 'SHA1', color: tokenColor),
              buildChip(label: 'SHA256', color: tokenColor),
              buildChip(label: 'SHA512', color: tokenColor),
              buildChip(label: '5–8 digits', color: tokenColor),
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
        color: tokenColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tokenColor.withAlpha(50), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: tokenColor),
          const SizedBox(height: 6),
          Text(
            name,
            style: ChewieTheme.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: ChewieTheme.titleLarge.color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: ChewieTheme.labelSmall.copyWith(
              fontSize: 10.5,
              color: ChewieTheme.bodyMedium.color?.withAlpha(160),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Page 2 — Platforms
  Widget buildPlatformPage() {
    final platforms = [
      (LucideIcons.smartphone, 'Android'),
      (LucideIcons.smartphone, 'iOS'),
      (LucideIcons.monitor, 'Windows'),
      (LucideIcons.laptop, 'macOS'),
      (LucideIcons.monitor, 'Linux'),
    ];
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.layoutPanelTop,
        color: platformColor,
        title: appLocalizations.featurePlatformTitle,
        subtitle: appLocalizations.featurePlatformDescription,
      ),
      content: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children:
                platforms.map((p) => _buildPlatformCard(p.$1, p.$2)).toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              buildChip(
                label: appLocalizations.featurePlatformSync,
                color: platformColor,
                icon: LucideIcons.refreshCw,
              ),
              buildChip(
                label: appLocalizations.featurePlatformResponsive,
                color: platformColor,
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
        color: platformColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: platformColor.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: platformColor),
          const SizedBox(height: 6),
          Text(
            name,
            style: ChewieTheme.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: ChewieTheme.titleLarge.color,
            ),
          ),
        ],
      ),
    );
  }

  // Page 3 — Cloud Backup
  Widget buildCloudPage() {
    final services = [
      'WebDAV', 'OneDrive', 'Google Drive', 'Dropbox',
      'S3', 'Huawei Cloud', 'Box', 'Aliyun Drive',
    ];
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.cloudUpload,
        color: cloudColor,
        title: appLocalizations.featureCloudTitle,
        subtitle: appLocalizations.featureCloudDescription,
      ),
      content: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: services
                  .map((s) => buildChip(
                        label: s,
                        color: cloudColor,
                        icon: LucideIcons.cloud,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: cloudColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cloudColor.withAlpha(50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBadge(LucideIcons.refreshCw,
                      appLocalizations.featureCloudAuto, cloudColor),
                  _buildBadge(LucideIcons.lock,
                      appLocalizations.featureCloudEncrypted, cloudColor),
                  _buildBadge(LucideIcons.fileText,
                      appLocalizations.featureCloudLog, cloudColor),
                ],
              ),
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
          style: ChewieTheme.labelSmall.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // Page 4 — Smart Icons
  Widget buildIconPage() {
    final brands = [
      'google.png', 'github.png', 'microsoft.png', 'apple.png',
      'amazon.png', 'discord.png', 'steam.png', 'slack.png',
      'dropbox.png', 'paypal.png', 'netflix.png', 'spotify.png',
    ];
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.image,
        color: iconColor,
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
          buildChip(
            label: '2500+',
            color: iconColor,
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
            Icon(LucideIcons.image, color: iconColor, size: 18),
      ),
    );
  }

  // Page 5 — Security
  Widget buildSecurityPage() {
    final features = [
      (LucideIcons.databaseBackup, appLocalizations.featureSecurityEncryption),
      (LucideIcons.fingerprint, appLocalizations.featureSecurityBiometric),
      (LucideIcons.lockKeyhole, appLocalizations.featureSecurityGesture),
      (LucideIcons.timer, appLocalizations.featureSecurityAutoLock),
      (LucideIcons.eyeOff, appLocalizations.featureSecuritySafeMode),
      (LucideIcons.shieldEllipsis,
          appLocalizations.featureSecurityBackupEncrypt),
    ];
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.shieldCheck,
        color: securityColor,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  securityColor.withAlpha(40),
                  securityColor.withAlpha(15),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: securityColor.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.github, size: 18, color: securityColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    appLocalizations.featureSecurityOpenSource,
                    style: ChewieTheme.labelSmall.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: securityColor,
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
              buildChip(
                label: 'AES-256-GCM',
                color: securityColor,
                icon: LucideIcons.lock,
              ),
              buildChip(
                label: 'Argon2',
                color: securityColor,
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
        color: securityColor.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: securityColor.withAlpha(45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: securityColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: ChewieTheme.labelSmall.copyWith(
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

  // Page 6 — Import & Export
  Widget buildImportExportPage() {
    final imports = [
      'Google Auth', 'Aegis', '2FAS', 'Bitwarden', 'andOTP',
      'Ente Auth', 'FreeOTP+', 'TOTP Auth', 'WinAuth',
    ];
    final exports = [
      appLocalizations.featureExportEncrypted,
      appLocalizations.featureExportUri,
      appLocalizations.featureExportCloudOTPQR,
      appLocalizations.featureExportGoogleQR,
    ];
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.arrowLeftRight,
        color: migrationColor,
        title: appLocalizations.featureImportExportTitle,
        subtitle: appLocalizations.featureImportExportDescription,
      ),
      content: Column(
        children: [
          buildSectionLabel(
            LucideIcons.download,
            appLocalizations.featureImportSection,
            migrationColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: imports
                .map((s) => buildChip(label: s, color: migrationColor))
                .toList(),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              buildChip(
                label: appLocalizations.featureImportScan,
                color: migrationColor,
                icon: LucideIcons.scanLine,
              ),
              buildChip(
                label: appLocalizations.featureImportClipboard,
                color: migrationColor,
                icon: LucideIcons.clipboard,
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSectionLabel(
            LucideIcons.upload,
            appLocalizations.featureExportSection,
            migrationColor,
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: exports
                .map((s) => buildChip(
                      label: s,
                      color: migrationColor,
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

  // Page 7 — Convenience
  Widget buildConveniencePage() {
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
    return buildPage(
      hero: buildHero(
        icon: LucideIcons.zap,
        color: convenienceColor,
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
        color: convenienceColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: convenienceColor.withAlpha(50)),
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: convenienceColor),
          const SizedBox(height: 6),
          Text(
            label,
            style: ChewieTheme.labelSmall.copyWith(
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

  // Page 8 — Customization
  Widget buildCustomizePage() {
    const themeColors = [
      Color(0xFF009BFF), Color(0xFF3790A4), Color(0xFFF588A8),
      Color(0xFF11B667), Color(0xFF454D66), Color(0xFF272643),
      Color(0xFFE74645), Color(0xFF361D32), Color(0xFFF8BE5F),
      Color(0xFF0084FF),
    ];

    return buildPage(
      hero: buildHero(
        icon: LucideIcons.palette,
        color: customizeColor,
        title: appLocalizations.featureCustomizeTitle,
        subtitle: appLocalizations.featureCustomizeDescription,
      ),
      content: Column(
        children: [
          buildSectionLabel(
            LucideIcons.droplet,
            appLocalizations.featureThemeColors,
            customizeColor,
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
          buildChip(
            label: appLocalizations.featureCustomThemeEditor,
            color: customizeColor,
            icon: LucideIcons.pencilLine,
          ),
          const SizedBox(height: 14),
          buildSectionLabel(
            LucideIcons.layoutGrid,
            appLocalizations.featureLayoutStyles,
            customizeColor,
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
              buildChip(
                  label: appLocalizations.featureGlassEffect,
                  color: customizeColor,
                  icon: LucideIcons.sparkles),
              buildChip(
                  label: appLocalizations.featureCustomFont,
                  color: customizeColor,
                  icon: LucideIcons.type),
              buildChip(
                  label: appLocalizations.featureMultiLang,
                  color: customizeColor,
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
        color: customizeColor.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: customizeColor.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: customizeColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: ChewieTheme.labelSmall.copyWith(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: customizeColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
