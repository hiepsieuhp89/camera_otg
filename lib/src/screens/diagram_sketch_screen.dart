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
  static const Color toolbarBackgroundColor = Color(0xC0424242);

  bool isCompactConfig = true;

  @override
  void initState() {
    super.initState();
    isCompactConfig = true;
    
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
    textFocusNode.addListener(onFocus);
    loadImage();

    controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (!isAnyToolActive() && isSettingsPanelVisible) {
      hideSettingsPanel();
    } else if (isAnyToolActive() && isUIVisible && !isSettingsPanelVisible) {
      showSettingsPanel();
    }
  }

  void toggleUIVisibility() {
    setState(() {
      isUIVisible = !isUIVisible;
      if (!isUIVisible) {
        isSettingsPanelVisible = false;
      }
    });
  }
  
  void showSettingsPanel() {
    if (isAnyToolActive()) {
      setState(() {
        isSettingsPanelVisible = true;
        isCompactConfig = true;
        isUIVisible = true;
      });
    } else {
      hideSettingsPanel();
    }
  }
  
  void hideSettingsPanel() {
    setState(() {
      isSettingsPanelVisible = false;
    });
  }

  bool isInDrawingArea(Offset position) {
    if (!isUIVisible) {
      return true;
    }

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    
    double topBarHeight = kToolbarHeight + mediaQuery.padding.top;
    double bottomBarHeight = isSettingsPanelVisible ? 180.0 : 56.0;
    
    return position.dy > topBarHeight && position.dy < (screenHeight - bottomBarHeight);
  }

  void onCanvasTap(Offset position) {
  }

  void onDrawingStart(Offset position) {
  }

  void onFocus() {
    setState(() {
      isUIVisible = true;
      isKeyboardVisible = textFocusNode.hasFocus;
      
      if (textFocusNode.hasFocus) {
        isSettingsPanelVisible = true;
        Future.microtask(() => setState(() {}));
      }
    });
  }

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
      shapePaint = paint;
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

  Future<void> loadImage() async {
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
      final renderedImage = await controller.renderImage(Size(
        backgroundImage.width.toDouble(),
        backgroundImage.height.toDouble(),
      ));

      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);

      await file.writeAsBytes(
          (await renderedImage.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List());

      await CachedNetworkImage.evictFromCache(widget.diagram.photo!.photoLink);
      
      final photo = await ref.read(apiServiceProvider).uploadPhoto(tempPath);
      
      final updatedDiagram = widget.diagram.copyWith(photoId: photo.id!);
      
      final updatedDiagramFromApi = await ref.read(apiServiceProvider).updateDiagram(updatedDiagram);
      
      await CachedNetworkImage.evictFromCache(updatedDiagramFromApi.photo!.photoLink);
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      ref.invalidate(diagramsProvider(widget.diagram.bridgeId));
      ref.invalidate(inspectionPointsProvider(widget.diagram.bridgeId));
      ref.invalidate(damageInspectionProvider(widget.diagram.bridgeId));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
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
    final bottomPadding = mediaQuery.viewInsets.bottom;
    
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
                  color: Colors.black.withAlpha(51),
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
          if (!isLoading)
            Positioned.fill(
              child: FlutterPainter(
                controller: controller,
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
            
          Positioned(
            bottom: isSettingsPanelVisible ? 112 : 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: FloatingActionButton(
                heroTag: 'toggle_ui_always',
                backgroundColor: toolbarBackgroundColor,
                onPressed: toggleUIVisibility,
                child: Icon(
                  isUIVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          if (isSettingsPanelVisible)
            Positioned(
              bottom: isKeyboardVisible ? bottomPadding : 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},
                child: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (context, _, __) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 0,
                    ),
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: toolbarBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(51),
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
                                    : localizations.brushSettings,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 20),
                              onPressed: () {
                                hideSettingsPanel();
                                if (textFocusNode.hasFocus) {
                                  textFocusNode.unfocus();
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
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
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    controller.freeStyleMode =
                        controller.freeStyleMode != FreeStyleMode.draw
                            ? FreeStyleMode.draw
                            : FreeStyleMode.none;
                    
                    if (controller.shapeFactory != null) {
                      controller.shapeFactory = null;
                    }
                    
                    if (controller.freeStyleMode != FreeStyleMode.none) {
                      showSettingsPanel();
                    } else {
                      if (!isAnyToolActive()) {
                        hideSettingsPanel();
                      }
                    }
                  },
                  color: controller.freeStyleMode == FreeStyleMode.draw
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    controller.freeStyleMode =
                        controller.freeStyleMode != FreeStyleMode.erase
                            ? FreeStyleMode.erase
                            : FreeStyleMode.none;
                    
                    if (controller.shapeFactory != null) {
                      controller.shapeFactory = null;
                    }
                    
                    if (controller.freeStyleMode != FreeStyleMode.none) {
                      showSettingsPanel();
                    } else {
                      if (!isAnyToolActive()) {
                        hideSettingsPanel();
                      }
                    }
                  },
                  color: controller.freeStyleMode == FreeStyleMode.erase
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: () {
                    if (controller.freeStyleMode != FreeStyleMode.none) {
                      controller.freeStyleMode = FreeStyleMode.none;
                    }
                    if (controller.shapeFactory != null) {
                      controller.shapeFactory = null;
                    }
                    
                    showSettingsPanel();
                    
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) {
                        controller.addText();
                        Future.microtask(() => setState(() {}));
                      }
                    });
                  },
                  color: textFocusNode.hasFocus
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                ),
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
                    
                    if (factory != null) {
                      controller.shapePaint ??= shapePaint;
                      showSettingsPanel();
                    } else {
                      if (!isAnyToolActive()) {
                        hideSettingsPanel();
                      }
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
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        
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
          
        if (showFillOption && onFillChanged != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.fill,
                style: const TextStyle(fontSize: 12, color: Colors.white),
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

  bool isAnyToolActive() {
    return controller.freeStyleMode != FreeStyleMode.none || 
           controller.shapeFactory != null || 
           textFocusNode.hasFocus;
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChange);
    controller.dispose();
    textFocusNode.dispose();
    super.dispose();
  }
}
