part of 'slidable.dart';

const _defaultExtentRatio = 0.5;

/// Data of the ambient [ActionPane] accessible from its children.
@immutable
class ActionPaneData {
  /// Creates an [ActionPaneData].
  const ActionPaneData({
    required this.extentRatio,
    required this.alignment,
    required this.direction,
    required this.fromStart,
    required this.children,
    this.autoTriggerProgress = 0.0,
  });

  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  final double extentRatio;

  /// The alignment used by the current action pane to position itself.
  final Alignment alignment;

  /// The axis in which the slidable can slide.
  final Axis direction;

  /// Whether the current action pane is the start one.
  final bool fromStart;

  /// The actions for this pane.
  final List<Widget> children;

  /// Progress toward auto-trigger threshold (0.0 = at extentRatio, 1.0 = at threshold).
  final double autoTriggerProgress;
}

/// An action pane.
class ActionPane extends StatefulWidget {
  /// Creates an [ActionPane].
  ///
  /// The [extentRatio] argument must not be null and must be between 0
  /// (exclusive) and 1 (inclusive).
  /// The [openThreshold] argument must be null or between 0 and 1
  /// (both exclusives).
  /// The [closeThreshold] argument must be null or between 0 and 1
  /// (both exclusives).
  /// The [children] argument must not be null.
  const ActionPane({
    super.key,
    this.extentRatio = _defaultExtentRatio,
    required this.motion,
    this.dismissible,
    this.dragDismissible = true,
    this.openThreshold,
    this.closeThreshold,
    this.onAutoTrigger,
    this.autoTriggerThreshold,
    required this.children,
  })  : assert(extentRatio > 0 && extentRatio <= 1),
        assert(
            openThreshold == null || (openThreshold > 0 && openThreshold < 1)),
        assert(closeThreshold == null ||
            (closeThreshold > 0 && closeThreshold < 1));

  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  final double extentRatio;

  /// A widget which animates when the [Slidable] moves.
  final Widget motion;

  /// A widget which controls how the [Slidable] dismisses.
  final Widget? dismissible;

  /// Indicates whether the [Slidable] can be dismissed by dragging.
  ///
  /// Defaults to true.
  final bool dragDismissible;

  /// The fraction of the total extent from where the [Slidable] will
  /// automatically open when the drag end.
  ///
  /// Must be between 0 (excluded) and 1 (excluded).
  ///
  /// By default this value is half the [extentRatio].
  final double? openThreshold;

  /// The fraction of the total extent from where the [Slidable] will
  /// automatically close when the drag end.
  ///
  /// Must be between 0 (excluded) and 1 (excluded).
  ///
  /// By default this value is half the [extentRatio].
  final double? closeThreshold;

  /// Callback invoked when the user drags past the [autoTriggerThreshold]
  /// and releases.
  final VoidCallback? onAutoTrigger;

  /// The ratio threshold beyond which [onAutoTrigger] is called.
  /// Defaults to `extentRatio * 2.0` if [onAutoTrigger] is set.
  final double? autoTriggerThreshold;

  /// The actions for this pane.
  final List<Widget> children;

  @override
  _ActionPaneState createState() => _ActionPaneState();

  /// The action pane's data from the closest instance of this class that
  /// encloses the given context.
  static ActionPaneData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ActionPaneScope>()
        ?.actionPaneData;
  }
}

class _ActionPaneState extends State<ActionPane> implements RatioConfigurator {
  SlidableController? controller;
  late double openThreshold;
  late double closeThreshold;
  bool showMotion = true;
  bool _hasTriggeredAutoTriggerHaptic = false;

  @override
  double get extentRatio => widget.extentRatio;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    controller!.endGesture.addListener(handleEndGestureChanged);

    if (widget.dismissible != null) {
      controller!.animation.addListener(handleRatioChanged);
    }
    updateThresholds();
    controller!.actionPaneConfigurator = this;
  }

  void updateThresholds() {
    openThreshold = widget.openThreshold ?? widget.extentRatio / 2;
    closeThreshold = widget.closeThreshold ?? widget.extentRatio / 2;
  }

  @override
  void didUpdateWidget(covariant ActionPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissible != null) {
      controller!.animation.removeListener(handleRatioChanged);
    }
    if (widget.dismissible == null) {
      // In the case where the child was different than the motion, we get
      // it back.
      showMotion = true;
    } else {
      controller!.animation.addListener(handleRatioChanged);
    }
    updateThresholds();
  }

  @override
  void dispose() {
    controller!.endGesture.removeListener(handleEndGestureChanged);
    controller!.animation.removeListener(handleRatioChanged);
    controller!.actionPaneConfigurator = null;
    super.dispose();
  }

  @override
  double normalizeRatio(double ratio) {
    if (widget.dismissible != null && widget.dragDismissible) {
      return ratio;
    }

    if (widget.onAutoTrigger != null) {
      final effectiveThreshold =
          widget.autoTriggerThreshold ?? widget.extentRatio * 2.0;
      final absoluteRatio = ratio.abs();

      if (absoluteRatio <= widget.extentRatio) {
        _checkAutoTriggerThreshold(absoluteRatio, effectiveThreshold);
        return ratio < 0 ? -absoluteRatio : absoluteRatio;
      } else {
        final overExtent = absoluteRatio - widget.extentRatio;
        final maxOverExtent = effectiveThreshold - widget.extentRatio;
        final dampedOverExtent = maxOverExtent *
            (1 -
                math.pow(math.e, -overExtent / maxOverExtent * 2).toDouble());
        final clampedResult =
            (widget.extentRatio + dampedOverExtent).clamp(0.0, effectiveThreshold);
        _checkAutoTriggerThreshold(clampedResult, effectiveThreshold);
        return ratio < 0 ? -clampedResult : clampedResult;
      }
    }

    final absoluteRatio = ratio.abs();
    if (absoluteRatio <= widget.extentRatio) {
      return ratio < 0 ? -absoluteRatio : absoluteRatio;
    }
    final overExtent = absoluteRatio - widget.extentRatio;
    final maxOverExtent = widget.extentRatio * 0.2;
    final dampedOverExtent = maxOverExtent *
        (1 - math.pow(math.e, -overExtent / maxOverExtent * 2).toDouble());
    final result = widget.extentRatio + dampedOverExtent;
    return ratio < 0 ? -result : result;
  }

  void _checkAutoTriggerThreshold(double currentRatio, double threshold) {
    final hapticThreshold =
        widget.extentRatio + (threshold - widget.extentRatio) * 0.7;

    if (currentRatio >= hapticThreshold && !_hasTriggeredAutoTriggerHaptic) {
      _hasTriggeredAutoTriggerHaptic = true;
      HapticFeedback.mediumImpact();
    } else if (currentRatio < hapticThreshold &&
        _hasTriggeredAutoTriggerHaptic) {
      _hasTriggeredAutoTriggerHaptic = false;
      HapticFeedback.lightImpact();
    }
  }

  @override
  void handleEndGestureChanged() {
    final gesture = controller!.endGesture.value;
    final position = controller!.animation.value;

    if (widget.dismissible != null &&
        widget.dragDismissible &&
        position > widget.extentRatio) {
      if (controller!.isDismissibleReady) {
        controller!.dismissGesture.value = DismissGesture(gesture);
      } else {
        controller!.openCurrentActionPane();
      }
      _hasTriggeredAutoTriggerHaptic = false;
      return;
    }

    if (widget.onAutoTrigger != null && _hasTriggeredAutoTriggerHaptic) {
      HapticFeedback.heavyImpact();
      widget.onAutoTrigger!();
      controller!.close();
      _hasTriggeredAutoTriggerHaptic = false;
      return;
    }
    _hasTriggeredAutoTriggerHaptic = false;

    if ((gesture is OpeningGesture && openThreshold <= extentRatio) ||
        gesture is StillGesture &&
            ((gesture.opening && position >= openThreshold) ||
                gesture.closing && position > closeThreshold)) {
      controller!.openCurrentActionPane();
      return;
    }

    // Otherwise we close the the Slidable.
    controller!.close();
  }

  void handleRatioChanged() {
    final show = controller!.ratio.abs() <= widget.extentRatio &&
        !controller!.isDismissibleReady;
    if (show != showMotion) {
      setState(() {
        showMotion = show;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ActionPaneConfiguration.of(context)!;

    Widget? child;

    if (showMotion) {
      if (widget.onAutoTrigger != null) {
        child = AnimatedBuilder(
          animation: controller!.animation,
          builder: (context, _) {
            final currentRatio = controller!.animation.value;
            final factor = currentRatio > widget.extentRatio
                ? currentRatio
                : widget.extentRatio;
            final effectiveThreshold =
                widget.autoTriggerThreshold ?? widget.extentRatio * 2.0;
            final overRange = effectiveThreshold - widget.extentRatio;
            final progress = overRange > 0
                ? ((currentRatio - widget.extentRatio) / overRange)
                    .clamp(0.0, 1.0)
                : 0.0;

            return _ActionPaneScope(
              actionPaneData: ActionPaneData(
                alignment: config.alignment,
                direction: config.direction,
                fromStart: config.isStartActionPane,
                extentRatio: widget.extentRatio,
                children: widget.children,
                autoTriggerProgress: progress,
              ),
              child: FractionallySizedBox(
                alignment: config.alignment,
                widthFactor:
                    config.direction == Axis.horizontal ? factor : null,
                heightFactor:
                    config.direction == Axis.horizontal ? null : factor,
                child: widget.motion,
              ),
            );
          },
        );
      } else {
        child = AnimatedBuilder(
          animation: controller!.animation,
          builder: (context, _) {
            final currentRatio = controller!.animation.value;
            final factor = widget.extentRatio;
            Alignment alignment = config.alignment;
            if (currentRatio > widget.extentRatio && widget.extentRatio < 1.0) {
              final overRatio = (currentRatio - widget.extentRatio) /
                  (1 - widget.extentRatio);
              if (config.direction == Axis.horizontal) {
                alignment = Alignment(
                  config.alignment.x * (1 - 2 * overRatio),
                  config.alignment.y,
                );
              } else {
                alignment = Alignment(
                  config.alignment.x,
                  config.alignment.y * (1 - 2 * overRatio),
                );
              }
            }
            return FractionallySizedBox(
              alignment: alignment,
              widthFactor:
                  config.direction == Axis.horizontal ? factor : null,
              heightFactor:
                  config.direction == Axis.horizontal ? null : factor,
              child: widget.motion,
            );
          },
        );
      }
    } else {
      child = widget.dismissible;
    }

    if (widget.onAutoTrigger != null && showMotion) {
      return child!;
    }

    return _ActionPaneScope(
      actionPaneData: ActionPaneData(
        alignment: config.alignment,
        direction: config.direction,
        fromStart: config.isStartActionPane,
        extentRatio: widget.extentRatio,
        children: widget.children,
      ),
      child: child!,
    );
  }
}

class _ActionPaneScope extends InheritedWidget {
  const _ActionPaneScope({
    this.actionPaneData,
    required super.child,
  });

  final ActionPaneData? actionPaneData;

  @override
  bool updateShouldNotify(covariant _ActionPaneScope oldWidget) {
    return oldWidget.actionPaneData != actionPaneData;
  }
}
