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
import 'package:cloudotp/Utils/hive_util.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../Utils/constant.dart';
import '../Utils/shortcuts_util.dart';
import '../l10n/l10n.dart';
import 'feature_showcase_pages.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin, FeatureShowcasePages {
  late final AnimationController _splashController;
  late final AnimationController _transitionController;

  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _buttonFade;

  late final Animation<double> _heroProgress;
  late final Animation<double> _contentFade;

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _splashReady = false;
  bool _transitioning = false;
  bool _transitionDone = false;

  @override
  void initState() {
    super.initState();

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _iconFade = CurvedAnimation(
      parent: _splashController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _splashController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _splashController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _subtitleFade = CurvedAnimation(
      parent: _splashController,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
    );
    _buttonFade = CurvedAnimation(
      parent: _splashController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _heroProgress = CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    );
    _contentFade = CurvedAnimation(
      parent: _transitionController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _splashController.forward();
    _splashController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _splashReady = true);
      }
    });

    _transitionController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _transitionDone = true);
      }
    });

    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    _transitionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startExploring() {
    setState(() => _transitioning = true);
    _transitionController.forward();
  }

  void _skip() {
    ChewieHiveUtil.put(CloudOTPHiveUtil.haveShownWelcome4Key, true);
    ChewieHiveUtil.put(CloudOTPHiveUtil.haveShownCoachMarkKey, true);
    ShortcutsUtil.jumpToMain();
  }

  void _finishWithGuide() {
    ChewieHiveUtil.put(CloudOTPHiveUtil.haveShownWelcome4Key, true);
    ShortcutsUtil.jumpToMain();
  }

  void _nextPage() {
    final pages = featurePages;
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      if (ResponsiveUtil.isMobile()) {
        _finishWithGuide();
      } else {
        _skip();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChewieTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            _buildFeatureContent(),
            if (!_transitionDone) _buildHeroTransition(),
            _buildSkipButton(),
            if (ResponsiveUtil.isDesktop()) const WindowMoveHandle(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroTransition() {
    return AnimatedBuilder(
      animation: Listenable.merge([_splashController, _transitionController]),
      builder: (context, child) {
        final t = _heroProgress.value;
        final screenHeight = MediaQuery.of(context).size.height;

        final bgOpacity = (1.0 - t).clamp(0.0, 1.0);

        // Elements fade out during transition
        final iconOpacity = _iconFade.value *
            (1.0 - Curves.easeIn.transform((t / 0.5).clamp(0.0, 1.0)));
        final subtitleOpacity = _subtitleFade.value *
            (1.0 - Curves.easeIn.transform((t / 0.3).clamp(0.0, 1.0)));
        final buttonOpacity = _buttonFade.value *
            (1.0 - Curves.easeIn.transform((t / 0.3).clamp(0.0, 1.0)));

        // Title hero: moves from center to top-left, font shrinks
        final titleTopStart = screenHeight * 0.42;
        final titleTopEnd = ResponsiveUtil.isMacOS() ? 15.0 : 12.0;
        final titleTop = titleTopStart + (titleTopEnd - titleTopStart) * t;
        final titleFontSize = 28.0 + (16.0 - 28.0) * t;
        final titleAlignment =
            Alignment.lerp(Alignment.center, Alignment.centerLeft, t)!;

        return Stack(
          children: [
            if (bgOpacity > 0)
              Positioned.fill(
                child: Container(
                  color: ChewieTheme.scaffoldBackgroundColor
                      .withAlpha((255 * bgOpacity).round()),
                ),
              ),
            // Icon
            if (iconOpacity > 0.01)
              Positioned.fill(
                child: Opacity(
                  opacity: iconOpacity.clamp(0.0, 1.0),
                  child: FadeTransition(
                    opacity: _iconFade,
                    child: ScaleTransition(
                      scale: _iconScale,
                      child: Align(
                        alignment: const Alignment(0, -0.35),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                ChewieTheme.primaryColor.withAlpha(60),
                                ChewieTheme.primaryColor.withAlpha(20),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ChewieTheme.primaryColor.withAlpha(80),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.shieldCheck,
                            size: 40,
                            color: ChewieTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Title (hero animation: center → top-left)
            Positioned(
              left: ResponsiveUtil.isMacOS()
                  ? 20 + (macosTitleBarLeftMargin - 20) * t
                  : 20,
              right: 20,
              top: titleTop,
              child: Opacity(
                opacity: _titleFade.value.clamp(0.0, 1.0),
                child: Align(
                  alignment: titleAlignment,
                  child: Text(
                    t < 0.5 ? appLocalizations.welcomeTitle : 'CloudOTP 4.0',
                    textAlign: t < 0.5 ? TextAlign.center : TextAlign.left,
                    style: ChewieTheme.titleLarge.copyWith(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ),
            // Subtitle
            if (subtitleOpacity > 0.01)
              Positioned(
                left: 48,
                right: 48,
                top: screenHeight * 0.54,
                child: Opacity(
                  opacity: subtitleOpacity.clamp(0.0, 1.0),
                  child: Text(
                    appLocalizations.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: ChewieTheme.bodyMedium.copyWith(
                      color: ChewieTheme.bodyMedium.color?.withAlpha(150),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            // Button
            if (buttonOpacity > 0.01)
              Positioned(
                left: 48,
                right: 48,
                top: screenHeight * 0.62,
                child: Opacity(
                  opacity: buttonOpacity.clamp(0.0, 1.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _splashReady && !_transitioning
                              ? _startExploring
                              : null,
                          style: TextButton.styleFrom(
                            backgroundColor: ChewieTheme.primaryColor,
                            overlayColor: Colors.white.withAlpha(30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            appLocalizations.welcomeStartExploring,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureContent() {
    final pages = featurePages;
    return FadeTransition(
      opacity: _contentFade,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              ResponsiveUtil.isMacOS() ? macosTitleBarLeftMargin : 20,
              ResponsiveUtil.isMacOS() ? 15 : 12,
              20,
              0,
            ),
            child: Row(
              children: [
                Opacity(
                  opacity: _transitionDone ? 1.0 : 0.0,
                  child: Text(
                    'CloudOTP 4.0',
                    style: ChewieTheme.titleLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              itemBuilder: (context, index) => pages[index].build(),
            ),
          ),
          const SizedBox(height: 12),
          _buildPageIndicator(pages.length),
          const SizedBox(height: 16),
          _buildActionButton(pages.length),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int total) {
    final activeColor = featurePages[_currentPage].color;
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
            color: isActive ? activeColor : activeColor.withAlpha(50),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(int totalPages) {
    final isLast = _currentPage == totalPages - 1;
    final color = featurePages[_currentPage].color;
    final label = isLast
        ? (ResponsiveUtil.isMobile()
            ? appLocalizations.welcomeStartGuide
            : appLocalizations.welcomeGetStarted)
        : appLocalizations.welcomeNextButton;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _nextPage,
              style: TextButton.styleFrom(
                backgroundColor: color,
                overlayColor: Colors.white.withAlpha(30),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Positioned(
      top: 8,
      right: ResponsiveUtil.isMacOS() ? 8 : 16,
      child: TextButton(
        onPressed: _skip,
        style: TextButton.styleFrom(
          overlayColor: ChewieTheme.primaryColor.withAlpha(30),
        ),
        child: Text(
          appLocalizations.welcomeSkip,
          style: ChewieTheme.bodyMedium.copyWith(
            color: ChewieTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
