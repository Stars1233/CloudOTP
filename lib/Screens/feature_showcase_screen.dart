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

import '../Utils/app_provider.dart';
import '../l10n/l10n.dart';
import 'feature_showcase_pages.dart';

class FeatureShowcaseScreen extends StatefulWidget {
  final bool isDialog;

  const FeatureShowcaseScreen({super.key, this.isDialog = false});

  static const String routeName = "/feature/showcase";

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
    extends BaseDynamicState<FeatureShowcaseScreen>
    with FeatureShowcasePages {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    final pages = featurePages;
    final body = Column(
      children: [
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
        _buildActionButton(),
        SizedBox(
            height: widget.isDialog
                ? 16
                : MediaQuery.of(context).padding.bottom + 24),
      ],
    );

    if (widget.isDialog) {
      return Container(
        color: ChewieTheme.scaffoldBackgroundColor,
        child: body,
      );
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

  Widget _buildActionButton() {
    final pages = featurePages;
    final isLast = _currentPage == pages.length - 1;
    final color = pages[_currentPage].color;

    final String label;
    final VoidCallback onPressed;

    if (!isLast) {
      label = appLocalizations.welcomeNextButton;
      onPressed = () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      };
    } else if (ResponsiveUtil.isMobile() && !widget.isDialog) {
      label = appLocalizations.welcomeStartGuide;
      onPressed = () {
        Navigator.of(context).pop();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          homeScreenState?.showCoachMark();
        });
      };
    } else if (ResponsiveUtil.isDesktop() ||
        ResponsiveUtil.isLandscapeTablet()) {
      label = appLocalizations.welcomeStartGuide;
      onPressed = () {
        if (widget.isDialog) {
          DialogNavigatorHelper.popPage();
        } else {
          Navigator.of(context).pop();
        }
        Future.delayed(const Duration(milliseconds: 400), () {
          mainScreenState?.showDesktopCoachMark(force: true);
        });
      };
    } else {
      label = appLocalizations.welcomeGetStarted;
      onPressed = () {
        if (widget.isDialog) {
          DialogNavigatorHelper.popPage();
        } else {
          Navigator.of(context).pop();
        }
      };
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                label,
                style: ChewieTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
