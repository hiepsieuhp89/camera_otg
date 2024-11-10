import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:photo_view/photo_view.dart';

class ImageMarkingViewOverlay extends ModalRoute<Marking> {
  ImageProvider imageProvider;
  Marking? originalMarking;

  ImageMarkingViewOverlay({required this.imageProvider, this.originalMarking});

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
    return PageContent(
        imageProvider: imageProvider,
        initialMarking: originalMarking ?? const Marking(x: 0, y: 0));
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

class PageContent extends StatefulWidget {
  final ImageProvider imageProvider;
  final Marking initialMarking;

  const PageContent(
      {super.key, required this.imageProvider, required this.initialMarking});

  @override
  State<PageContent> createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  late Marking marking;
  late PhotoViewController controller;
  double scale = 1.0;
  Offset position = Offset.zero;
  int imageWidth = 0;
  int imageHeight = 0;
  double top = 0;
  double left = 0;

  @override
  void initState() {
    super.initState();
    marking = widget.initialMarking;
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, synchronousCall) {
      setState(() {
        imageHeight = info.image.height;
        imageWidth = info.image.width;

        setState(() {});
      });
    }));
    controller = PhotoViewController()
      ..outputStateStream.listen((value) {
        setState(() {
          scale = value.scale ?? 1.0;
          position = value.position;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onLongPressEnd: (details) {
              setState(() {
                final adjustedX = details.localPosition.dx / scale -
                    position.dx / scale -
                    screenWidth / 2 / scale +
                    imageWidth / 2;
                final adjustedY = details.localPosition.dy / scale -
                    position.dy / scale -
                    screenHeight / 2 / scale +
                    imageHeight / 2;

                marking = Marking(x: adjustedX.toInt(), y: adjustedY.toInt());
              });
            },
            child: PhotoView(
              controller: controller,
              imageProvider: widget.imageProvider,
            ),
          ),
          Positioned(
            top: (marking.y * scale) +
                (screenHeight - scale * imageHeight) / 2 +
                position.dy -
                10,
            left: (marking.x * scale) +
                (screenWidth - scale * imageWidth) / 2 +
                position.dx -
                10,
            child: const Icon(
              Icons.circle,
              color: Colors.red,
              size: 20,
            ),
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
              )),
          Positioned(
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text(
                '長押ししてマークを追加',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}
