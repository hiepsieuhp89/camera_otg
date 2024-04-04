import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:photo_view/photo_view.dart';

class PhotoViewWithMarking extends StatefulWidget {
  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final Marking? marking;

  const PhotoViewWithMarking(
      {super.key,
      this.backgroundDecoration,
      required this.imageProvider,
      this.marking});

  @override
  State<PhotoViewWithMarking> createState() => _PhotoViewWithMarkingState();
}

class _PhotoViewWithMarkingState extends State<PhotoViewWithMarking> {
  late PhotoViewController controller;
  double? scale;
  Offset? position;
  int? imageWidth;
  int? imageHeight;

  @override
  void initState() {
    super.initState();
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, call) {
      imageHeight = info.image.height;
      imageWidth = info.image.width;

      setState(() {});
    }));
    controller = PhotoViewController()..outputStateStream.listen(listener);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void listener(PhotoViewControllerValue value) {
    setState(() {
      scale = value.scale;
      position = value.position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        PhotoView(
          imageProvider: widget.imageProvider,
          controller: controller,
          backgroundDecoration: widget.backgroundDecoration,
        ),
        if (scale != null && position != null && widget.marking != null)
          Positioned(
              top: (widget.marking!.y * scale!) +
                  (screenHeight - scale! * imageHeight!) / 2 +
                  position!.dy,
              left: (widget.marking!.x * scale!) +
                  (screenWidth - scale! * imageWidth!) / 2 +
                  position!.dx,
              child: const Icon(
                Icons.circle,
                color: Colors.red,
                size: 20,
              ))
      ],
    );
  }
}
