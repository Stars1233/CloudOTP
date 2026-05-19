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

import 'dart:async';
import 'dart:ui' as ui;

import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:cloudotp/Utils/hive_util.dart';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../Screens/home_screen.dart';
import '../../l10n/l10n.dart';

class CoachMarkManager {
  final BuildContext context;
  final GlobalKey appBarTitleKey;
  final GlobalKey? firstTokenKey;
  final GlobalKey? categoryTabKey;
  final GlobalKey moreButtonKey;
  final LayoutType layoutType;
  final int tokenCount;
  final int categoryCount;
  final Future<void> Function(String identify)? onDemoAction;
  final Future<void> Function(String identify)? onUndoDemoAction;

  CoachMarkManager({
    required this.context,
    required this.appBarTitleKey,
    this.firstTokenKey,
    this.categoryTabKey,
    required this.moreButtonKey,
    required this.layoutType,
    required this.tokenCount,
    required this.categoryCount,
    this.onDemoAction,
    this.onUndoDemoAction,
  });

  Future<void> show({bool force = false}) async {
    if (!ResponsiveUtil.isMobile()) return;
    if (!force &&
        ChewieHiveUtil.getBool(CloudOTPHiveUtil.haveShownCoachMarkKey,
            defaultValue: false)) {
      return;
    }

    List<_CoachStep> steps = _buildSteps();
    if (steps.isEmpty) return;

    bool skipped = false;

    for (int i = 0; i < steps.length; i++) {
      if (skipped || !context.mounted) break;
      final step = steps[i];
      final completer = Completer<bool>();

      final tcm = TutorialCoachMark(
        targets: [_buildTarget(step, i, steps.length, completer)],
        colorShadow: Colors.black,
        opacityShadow: 0.75,
        paddingFocus: 8,
        pulseEnable: true,
        focusAnimationDuration: const Duration(milliseconds: 300),
        unFocusAnimationDuration: const Duration(milliseconds: 300),
        showSkipInLastTarget: true,
        hideSkip: true,
        onFinish: () {
          if (!completer.isCompleted) completer.complete(true);
        },
        onSkip: () {
          if (!completer.isCompleted) completer.complete(false);
          return true;
        },
      );

      tcm.show(context: context);
      final proceed = await completer.future;

      if (!proceed) {
        skipped = true;
        break;
      }

      if (onDemoAction != null && context.mounted) {
        await Future.delayed(const Duration(milliseconds: 200));
        await onDemoAction!(step.identify);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (context.mounted) {
          await onUndoDemoAction?.call(step.identify);
        }
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }
    _markShown();
  }

  void _markShown() {
    ChewieHiveUtil.put(CloudOTPHiveUtil.haveShownCoachMarkKey, true);
  }

  List<_CoachStep> _buildSteps() {
    List<_CoachStep> steps = [];

    steps.add(_CoachStep(
      key: appBarTitleKey,
      identify: "search_title",
      shape: ShapeLightFocus.RRect,
      radius: 8,
      title: appLocalizations.coachMarkSearchTitle,
      description: appLocalizations.coachMarkSearchDescription,
    ));

    bool swipeApplicable = tokenCount >= 1 &&
        firstTokenKey != null &&
        (layoutType == LayoutType.List || layoutType == LayoutType.Spotlight);
    if (swipeApplicable) {
      steps.add(_CoachStep(
        key: firstTokenKey!,
        identify: "swipe_token",
        shape: ShapeLightFocus.RRect,
        radius: 12,
        title: appLocalizations.coachMarkSwipeTitle,
        description: appLocalizations.coachMarkSwipeDescription,
      ));
    }

    if (categoryCount >= 1 && categoryTabKey != null) {
      steps.add(_CoachStep(
        key: categoryTabKey!,
        identify: "category_tab",
        shape: ShapeLightFocus.RRect,
        radius: 8,
        title: appLocalizations.coachMarkCategoryTitle,
        description: appLocalizations.coachMarkCategoryDescription,
      ));
    }

    if (tokenCount > 1) {
      steps.add(_CoachStep(
        key: moreButtonKey,
        identify: "more_menu",
        shape: ShapeLightFocus.Circle,
        radius: 0,
        title: appLocalizations.coachMarkMultiSelectTitle,
        description: appLocalizations.coachMarkMultiSelectDescription,
      ));
    }

    return steps;
  }

  TargetFocus _buildTarget(
      _CoachStep step, int index, int total, Completer<bool> completer) {
    return TargetFocus(
      identify: step.identify,
      keyTarget: step.key,
      alignSkip: Alignment.topRight,
      shape: step.shape,
      radius: step.radius,
      enableOverlayTab: false,
      enableTargetTab: false,
      contents: [
        TargetContent(
          align: _contentAlign(step.key),
          builder: (context, controller) {
            return _buildContent(
              title: step.title,
              description: step.description,
              stepIndex: index,
              totalSteps: total,
              isLast: index == total - 1,
              onNext: () {
                if (!completer.isCompleted) {
                  controller.next();
                }
              },
              onSkip: () {
                if (!completer.isCompleted) {
                  completer.complete(false);
                  controller.skip();
                }
              },
            );
          },
        ),
      ],
    );
  }

  ContentAlign _contentAlign(GlobalKey key) {
    try {
      final renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return ContentAlign.bottom;
      final pos = renderBox.localToGlobal(Offset.zero);
      final screenHeight = MediaQuery.of(context).size.height;
      return pos.dy < screenHeight / 2
          ? ContentAlign.bottom
          : ContentAlign.top;
    } catch (_) {
      return ContentAlign.bottom;
    }
  }

  Widget _buildContent({
    required String title,
    required String description,
    required int stepIndex,
    required int totalSteps,
    required bool isLast,
    required VoidCallback onNext,
    required VoidCallback onSkip,
  }) {
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
                _buildProgressDots(stepIndex, totalSteps),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
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
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
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
                      onPressed: onNext,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
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

class _CoachStep {
  final GlobalKey key;
  final String identify;
  final ShapeLightFocus shape;
  final double radius;
  final String title;
  final String description;

  _CoachStep({
    required this.key,
    required this.identify,
    required this.shape,
    required this.radius,
    required this.title,
    required this.description,
  });
}
