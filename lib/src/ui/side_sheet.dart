import 'package:flutter/material.dart';

Future<void> showSideSheet(BuildContext context,
    {required Widget body, required String headerText}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Side sheet',
    transitionDuration: const Duration(milliseconds: 500),
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.3),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position:
            Tween(begin: const Offset(1, 0), end: const Offset(0, 0)).animate(
          animation,
        ),
        child: child,
      );
    },
    pageBuilder: (context, animation1, animation2) {
      return Align(
        alignment: Alignment.centerRight,
        child: SideSheetContent(
          headerText: headerText,
          body: body,
        ),
      );
    },
  ).then((value) {
    return;
  });
}

class SideSheetContent extends StatelessWidget {
  final String headerText;
  final Widget body;

  const SideSheetContent({
    super.key,
    required this.headerText,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Material(
      elevation: 1,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      child: SafeArea(
        top: true,
        bottom: false,
        minimum: const EdgeInsets.only(top: 24),
        child: Container(
          constraints: BoxConstraints(
            minWidth: 256,
            maxWidth: size.width <= 600 ? size.width : 500,
            minHeight: size.height,
            maxHeight: size.height,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Text(
                      headerText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    const Flexible(
                      fit: FlexFit.tight,
                      child: SizedBox(width: 12),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
