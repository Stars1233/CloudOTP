import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';

class LoadingDialogWidget extends StatefulWidget {
  final bool dismissible;

  final ValueNotifier<String?> titleNotifier;

  final double size;

  const LoadingDialogWidget({
    super.key,
    this.dismissible = false,
    required this.titleNotifier,
    this.size = 40,
  });

  @override
  State<StatefulWidget> createState() => LoadingDialogWidgetState();
}

class LoadingDialogWidgetState extends State<LoadingDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PopScope(
          canPop: widget.dismissible,
          onPopInvokedWithResult: (_, __) => Future.value(widget.dismissible),
          child: Container(
            decoration: ChewieTheme.defaultDecoration.copyWith(
              color: ChewieTheme.scaffoldBackgroundColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: ValueListenableBuilder<String?>(
              valueListenable: widget.titleNotifier,
              builder: (context, title, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  chewieProvider.loadingWidgetBuilder(widget.size, false),
                  if (title != null) const SizedBox(height: 16),
                  if (title != null)
                    Text(
                      title,
                      style: ChewieTheme.labelLarge,
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
