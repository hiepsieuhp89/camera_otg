import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:kyoryo/src/providers/damage_inspection.provider.dart';
import 'package:kyoryo/src/providers/diagrams.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
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
  bool isUIVisible = true;
  bool isSettingsPanelVisible = false;
  bool isKeyboardVisible = false;
  FocusNode textFocusNode = FocusNode();
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static const Color defaultColor = Colors.red;
  static const Color toolbarBackgroundColor = Color(0xC0424242); // Lighter semi-transparent gray

  // Size of the config panel (compact vs normal)
  bool isCompactConfig = true;

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

    // Add listener to detect when user starts interacting with canvas
    controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    // If any drawing has started, hide the UI unless settings panel is visible
    if (!isSettingsPanelVisible && 
        (controller.freeStyleMode != FreeStyleMode.none && controller.value.drawables.isNotEmpty) ||
        controller.shapeFactory != null) {
      if (isUIVisible) {
        setState(() {
          isUIVisible = false;
        });
      }
    }
  }

  void toggleUIVisibility() {
    setState(() {
      isUIVisible = !isUIVisible;
      // Reset settings panel visibility if hiding UI
      if (!isUIVisible) {
        isSettingsPanelVisible = false;
      }
    });
  }
  
  void showSettingsPanel() {
    setState(() {
      isSettingsPanelVisible = true;
      isUIVisible = true;
    });
  }
  
  void hideSettingsPanel() {
    setState(() {
      isSettingsPanelVisible = false;
    });
  }

  void onFocus() {
    setState(() {
      isUIVisible = true;
      isKeyboardVisible = textFocusNode.hasFocus;
      
      // If keyboard is shown, we need to ensure the settings panel is visible
      if (textFocusNode.hasFocus) {
        isSettingsPanelVisible = true;
      }
    });
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
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.viewInsets.bottom; // Keyboard height
    
    // Update keyboard visibility state
    final keyboardIsVisible = bottomPadding > 0;
    if (isKeyboardVisible != keyboardIsVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isKeyboardVisible = keyboardIsVisible;
        });
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 0.4 + topPadding),
        child: Visibility(
          visible: isUIVisible,
          maintainState: true,
          maintainSize: true,
          maintainAnimation: true,
          maintainSemantics: true,
          child: Container(
            decoration: BoxDecoration(
              color: toolbarBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: SafeArea(
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: kToolbarHeight * 0.4,
                automaticallyImplyLeading: true,
                leadingWidth: 40,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  alignment: Alignment.center,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  localizations.editDiagram,
                  style: const TextStyle(color: Colors.white),
                ),
                titleSpacing: 0,
                actions: [
                  // Delete selected drawable
                  ValueListenableBuilder<PainterControllerValue>(
                    valueListenable: controller,
                    builder: (context, _, __) => IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: controller.selectedObjectDrawable == null
                          ? null
                          : removeSelectedDrawable,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  // Flip selected image
                  ValueListenableBuilder<PainterControllerValue>(
                    valueListenable: controller,
                    builder: (context, _, __) => IconButton(
                      icon: const Icon(Icons.flip, color: Colors.white),
                      onPressed: controller.selectedObjectDrawable is ImageDrawable
                          ? flipSelectedImageDrawable
                          : null,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  // Undo
                  ValueListenableBuilder<PainterControllerValue>(
                    valueListenable: controller,
                    builder: (context, _, __) => IconButton(
                      icon: const Icon(Icons.undo, color: Colors.white),
                      onPressed: controller.canUndo ? controller.undo : null,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  // Redo
                  ValueListenableBuilder<PainterControllerValue>(
                    valueListenable: controller,
                    builder: (context, _, __) => IconButton(
                      icon: const Icon(Icons.redo, color: Colors.white),
                      onPressed: controller.canRedo ? controller.redo : null,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  // Save
                  ValueListenableBuilder<PainterControllerValue>(
                    valueListenable: controller,
                    builder: (context, _, __) => IconButton(
                      icon: const Icon(Icons.save, color: Colors.white),
                      onPressed: isSaving ? null : saveSketch,
                      iconSize: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // The painter that takes full screen (always visible)
          if (!isLoading)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // Only toggle UI if not interacting with settings panel
                  if (!isSettingsPanelVisible) {
                    toggleUIVisibility();
                  }
                },
                child: FlutterPainter(
                  controller: controller,
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
            
          // Settings panel - only visible when explicitly shown
          if (isSettingsPanelVisible)
            Positioned(
              bottom: isKeyboardVisible ? bottomPadding : 0, // Position above keyboard or toolbar
              left: 0,
              right: 0,
              child: GestureDetector(
                // Prevent taps from reaching the canvas
                onTap: () {},
                child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, _, __) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: isCompactConfig ? 0 : 4
                    ),
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: toolbarBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.freeStyleMode != FreeStyleMode.none
                                ? localizations.brushSettings
                                : controller.shapeFactory != null
                                  ? localizations.shapeSettings
                                  : textFocusNode.hasFocus
                                    ? localizations.textSettings
                                    : "Settings",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: [
                                // Toggle compact/full mode
                                IconButton(
                                  icon: Icon(
                                    isCompactConfig ? Icons.expand_more : Icons.expand_less,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isCompactConfig = !isCompactConfig;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                // Close button
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  onPressed: () {
                                    hideSettingsPanel();
                                    // When closing text settings, unfocus the text field
                                    if (textFocusNode.hasFocus) {
                                      textFocusNode.unfocus();
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (controller.freeStyleMode != FreeStyleMode.none) ...[
                          buildCompactSettingsControls(
                            label: localizations.width,
                            value: controller.freeStyleStrokeWidth,
                            min: 2,
                            max: 25,
                            onChanged: setFreeStyleStrokeWidth,
                            showColor: controller.freeStyleMode == FreeStyleMode.draw,
                            colorValue: controller.freeStyleColor,
                            onColorChanged: setFreeStyleColor,
                          ),
                        ],
                        if (textFocusNode.hasFocus) ...[
                          buildCompactSettingsControls(
                            label: localizations.size,
                            value: controller.textStyle.fontSize ?? 14,
                            min: 8,
                            max: 96,
                            onChanged: setTextFontSize,
                            showColor: true,
                            colorValue: controller.textStyle.color ?? defaultColor,
                            onColorChanged: setTextColor,
                          ),
                        ],
                        if (controller.shapeFactory != null) ...[
                          buildCompactSettingsControls(
                            label: localizations.width,
                            value: controller.shapePaint?.strokeWidth ?? shapePaint.strokeWidth,
                            min: 2,
                            max: 25,
                            onChanged: (value) => setShapeFactoryPaint(
                              (controller.shapePaint ?? shapePaint).copyWith(
                                strokeWidth: value,
                              ),
                            ),
                            showColor: true,
                            colorValue: (controller.shapePaint ?? shapePaint).color,
                            onColorChanged: (hue) => setShapeFactoryPaint(
                              (controller.shapePaint ?? shapePaint).copyWith(
                                color: HSVColor.fromAHSV(1, hue, 1, 1).toColor(),
                              ),
                            ),
                            showFillOption: true,
                            isFilled: (controller.shapePaint ?? shapePaint).style == PaintingStyle.fill,
                            onFillChanged: (value) => setShapeFactoryPaint(
                              (controller.shapePaint ?? shapePaint).copyWith(
                                style: value ? PaintingStyle.fill : PaintingStyle.stroke,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
          // Floating action button to toggle UI
          if (!isUIVisible)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'toggle_ui',
                backgroundColor: toolbarBackgroundColor,
                child: const Icon(Icons.settings),
                onPressed: toggleUIVisibility,
              ),
            ),
        ],
      ),
      bottomNavigationBar: Visibility(
        visible: isUIVisible,
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        maintainSemantics: true,
        child: Container(
          height: 56.0,
          decoration: const BoxDecoration(
            color: toolbarBackgroundColor,
          ),
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, _, __) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Free-style drawing
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    controller.freeStyleMode =
                        controller.freeStyleMode != FreeStyleMode.draw
                            ? FreeStyleMode.draw
                            : FreeStyleMode.none;
                    // Clear shape factory when switching to drawing
                    if (controller.shapeFactory != null) {
                      controller.shapeFactory = null;
                    }
                    // Show settings panel when selecting a drawing tool
                    showSettingsPanel();
                  },
                  color: controller.freeStyleMode == FreeStyleMode.draw
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
                // Eraser
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () {
                    controller.freeStyleMode =
                        controller.freeStyleMode != FreeStyleMode.erase
                            ? FreeStyleMode.erase
                            : FreeStyleMode.none;
                    // Clear shape factory when switching to eraser
                    if (controller.shapeFactory != null) {
                      controller.shapeFactory = null;
                    }
                    // Show settings panel when selecting eraser
                    showSettingsPanel();
                  },
                  color: controller.freeStyleMode == FreeStyleMode.erase
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
                // Add text
                IconButton(
                  icon: const Icon(Icons.text_fields, color: Colors.white),
                  onPressed: () {
                    if (controller.freeStyleMode != FreeStyleMode.none) {
                      controller.freeStyleMode = FreeStyleMode.none;
                    }
                    // Clear shape factory when adding text
                    if (controller.shapeFactory != null) {
                      controller.shapeFactory = null;
                    }
                    controller.addText();
                    // Show settings panel when adding text
                    showSettingsPanel();
                  },
                  color: textFocusNode.hasFocus
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
                // Add shapes
                PopupMenuButton<ShapeFactory?>(
                  tooltip: localizations.addShape,
                  icon: Icon(
                    Icons.shape_line,
                    color: controller.shapeFactory != null
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                  ),
                  color: toolbarBackgroundColor,
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
                                color: Colors.white,
                              ),
                              Text(" ${e.value}", style: const TextStyle(color: Colors.white))
                            ],
                          )))
                      .toList(),
                  onSelected: (factory) {
                    if (controller.freeStyleMode != FreeStyleMode.none) {
                      controller.freeStyleMode = FreeStyleMode.none;
                    }
                    controller.shapeFactory = factory;
                    // Show settings panel when selecting a shape
                    if (factory != null) {
                      showSettingsPanel();
                    } else {
                      hideSettingsPanel();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build compact or standard settings controls
  Widget buildCompactSettingsControls({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    bool showColor = false,
    Color? colorValue,
    ValueChanged<double>? onColorChanged,
    bool showFillOption = false,
    bool isFilled = false,
    ValueChanged<bool>? onFillChanged,
  }) {
    if (isCompactConfig) {
      // Compact version with all controls in one row
      return Row(
        children: [
          // Label
          SizedBox(
            width: 45,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          
          // Main slider
          Expanded(
            flex: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: Colors.white70,
                inactiveTrackColor: Colors.grey.shade700,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          
          // Color slider if needed
          if (showColor && colorValue != null && onColorChanged != null)
            Expanded(
              flex: 3,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  activeTrackColor: Colors.white70,
                  inactiveTrackColor: Colors.grey.shade700,
                  thumbColor: colorValue,
                ),
                child: Slider(
                  value: HSVColor.fromColor(colorValue).hue,
                  min: 0,
                  max: 359.99,
                  activeColor: colorValue,
                  onChanged: onColorChanged,
                ),
              ),
            ),
            
            // Fill switch if needed
            if (showFillOption && onFillChanged != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Fill",
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Switch(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    value: isFilled,
                    onChanged: onFillChanged,
                    activeColor: Colors.white,
                  ),
                ],
              ),
        ],
      );
    } else {
      // Standard version with controls in separate rows
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 45,
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: Colors.white70,
                    inactiveTrackColor: Colors.grey.shade700,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
          if (showColor && colorValue != null && onColorChanged != null)
            Row(
              children: [
                const SizedBox(
                  width: 45,
                  child: Text(
                    "Color",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      activeTrackColor: Colors.white70,
                      inactiveTrackColor: Colors.grey.shade700,
                      thumbColor: colorValue,
                    ),
                    child: Slider(
                      value: HSVColor.fromColor(colorValue).hue,
                      min: 0,
                      max: 359.99,
                      activeColor: colorValue,
                      onChanged: onColorChanged,
                    ),
                  ),
                ),
              ],
            ),
          if (showFillOption && onFillChanged != null)
            Row(
              children: [
                const SizedBox(
                  width: 45,
                  child: Text(
                    "Fill",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),
                Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isFilled,
                  onChanged: onFillChanged,
                  activeColor: Colors.white,
                ),
              ],
            ),
        ],
      );
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    controller.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
