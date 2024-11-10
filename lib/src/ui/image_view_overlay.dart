import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/ui/photo_view_with_marking.dart';

class ImageViewOverlay extends ModalRoute<void> {
  String imageUrl;
  Marking? marking;

  ImageViewOverlay({required this.imageUrl, this.marking});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: _buildOverlayContent(context),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        PhotoViewWithMarking(
          imageProvider: imageUrl.startsWith('http')
              ? NetworkImage(imageUrl)
              : FileImage(File(imageUrl)) as ImageProvider,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          marking: marking,
        ),
        Positioned(
            left: 4,
            top: 4,
            child: Container(
              height: 48,
              width: 48,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.black26),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context, marking);
                },
              ),
            ))
      ],
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
