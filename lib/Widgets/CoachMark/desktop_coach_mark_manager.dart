import 'dart:io';
import 'dart:ui' as ui;

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:cloudotp/Database/database_manager.dart';
import 'package:cloudotp/Utils/hive_util.dart';
import 'package:cloudotp/Utils/shortcuts_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class DesktopCoachMarkManager {
  final BuildContext context;
  final GlobalKey searchBarKey;
  final GlobalKey addTokenKey;
  final GlobalKey categoryKey;
  final GlobalKey? qrScanKey;
  final GlobalKey importExportKey;
  final GlobalKey importThirdPartyKey;
  final GlobalKey? cloudBackupKey;
  final GlobalKey? backupLogKey;
  final GlobalKey? sortButtonKey;
  final GlobalKey? layoutButtonKey;
  final GlobalKey featureShowcaseKey;
  final GlobalKey settingKey;
  final GlobalKey logoKey;
  final GlobalKey? firstTokenKey;
  final VoidCallback? onDeleteSampleData;

  DesktopCoachMarkManager({
    required this.context,
    required this.searchBarKey,
    required this.addTokenKey,
    required this.categoryKey,
    this.qrScanKey,
    required this.importExportKey,
    required this.importThirdPartyKey,
    this.cloudBackupKey,
    this.backupLogKey,
    this.sortButtonKey,
    this.layoutButtonKey,
    required this.featureShowcaseKey,
    required this.settingKey,
    required this.logoKey,
    this.firstTokenKey,
    this.onDeleteSampleData,
  });

  Future<void> show({bool force = false}) async {
    if (!ResponsiveUtil.isDesktop() && !ResponsiveUtil.isLandscapeTablet()) {
      return;
    }
    if (!force &&
        ChewieHiveUtil.getBool(CloudOTPHiveUtil.haveShownDesktopCoachMarkKey,
            defaultValue: false)) {
      return;
    }

    List<_CoachStep> steps = _buildSteps();
    if (steps.isEmpty) return;

    if (!context.mounted) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CoachMarkOverlay(
        steps: steps,
        onFinish: () {
          entry.remove();
          _markShown();
        },
      ),
    );
    overlay.insert(entry);
  }

  void _markShown() {
    ChewieHiveUtil.put(CloudOTPHiveUtil.haveShownDesktopCoachMarkKey, true);
    _promptDeleteSampleData();
  }

  Future<void> _promptDeleteSampleData() async {
    if (!context.mounted) return;
    final hasSample = await DatabaseManager.hasSampleData();
    if (!hasSample || !context.mounted) return;
    DialogBuilder.showConfirmDialog(
      context,
      title: appLocalizations.coachMarkDeleteSampleTitle,
      message: appLocalizations.coachMarkDeleteSampleMessage,
      onTapConfirm: () async {
        await DatabaseManager.deleteSampleData();
        onDeleteSampleData?.call();
      },
      onTapCancel: () {
        DatabaseManager.clearSampleDataFlag();
      },
    );
  }

  CloudOTPShortcut? _findShortcut<T extends Intent>() {
    if (ResponsiveUtil.isLandscapeTablet()) return null;
    try {
      return ShortcutsUtil.shortcuts.firstWhere((s) => s.intent is T);
    } catch (_) {
      return null;
    }
  }

  List<_CoachStep> _buildSteps() {
    List<_CoachStep> steps = [];

    steps.add(_CoachStep(
      key: searchBarKey,
      title: appLocalizations.desktopCoachSearchTitle,
      description: appLocalizations.desktopCoachSearchDescription,
      shortcut: _findShortcut<SearchIntent>(),
    ));

    steps.add(_CoachStep(
      key: logoKey,
      title: appLocalizations.desktopCoachLogoShortcutTitle,
      description: appLocalizations.desktopCoachLogoShortcutDescription,
      shortcut: _findShortcut<KeyboardShortcutHelpIntent>(),
    ));

    steps.add(_CoachStep(
      key: addTokenKey,
      title: appLocalizations.desktopCoachAddTokenTitle,
      description: appLocalizations.desktopCoachAddTokenDescription,
      shortcut: _findShortcut<AddTokenIntent>(),
    ));

    steps.add(_CoachStep(
      key: categoryKey,
      title: appLocalizations.desktopCoachCategoryTitle,
      description: appLocalizations.desktopCoachCategoryDescription,
      shortcut: _findShortcut<CategoryIntent>(),
    ));

    if (qrScanKey != null) {
      steps.add(_CoachStep(
        key: qrScanKey!,
        title: appLocalizations.desktopCoachQrScanTitle,
        description: appLocalizations.desktopCoachQrScanDescription,
      ));
    }

    steps.add(_CoachStep(
      key: importExportKey,
      title: appLocalizations.desktopCoachImportTitle,
      description: appLocalizations.desktopCoachImportDescription,
      shortcut: _findShortcut<ImportExportIntent>(),
    ));

    steps.add(_CoachStep(
      key: importThirdPartyKey,
      title: appLocalizations.desktopCoachImportThirdTitle,
      description: appLocalizations.desktopCoachImportThirdDescription,
    ));

    if (cloudBackupKey != null) {
      steps.add(_CoachStep(
        key: cloudBackupKey!,
        title: appLocalizations.desktopCoachCloudBackupTitle,
        description: appLocalizations.desktopCoachCloudBackupDescription,
      ));
    }

    if (backupLogKey != null) {
      steps.add(_CoachStep(
        key: backupLogKey!,
        title: appLocalizations.desktopCoachBackupLogTitle,
        description: appLocalizations.desktopCoachBackupLogDescription,
      ));
    }

    if (sortButtonKey != null) {
      steps.add(_CoachStep(
        key: sortButtonKey!,
        title: appLocalizations.desktopCoachSortTitle,
        description: appLocalizations.desktopCoachSortDescription,
      ));
    }

    if (layoutButtonKey != null) {
      steps.add(_CoachStep(
        key: layoutButtonKey!,
        title: appLocalizations.desktopCoachLayoutTitle,
        description: appLocalizations.desktopCoachLayoutDescription,
        shortcut: _findShortcut<ChangeLayoutTypeIntent>(),
      ));
    }

    steps.add(_CoachStep(
      key: featureShowcaseKey,
      title: appLocalizations.desktopCoachFeatureShowcaseTitle,
      description: appLocalizations.desktopCoachFeatureShowcaseDescription,
    ));

    steps.add(_CoachStep(
      key: settingKey,
      title: appLocalizations.desktopCoachSettingTitle,
      description: appLocalizations.desktopCoachSettingDescription,
      shortcut: _findShortcut<SettingIntent>(),
    ));

    if (firstTokenKey != null) {
      steps.add(_CoachStep(
        key: firstTokenKey!,
        title: appLocalizations.desktopCoachRightClickTitle,
        description: appLocalizations.desktopCoachRightClickDescription,
        radius: 12,
      ));
    }

    return steps;
  }
}

class _CoachMarkOverlay extends StatefulWidget {
  final List<_CoachStep> steps;
  final VoidCallback onFinish;

  const _CoachMarkOverlay({
    required this.steps,
    required this.onFinish,
  });

  @override
  State<_CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<_CoachMarkOverlay>
    with TickerProviderStateMixin {
  static const _shadowOpacity = 0.75;
  static const _padding = 4.0;
  static const _animDuration = Duration(milliseconds: 350);

  int _currentIndex = 0;
  late AnimationController _holeController;
  Animation<Rect?>? _holeAnimation;
  late AnimationController _contentController;
  late AnimationController _pulseController;
  bool _isTransitioning = false;

  Rect _currentTargetRect = Rect.zero;

  @override
  void initState() {
    super.initState();
    _holeController = AnimationController(vsync: this, duration: _animDuration);
    _contentController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _holeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentTargetRect = _holeAnimation?.value ?? _currentTargetRect;
        _isTransitioning = false;
        _contentController.forward();
        _pulseController.repeat(reverse: true);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFirstTarget();
    });
  }

  Rect _expandedRect(Rect target, Size screenSize) {
    final expandFactor = screenSize.longestSide;
    return Rect.fromCenter(
      center: target.center,
      width: target.width + expandFactor,
      height: target.height + expandFactor,
    );
  }

  void _initFirstTarget() {
    final rect = _getTargetRect(widget.steps[0]);
    if (rect == null) {
      widget.onFinish();
      return;
    }
    final screenSize = MediaQuery.of(context).size;
    final startRect = _expandedRect(rect, screenSize);
    _currentTargetRect = rect;
    _holeAnimation = RectTween(begin: startRect, end: rect)
        .animate(CurvedAnimation(parent: _holeController, curve: Curves.easeOutCubic));
    _holeController.forward(from: 0).then((_) {
      _contentController.forward();
    });
    setState(() {});
  }

  Rect? _getTargetRect(_CoachStep step) {
    final renderBox =
        step.key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;
    final pos = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    return Rect.fromLTWH(
      pos.dx - _padding,
      pos.dy - _padding,
      size.width + _padding * 2,
      size.height + _padding * 2,
    );
  }

  void _goToNext() {
    if (_isTransitioning) return;
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= widget.steps.length) {
      _dismiss();
      return;
    }
    _transitionTo(nextIndex);
  }

  void _dismiss() {
    _contentController.reverse().then((_) {
      widget.onFinish();
    });
  }

  void _transitionTo(int index) {
    final nextRect = _getTargetRect(widget.steps[index]);
    if (nextRect == null) {
      if (index + 1 < widget.steps.length) {
        _transitionTo(index + 1);
      } else {
        _dismiss();
      }
      return;
    }

    _isTransitioning = true;
    _pulseController.stop();
    _contentController.reverse().then((_) {
      setState(() {
        _currentIndex = index;
      });
      _holeAnimation = RectTween(begin: _currentTargetRect, end: nextRect)
          .animate(CurvedAnimation(parent: _holeController, curve: Curves.easeInOut));
      _holeController.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _holeController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_holeAnimation == null) return const SizedBox.shrink();
    final step = widget.steps[_currentIndex];
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_holeController, _pulseController]),
              builder: (context, _) {
                Rect rect = _holeAnimation?.value ?? _currentTargetRect;
                if (!_isTransitioning && _pulseController.isAnimating) {
                  final pulseAmount = 3.0 * _pulseController.value;
                  rect = rect.inflate(pulseAmount);
                }
                return CustomPaint(
                  painter: _HolePainter(
                    holeRect: rect,
                    radius: step.radius,
                    shadowColor: Colors.black,
                    shadowOpacity: _shadowOpacity,
                  ),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _goToNext,
              child: const SizedBox.expand(),
            ),
          ),
          _buildContentPositioned(step),
        ],
      ),
    );
  }

  Widget _buildContentPositioned(_CoachStep step) {
    final screenSize = MediaQuery.of(context).size;
    final targetRect = _getTargetRect(step) ?? _currentTargetRect;
    final contentAlign = _computeContentAlign(targetRect, screenSize);
    const maxWidth = 360.0;
    const gap = 10.0;

    double? top, bottom, left, right;

    switch (contentAlign) {
      case _ContentAlign.bottom:
        top = targetRect.bottom + gap;
        left = (targetRect.left).clamp(12.0, screenSize.width - maxWidth - 12);
        break;
      case _ContentAlign.top:
        bottom = screenSize.height - targetRect.top + gap;
        left = (targetRect.left).clamp(12.0, screenSize.width - maxWidth - 12);
        break;
      case _ContentAlign.right:
        left = targetRect.right + gap;
        top = (targetRect.top).clamp(12.0, screenSize.height - 240);
        break;
      case _ContentAlign.left:
        right = screenSize.width - targetRect.left + gap;
        top = (targetRect.top).clamp(12.0, screenSize.height - 240);
        break;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: FadeTransition(
        opacity: _contentController,
        child: _buildContent(
          step: step,
          maxWidth: maxWidth,
        ),
      ),
    );
  }

  _ContentAlign _computeContentAlign(Rect targetRect, Size screenSize) {
    const contentHeight = 220.0;
    const contentWidth = 360.0;
    const gap = 10.0;

    final spaceRight = screenSize.width - targetRect.right - gap;
    final spaceLeft = targetRect.left - gap;
    final spaceBottom = screenSize.height - targetRect.bottom - gap;
    final spaceTop = targetRect.top - gap;

    if (targetRect.left < screenSize.width * 0.25) {
      if (spaceRight >= contentWidth) return _ContentAlign.right;
      if (spaceBottom >= contentHeight) return _ContentAlign.bottom;
      if (spaceTop >= contentHeight) return _ContentAlign.top;
      return _ContentAlign.right;
    }

    if (targetRect.right > screenSize.width * 0.75) {
      if (spaceLeft >= contentWidth) return _ContentAlign.left;
      if (spaceBottom >= contentHeight) return _ContentAlign.bottom;
      if (spaceTop >= contentHeight) return _ContentAlign.top;
      return _ContentAlign.left;
    }

    if (spaceBottom >= contentHeight) return _ContentAlign.bottom;
    if (spaceTop >= contentHeight) return _ContentAlign.top;
    if (spaceRight >= contentWidth) return _ContentAlign.right;
    return _ContentAlign.bottom;
  }

  Widget _buildContent({
    required _CoachStep step,
    required double maxWidth,
  }) {
    final totalSteps = widget.steps.length;
    final isLast = _currentIndex == totalSteps - 1;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(25)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressDots(_currentIndex, totalSteps),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (step.shortcut != null) ...[
                          const SizedBox(width: 10),
                          _buildShortcutBadge(step.shortcut!),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _dismiss,
                          style: TextButton.styleFrom(
                            overlayColor: Colors.white.withAlpha(40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            appLocalizations.coachMarkSkip,
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _goToNext,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            overlayColor:
                                ChewieTheme.primaryColor.withAlpha(40),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            isLast
                                ? appLocalizations.coachMarkGotIt
                                : appLocalizations.coachMarkNext,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildProgressDots(int current, int total) {
    return Row(
      children: List.generate(
        total,
        (i) => Container(
          width: i == current ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: i == current ? Colors.white : Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutBadge(CloudOTPShortcut shortcut) {
    final modifiers = _getModifierKeys(shortcut);
    final triggerLabel = shortcut.triggerLabel;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...modifiers.map((m) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _buildKeyCap(m),
            )),
        _buildKeyCap(triggerLabel),
      ],
    );
  }

  Widget _buildKeyCap(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withAlpha(80)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<String> _getModifierKeys(CloudOTPShortcut shortcut) {
    List<String> keys = [];
    final isMac = !kIsWeb && Platform.isMacOS;
    if (shortcut.isMetaPressed) {
      keys.add(isMac ? '⌘' : 'Meta');
    }
    if (shortcut.isControlPressed) {
      keys.add(isMac ? '⌃' : 'Ctrl');
    }
    if (shortcut.isShiftPressed) {
      keys.add(isMac ? '⇧' : 'Shift');
    }
    if (shortcut.isAltPressed) {
      keys.add(isMac ? '⌥' : 'Alt');
    }
    return keys;
  }
}

class _HolePainter extends CustomPainter {
  final Rect holeRect;
  final double radius;
  final Color shadowColor;
  final double shadowOpacity;

  _HolePainter({
    required this.holeRect,
    required this.radius,
    required this.shadowColor,
    required this.shadowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = shadowColor.withAlpha((shadowOpacity * 255).round())
      ..style = PaintingStyle.fill;

    final fullPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(radius)));

    final combined = Path.combine(PathOperation.difference, fullPath, holePath);
    canvas.drawPath(combined, paint);
  }

  @override
  bool shouldRepaint(_HolePainter oldDelegate) {
    return oldDelegate.holeRect != holeRect ||
        oldDelegate.radius != radius ||
        oldDelegate.shadowOpacity != shadowOpacity;
  }
}

enum _ContentAlign { top, bottom, right, left }

class _CoachStep {
  final GlobalKey key;
  final String title;
  final String description;
  final CloudOTPShortcut? shortcut;
  final double radius;

  _CoachStep({
    required this.key,
    required this.title,
    required this.description,
    this.shortcut,
    this.radius = 8,
  });
}
