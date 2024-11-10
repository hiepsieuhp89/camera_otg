import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/ui/photo_view_with_marking.dart';

class ImagesViewOverlay extends ModalRoute<void> {
  late List<String> imageUrls;
  Map<int, Marking> markings;
  int initialPage;

  ImagesViewOverlay(this.imageUrls,
      {this.initialPage = 0, this.markings = const {}});

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
    // final controller = PageController(initialPage: initialPage);
    final height = MediaQuery.of(context).size.height;
    final controller = CarouselSliderController();
    return Stack(
      children: <Widget>[
        CarouselSlider(
            carouselController: controller,
            items: imageUrls
                .mapIndexed((index, url) => PhotoViewWithMarking(
                      imageProvider: NetworkImage(url),
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                      marking: markings[index],
                    ))
                .toList(),
            options: CarouselOptions(
                initialPage: initialPage,
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                scrollPhysics: const NeverScrollableScrollPhysics())),
        Positioned(
          top: 4,
          left: 4,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Positioned(
          left: 16,
          top: height / 2 - 24,
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black26),
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.previousPage();
                }),
          ),
        ),
        Positioned(
          right: 16,
          top: height / 2 - 24,
          child: Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.black26),
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                onPressed: () {
                  controller.nextPage();
                }),
          ),
        ),
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
