import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

@RoutePage()
class DiagramSketchScreen extends ConsumerStatefulWidget {
  final Diagram diagram;

  const DiagramSketchScreen({super.key, required this.diagram});

  @override
  ConsumerState<DiagramSketchScreen> createState() => _DiagramSketchScreenState();
}

class _DiagramSketchScreenState extends ConsumerState<DiagramSketchScreen> {
  late PainterController controller;
  late ui.Image backgroundImage;
  bool isLoading = true;
  bool isSaving = false;
  FocusNode textFocusNode = FocusNode();
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
    
  // Define sticker image links
  static const List<String> imageLinks = [
    "https://i.imgur.com/btoI5OX.png",
    "https://i.imgur.com/EXTQFt7.png",
    "https://i.imgur.com/EDNjJYL.png",
    "https://i.imgur.com/uQKD6NL.png",
    "https://i.imgur.com/cMqVRbl.png",
    "https://i.imgur.com/1cJBAfI.png",
    "https://i.imgur.com/eNYfHKL.png",
    "https://i.imgur.com/c4Ag5yt.png",
    "https://i.imgur.com/GhpCJuf.png",
    "https://i.imgur.com/XVMeluF.png",
    "https://i.imgur.com/mt2yO6Z.png",
    "https://i.imgur.com/rw9XP1X.png",
    "https://i.imgur.com/pD7foZ8.png",
    "https://i.imgur.com/13Y3vp2.png",
    "https://i.imgur.com/ojv3yw1.png",
    "https://i.imgur.com/f8ZNJJ7.png",
    "https://i.imgur.com/BiYkHzw.png",
    "https://i.imgur.com/snJOcEz.png",
    "https://i.imgur.com/b61cnhi.png",
    "https://i.imgur.com/FkDFzYe.png",
    "https://i.imgur.com/P310x7d.png",
    "https://i.imgur.com/5AHZpua.png",
    "https://i.imgur.com/tmvJY4r.png",
    "https://i.imgur.com/PdVfGkV.png",
    "https://i.imgur.com/1PRzwBf.png",
    "https://i.imgur.com/VeeMfBS.png",
  ];

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontSize: 18,
          ),
        ),
        freeStyle: const FreeStyleSettings(
          color: Colors.red,
          strokeWidth: 5,
        ),
        shape: ShapeSettings(
          paint: shapePaint,
        ),
        scale: const ScaleSettings(
          enabled: true,
          minScale: 1,
          maxScale: 5,
        ),
      ),
    );
    loadImage();
  }

  Future<void> loadImage() async {
    // Load the network image
    final imageProvider = NetworkImage(widget.diagram.photo!.photoLink);
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    
    imageStream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }));

    backgroundImage = await completer.future;
    
    setState(() {
      controller.background = backgroundImage.backgroundDrawable;
      isLoading = false;
    });
  }

  Future<void> saveSketch() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      // Get the rendered image
      final renderedImage = await controller.renderImage(Size(
        backgroundImage.width.toDouble(),
        backgroundImage.height.toDouble(),
      ));
      
      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);
      
      await file.writeAsBytes((await renderedImage.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List());

      // Upload the new photo
      final photo = await ref.read(apiServiceProvider).uploadPhoto(tempPath);

      // Update the diagram with the new photo
      final updatedDiagram = widget.diagram.copyWith(photoId: photo.id!);
      await ref.read(apiServiceProvider).updateDiagram(updatedDiagram);

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save sketch: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> addSticker(String imageUrl) async {
    try {
      // Load the network image
      final imageProvider = NetworkImage(imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();
      
      imageStream.addListener(ImageStreamListener((info, _) {
        completer.complete(info.image);
      }));

      final stickerImage = await completer.future;
      
      // Create an image drawable and add it to the controller
      final drawable = ImageDrawable(
        image: stickerImage,
        position: const Offset(100, 100),  // Initial position
      );
      
      setState(() {
        controller.value = controller.value.copyWith(
          drawables: [...controller.value.drawables, drawable],
          selectedObjectDrawable: drawable,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add sticker: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sketch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: controller.canUndo ? controller.undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: controller.canRedo ? controller.redo : null,
          ),
          IconButton(
            icon: isSaving 
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
            onPressed: isSaving ? null : saveSketch,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: backgroundImage.width / backgroundImage.height,
                child: FlutterPainter(
                  controller: controller,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Free-style drawing
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw
                          ? FreeStyleMode.draw
                          : FreeStyleMode.none;
                    },
                    color: controller.freeStyleMode == FreeStyleMode.draw 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                  // Add text
                  IconButton(
                    icon: Icon(Icons.text_fields),
                    onPressed: () {
                      if (controller.freeStyleMode != FreeStyleMode.none) {
                        controller.freeStyleMode = FreeStyleMode.none;
                      }
                      controller.addText();
                    },
                    color: textFocusNode.hasFocus 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                  // Add shapes
                  PopupMenuButton<ShapeFactory>(
                    tooltip: "Add shape",
                    itemBuilder: (context) => <ShapeFactory, String>{
                      RectangleFactory(): "Rectangle",
                      OvalFactory(): "Oval",
                      ArrowFactory(): "Arrow",
                    }
                        .entries
                        .map((e) => PopupMenuItem(
                            value: e.key,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  e.key is RectangleFactory
                                      ? Icons.rectangle_outlined
                                      : e.key is OvalFactory
                                          ? Icons.circle_outlined
                                          : Icons.arrow_forward,
                                  color: Colors.black,
                                ),
                                Text(" ${e.value}")
                              ],
                            )))
                        .toList(),
                    onSelected: (factory) {
                      controller.shapeFactory = factory;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.shape_line,
                        color: controller.shapeFactory != null
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                  ),
                  // Eraser
                  IconButton(
                    icon: Icon(Icons.auto_fix_high),
                    onPressed: () {
                      controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase
                          ? FreeStyleMode.erase
                          : FreeStyleMode.none;
                    },
                    color: controller.freeStyleMode == FreeStyleMode.erase 
                        ? Theme.of(context).primaryColor 
                        : null,
                  ),
                  // Stickers
                  PopupMenuButton<String>(
                    tooltip: "Add sticker",
                    itemBuilder: (context) => imageLinks
                        .map((url) => PopupMenuItem(
                            value: url,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.network(
                                  url,
                                  width: 24,
                                  height: 24,
                                ),
                                Text(" Sticker ${imageLinks.indexOf(url) + 1}")
                              ],
                            )))
                        .toList(),
                    onSelected: addSticker,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.emoji_emotions),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
} 