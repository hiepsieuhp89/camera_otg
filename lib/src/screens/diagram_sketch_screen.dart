import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/damage_inspection.provider.dart';
import 'package:kyoryo/src/providers/diagram_inspection.provider.dart';
import 'package:kyoryo/src/providers/diagrams.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

@RoutePage()
class DiagramSketchScreen extends ConsumerStatefulWidget {
  final Diagram diagram;

  const DiagramSketchScreen({super.key, required this.diagram});

  @override
  ConsumerState<DiagramSketchScreen> createState() =>
      _DiagramSketchScreenState();
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

  static const Color defaultColor = Colors.red;

  // Define sticker image links
  /* 
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
  */

  @override
  void initState() {
    super.initState();
    controller = PainterController(
      settings: PainterSettings(
        text: TextSettings(
          focusNode: textFocusNode,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: defaultColor,
            fontSize: 18,
          ),
        ),
        freeStyle: const FreeStyleSettings(
          color: defaultColor,
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
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    loadImage();
  }

  void onFocus() {
    setState(() {});
  }

  // Helper methods for UI controls
  void setFreeStyleStrokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setFreeStyleColor(double hue) {
    controller.freeStyleColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
  }

  void setTextFontSize(double size) {
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
        textStyle: controller.textSettings.textStyle.copyWith(fontSize: size),
      );
    });
  }

  void setTextColor(double hue) {
    controller.textStyle = controller.textStyle.copyWith(
      color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
    );
  }

  void setShapeFactoryPaint(Paint paint) {
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(
      imageDrawable,
      imageDrawable.copyWith(flipped: !imageDrawable.flipped),
    );
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) {
      controller.removeDrawable(selectedDrawable);
    }
  }

  /* 
  Future<void> addSticker() async {
    final imageLink = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select sticker"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
            ),
            itemCount: imageLinks.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => Navigator.pop(context, imageLinks[index]),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(imageLinks[index]),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    if (imageLink == null) return;

    // Load and add the sticker
    final imageProvider = NetworkImage(imageLink);
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);
    final completer = Completer<ui.Image>();
    
    imageStream.addListener(ImageStreamListener((info, _) {
      completer.complete(info.image);
    }));

    final stickerImage = await completer.future;
    controller.addImage(stickerImage);
  }
  */

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
      final tempPath =
          '${tempDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);

      await file.writeAsBytes(
          (await renderedImage.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List());

      // First, explicitly evict the old image from cache
      await CachedNetworkImage.evictFromCache(widget.diagram.photo!.photoLink);
      
      // Upload the new photo
      final photo = await ref.read(apiServiceProvider).uploadPhoto(tempPath);
      
      // Update the diagram with the new photo
      final updatedDiagram = widget.diagram.copyWith(photoId: photo.id!);
      
      // Use direct API call to update the diagram
      final updatedDiagramFromApi = await ref.read(apiServiceProvider).updateDiagram(updatedDiagram);
      
      // IMPORTANT: Ensure we completely clear all caches for the new image URL
      await CachedNetworkImage.evictFromCache(updatedDiagramFromApi.photo!.photoLink);
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      // Invalidate all providers to force complete refresh
      ref.invalidate(diagramsProvider(widget.diagram.bridgeId));
      ref.invalidate(inspectionPointsProvider(widget.diagram.bridgeId));
      ref.invalidate(damageInspectionProvider(widget.diagram.bridgeId));
      
      // Add a small delay to ensure cache clearing completes
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // Return the updated diagram to the previous screen
        Navigator.of(context).pop(updatedDiagramFromApi);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .failedToSaveSketch(e.toString()))),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.editDiagram),
        actions: [
          // Delete selected drawable
          ValueListenableBuilder<PainterControllerValue>(
            valueListenable: controller,
            builder: (context, _, __) => IconButton(
              icon: const Icon(Icons.delete),
              onPressed: controller.selectedObjectDrawable == null
                  ? null
                  : removeSelectedDrawable,
            ),
          ),
          // Flip selected image
          ValueListenableBuilder<PainterControllerValue>(
            valueListenable: controller,
            builder: (context, _, __) => IconButton(
              icon: const Icon(Icons.flip),
              onPressed: controller.selectedObjectDrawable is ImageDrawable
                  ? flipSelectedImageDrawable
                  : null,
            ),
          ),
          // Undo
          ValueListenableBuilder<PainterControllerValue>(
            valueListenable: controller,
            builder: (context, _, __) => IconButton(
              icon: const Icon(Icons.undo),
              onPressed: controller.canUndo ? controller.undo : null,
            ),
          ),
          // Redo
          ValueListenableBuilder<PainterControllerValue>(
            valueListenable: controller,
            builder: (context, _, __) => IconButton(
              icon: const Icon(Icons.redo),
              onPressed: controller.canRedo ? controller.redo : null,
            ),
          ),
          // Save
          ValueListenableBuilder<PainterControllerValue>(
            valueListenable: controller,
            builder: (context, _, __) => IconButton(
              icon: const Icon(Icons.save),
              onPressed: isSaving ? null : saveSketch,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!isLoading)
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
          // Style controls panel
          Positioned(
            bottom: 0, // Lower position, just above the toolbar
            left: 0,
            right: 0,
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, _, __) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.freeStyleMode != FreeStyleMode.none) ...[
                      Text(
                        localizations.brushSettings,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                              width: 45,
                              child: Text(localizations.width,
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: controller.freeStyleStrokeWidth,
                                min: 2,
                                max: 25,
                                onChanged: setFreeStyleStrokeWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (controller.freeStyleMode == FreeStyleMode.draw)
                        Row(
                          children: [
                            SizedBox(
                                width: 45,
                                child: Text(localizations.color,
                                    style: const TextStyle(fontSize: 13))),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6),
                                ),
                                child: Slider(
                                  value: HSVColor.fromColor(
                                          controller.freeStyleColor)
                                      .hue,
                                  min: 0,
                                  max: 359.99,
                                  activeColor: controller.freeStyleColor,
                                  onChanged: setFreeStyleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                    if (textFocusNode.hasFocus) ...[
                      Text(
                        localizations.textSettings,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                              width: 45,
                              child: Text(localizations.size,
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: controller.textStyle.fontSize ?? 14,
                                min: 8,
                                max: 96,
                                onChanged: setTextFontSize,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                              width: 45,
                              child: Text(localizations.color,
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: HSVColor.fromColor(
                                        controller.textStyle.color ??
                                            defaultColor)
                                    .hue,
                                min: 0,
                                max: 359.99,
                                activeColor: controller.textStyle.color,
                                onChanged: setTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (controller.shapeFactory != null) ...[
                      Text(
                        localizations.shapeSettings,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                              width: 45,
                              child: Text(localizations.width,
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: controller.shapePaint?.strokeWidth ??
                                    shapePaint.strokeWidth,
                                min: 2,
                                max: 25,
                                onChanged: (value) => setShapeFactoryPaint(
                                  (controller.shapePaint ?? shapePaint)
                                      .copyWith(
                                    strokeWidth: value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                              width: 45,
                              child: Text(localizations.color,
                                  style: const TextStyle(fontSize: 13))),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 2,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: HSVColor.fromColor(
                                        (controller.shapePaint ?? shapePaint)
                                            .color)
                                    .hue,
                                min: 0,
                                max: 359.99,
                                activeColor:
                                    (controller.shapePaint ?? shapePaint).color,
                                onChanged: (hue) => setShapeFactoryPaint(
                                  (controller.shapePaint ?? shapePaint)
                                      .copyWith(
                                    color: HSVColor.fromAHSV(1, hue, 1, 1)
                                        .toColor(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                              width: 45,
                              child: Text(localizations.fill,
                                  style: const TextStyle(fontSize: 13))),
                          Switch(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            value:
                                (controller.shapePaint ?? shapePaint).style ==
                                    PaintingStyle.fill,
                            onChanged: (value) => setShapeFactoryPaint(
                              (controller.shapePaint ?? shapePaint).copyWith(
                                style: value
                                    ? PaintingStyle.fill
                                    : PaintingStyle.stroke,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, _, __) => Container(
          color: Colors.white,
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Free-style drawing
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  controller.freeStyleMode =
                      controller.freeStyleMode != FreeStyleMode.draw
                          ? FreeStyleMode.draw
                          : FreeStyleMode.none;
                  // Clear shape factory when switching to drawing
                  if (controller.shapeFactory != null) {
                    controller.shapeFactory = null;
                  }
                },
                color: controller.freeStyleMode == FreeStyleMode.draw
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              // Eraser
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  controller.freeStyleMode =
                      controller.freeStyleMode != FreeStyleMode.erase
                          ? FreeStyleMode.erase
                          : FreeStyleMode.none;
                  // Clear shape factory when switching to eraser
                  if (controller.shapeFactory != null) {
                    controller.shapeFactory = null;
                  }
                },
                color: controller.freeStyleMode == FreeStyleMode.erase
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
                  // Clear shape factory when adding text
                  if (controller.shapeFactory != null) {
                    controller.shapeFactory = null;
                  }
                  controller.addText();
                },
                color: textFocusNode.hasFocus
                    ? Theme.of(context).primaryColor
                    : null,
              ),
              /* 
              // Add sticker
              IconButton(
                icon: Icon(Icons.emoji_emotions),
                onPressed: () {
                  // Clear shape factory when adding sticker
                  if (controller.shapeFactory != null) {
                    controller.shapeFactory = null;
                  }
                  addSticker();
                },
              ),
              */
              // Add shapes
              PopupMenuButton<ShapeFactory?>(
                tooltip: localizations.addShape,
                itemBuilder: (context) => <ShapeFactory?, String>{
                  null: localizations.none,
                  LineFactory(): localizations.line,
                  ArrowFactory(): localizations.arrow,
                  DoubleArrowFactory(): localizations.doubleArrow,
                  RectangleFactory(): localizations.rectangle,
                  OvalFactory(): localizations.oval,
                }
                    .entries
                    .map((e) => PopupMenuItem(
                        value: e.key,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              e.key == null
                                  ? Icons.close
                                  : e.key is LineFactory
                                      ? Icons.horizontal_rule
                                      : e.key is ArrowFactory
                                          ? Icons.arrow_right_alt
                                          : e.key is DoubleArrowFactory
                                              ? Icons.sync_alt
                                              : e.key is RectangleFactory
                                                  ? Icons.rectangle_outlined
                                                  : Icons.circle_outlined,
                              color: Colors.black,
                            ),
                            Text(" ${e.value}")
                          ],
                        )))
                    .toList(),
                onSelected: (factory) {
                  if (controller.freeStyleMode != FreeStyleMode.none) {
                    controller.freeStyleMode = FreeStyleMode.none;
                  }
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
            ],
          ),
        ),
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
