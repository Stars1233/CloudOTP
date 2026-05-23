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

import 'dart:ui' as ui;

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:cloudotp/Database/database_manager.dart';
import 'package:cloudotp/Utils/hive_util.dart';
import 'package:flutter/material.dart';

import '../../Screens/home_screen.dart';
import '../../l10n/l10n.dart';

class CoachMarkManager {
  final BuildContext context;
  final GlobalKey appBarTitleKey;
  final GlobalKey? firstTokenKey;
  final GlobalKey? categoryTabKey;
  final GlobalKey moreButtonKey;
  final GlobalKey? sortButtonKey;
  final GlobalKey? layoutButtonKey;
  final GlobalKey? fabKey;
  final GlobalKey? cloudBackupKey;
  final GlobalKey? backupLogKey;
  final LayoutType layoutType;
  final int tokenCount;
  final int categoryCount;
  final VoidCallback? onDeleteSampleData;

  CoachMarkManager({
    required this.context,
    required this.appBarTitleKey,
    this.firstTokenKey,
    this.categoryTabKey,
    required this.moreButtonKey,
    this.sortButtonKey,
    this.layoutButtonKey,
    this.fabKey,
    this.cloudBackupKey,
    this.backupLogKey,
    required this.layoutType,
    required this.tokenCount,
    required this.categoryCount,
    this.onDeleteSampleData,
  });

  Future<void> show({bool force = false}) async {
    if (!ResponsiveUtil.isMobile() || ResponsiveUtil.isLandscapeTablet()) return;
    if (!force &&
        ChewieHiveUtil.getBool(CloudOTPHiveUtil.haveShownCoachMarkKey,
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
    ChewieHiveUtil.put(CloudOTPHiveUtil.haveShownCoachMarkKey, true);
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

  List<_CoachStep> _buildSteps() {
    List<_CoachStep> steps = [];

    steps.add(_CoachStep(
      key: appBarTitleKey,
      title: appLocalizations.coachMarkSearchTitle,
      description: appLocalizations.coachMarkSearchDescription,
    ));

    if (cloudBackupKey != null) {
      steps.add(_CoachStep(
        key: cloudBackupKey!,
        title: appLocalizations.coachMarkCloudBackupTitle,
        description: appLocalizations.coachMarkCloudBackupDescription,
      ));
    }

    if (backupLogKey != null) {
      steps.add(_CoachStep(
        key: backupLogKey!,
        title: appLocalizations.coachMarkBackupLogTitle,
        description: appLocalizations.coachMarkBackupLogDescription,
      ));
    }

    if (layoutButtonKey != null) {
      steps.add(_CoachStep(
        key: layoutButtonKey!,
        title: appLocalizations.coachMarkLayoutTitle,
        description: appLocalizations.coachMarkLayoutDescription,
      ));
    }

    if (sortButtonKey != null) {
      steps.add(_CoachStep(
        key: sortButtonKey!,
        title: appLocalizations.coachMarkSortTitle,
        description: appLocalizations.coachMarkSortDescription,
      ));
    }

    if (tokenCount > 1) {
      steps.add(_CoachStep(
        key: moreButtonKey,
        title: appLocalizations.coachMarkMultiSelectTitle,
        description: appLocalizations.coachMarkMultiSelectDescription,
      ));
    }

    bool swipeApplicable = tokenCount >= 1 &&
        firstTokenKey != null &&
        (layoutType == LayoutType.List || layoutType == LayoutType.Spotlight);
    if (swipeApplicable) {
      steps.add(_CoachStep(
        key: firstTokenKey!,
        title: appLocalizations.coachMarkSwipeTitle,
        description: appLocalizations.coachMarkSwipeDescription,
        radius: 12,
      ));
    }

    if (categoryCount >= 1 && categoryTabKey != null) {
      steps.add(_CoachStep(
        key: categoryTabKey!,
        title: appLocalizations.coachMarkCategoryTitle,
        description: appLocalizations.coachMarkCategoryDescription,
      ));
    }

    if (fabKey != null) {
      steps.add(_CoachStep(
        key: fabKey!,
        title: appLocalizations.coachMarkScanTitle,
        description: appLocalizations.coachMarkScanDescription,
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
    _pulseController.stop();
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

    double? top, bottom, left, right;

    switch (contentAlign) {
      case _ContentAlign.bottom:
        top = targetRect.bottom + 12;
        left = 0;
        right = 0;
        break;
      case _ContentAlign.top:
        bottom = screenSize.height - targetRect.top + 12;
        left = 0;
        right = 0;
        break;
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: FadeTransition(
        opacity: _contentController,
        child: _buildContent(step: step),
      ),
    );
  }

  _ContentAlign _computeContentAlign(Rect targetRect, Size screenSize) {
    const contentHeight = 200.0;

    final targetBottom = targetRect.bottom;
    if (targetBottom + contentHeight > screenSize.height - 40) {
      return _ContentAlign.top;
    }
    if (targetRect.top - contentHeight < 40) {
      return _ContentAlign.bottom;
    }
    return targetRect.top < screenSize.height / 2
        ? _ContentAlign.bottom
        : _ContentAlign.top;
  }

  Widget _buildContent({required _CoachStep step}) {
    final totalSteps = widget.steps.length;
    final isLast = _currentIndex == totalSteps - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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

enum _ContentAlign { top, bottom }

class _CoachStep {
  final GlobalKey key;
  final String title;
  final String description;
  final double radius;

  _CoachStep({
    required this.key,
    required this.title,
    required this.description,
    this.radius = 8,
  });
}
