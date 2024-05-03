import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';
import 'package:kyoryo/src/screens/preview_pictures_screen.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/ui/collapsible_panel.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class TakePictureScreen extends ConsumerStatefulWidget {
  const TakePictureScreen({super.key, required this.inspectionPoint});

  final InspectionPoint inspectionPoint;
  static const routeName = '/take-picture';

  @override
  ConsumerState<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends ConsumerState<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  Orientation? currentOrientation;
  Photo? previousPhoto;
  List<String> capturedPhotos = [];
  List<XFile> processingQueue = [];
  bool isProcessing = false;
  bool showPreviousPhoto = false;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _minZoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          currentOrientation = MediaQuery.of(context).orientation;
        });
      }
    });
    _enterFullScreen();
    _initCamera();
    _setLandscapeOrientation();

    final previousReport = ref
        .read(
            bridgeInspectionProvider(widget.inspectionPoint.bridgeId!).notifier)
        .findPreviousReportFromPoint(widget.inspectionPoint.id!);

    final preferredPhotoFromPreviousReport = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    setState(() {
      previousPhoto = preferredPhotoFromPreviousReport;
      showPreviousPhoto = preferredPhotoFromPreviousReport != null;
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (mounted) {
      setState(() {
        currentOrientation = MediaQuery.of(context).orientation;
      });
    }
  }

  Future<void> _initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => throw Exception('Back camera not found'),
    );

    setState(() {
      _controller = CameraController(backCamera, ResolutionPreset.veryHigh,
          enableAudio: false);
      _initializeControllerFuture = _controller?.initialize().then((_) async {
        final maxZoomLevel = await _controller!.getMaxZoomLevel();
        final minZoomLevel = await _controller!.getMinZoomLevel();

        setState(() {
          _maxZoomLevel = maxZoomLevel;
          _minZoomLevel = minZoomLevel;
        });
      });
    });
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([]);
  }

  void _setZoomLevel(zoomLevel) async {
    try {
      await _initializeControllerFuture;
      await _controller!.setZoomLevel(zoomLevel);
      setState(() {
        _currentZoomLevel = zoomLevel;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;

      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setExposureMode(ExposureMode.locked);

      final XFile rawImage = await _controller!.takePicture();

      final player = AudioPlayer();
      player.play(AssetSource('sounds/camera_shoot.mp3'));

      processingQueue.add(rawImage);
      processNextImage();

      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> processNextImage() async {
    if (isProcessing || processingQueue.isEmpty) return;

    setState(() {
      isProcessing = true;
    });

    var batch = processingQueue.take(5).toList();
    processingQueue = processingQueue.skip(5).toList();

    var futures = batch.map((image) async {
      String imagePath = await compressAndRotateImage(image,
          currentOrientation: currentOrientation);
      capturedPhotos.add(imagePath);
    }).toList();

    await Future.wait(futures);

    setState(() {
      isProcessing = false;
    });

    if (processingQueue.isNotEmpty) {
      processNextImage();
    }
  }

  void _navigateToPreview() {
    Navigator.pushNamed(
      context,
      PreviewPicturesScreen.routeName,
      arguments: capturedPhotos,
    ).then((updatedImages) {
      if (updatedImages != null) {
        setState(() {
          capturedPhotos = updatedImages as List<String>;
        });
      }
    });
  }

  void _navigateToReportScreen() {
    _resetOrientation();
    _exitFullScreen();
    Navigator.pushNamed(context, BridgeInspectionEvaluationScreen.routeName,
            arguments: BridgeInspectionEvaluationScreenArguments(
                point: widget.inspectionPoint, capturedPhotos: capturedPhotos))
        .then((_) {
      _setLandscapeOrientation();
    });
  }

  Widget getFlashIcon() {
    switch (_controller!.value.flashMode) {
      case FlashMode.off:
        return const Icon(Icons.flash_off, color: Colors.white);
      case FlashMode.auto:
        return const Icon(Icons.flash_auto, color: Colors.white);
      case FlashMode.always:
        return const Icon(Icons.flash_on, color: Colors.white);
      case FlashMode.torch:
        return const Icon(Icons.lightbulb, color: Colors.white);
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) {
      return;
    }

    await _controller!.setFlashMode(mode);
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      if (mounted) {
        setState(() {});
      }
    });

    Navigator.pop(context);
  }

  void showFlashDialog() {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: Colors.black,
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        onPressed: () =>
                            onSetFlashModeButtonPressed(FlashMode.off),
                        icon: const Icon(Icons.flash_off, color: Colors.white)),
                    IconButton(
                        onPressed: () =>
                            onSetFlashModeButtonPressed(FlashMode.always),
                        icon: const Icon(Icons.flash_on, color: Colors.white)),
                    IconButton(
                        onPressed: () =>
                            onSetFlashModeButtonPressed(FlashMode.auto),
                        icon:
                            const Icon(Icons.flash_auto, color: Colors.white)),
                    IconButton(
                        onPressed: () =>
                            onSetFlashModeButtonPressed(FlashMode.torch),
                        icon: const Icon(Icons.lightbulb, color: Colors.white)),
                  ],
                ),
              ),
            ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _exitFullScreen();
    _resetOrientation();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null) {
            return Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: null,
                  leading: Column(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                      FloatingActionButton(
                        elevation: 0,
                        onPressed: capturedPhotos.isEmpty
                            ? null
                            : _navigateToReportScreen,
                        child: const Icon(Icons.check),
                      ),
                      const SizedBox(height: 16)
                    ],
                  ),
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (int index) {
                    if (index == 0) {
                      setState(() {
                        showPreviousPhoto = !showPreviousPhoto;
                      });
                    }

                    if (index == 1) {
                      viewImage(context,
                          imageUrl:
                              widget.inspectionPoint.diagramMarkedPhotoLink ??
                                  widget.inspectionPoint.diagramUrl!,
                          marking: widget.inspectionPoint.diagramMarkingX !=
                                      null &&
                                  widget.inspectionPoint.diagramMarkingY != null
                              ? Marking(
                                  x: widget.inspectionPoint.diagramMarkingX!,
                                  y: widget.inspectionPoint.diagramMarkingY!)
                              : null);
                    }
                  },
                  destinations: [
                    NavigationRailDestination(
                      disabled: previousPhoto == null,
                      icon: const Icon(Icons.photo_outlined),
                      selectedIcon: const Icon(Icons.photo),
                      label: Text(
                          AppLocalizations.of(context)!.lastInspectionPhoto),
                    ),
                    NavigationRailDestination(
                        disabled:
                            widget.inspectionPoint.diagramMarkedPhotoLink ==
                                    null &&
                                widget.inspectionPoint.diagramUrl == null,
                        icon: const Icon(Icons.schema_outlined),
                        selectedIcon: const Icon(Icons.schema),
                        label:
                            Text(AppLocalizations.of(context)!.diagramPicture)),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Positioned.fill(
                        child: CameraPreview(_controller!),
                      ),
                      if (previousPhoto != null)
                        Positioned(
                            top: 0,
                            left: 0,
                            child: CollapsiblePanel(
                              collapsed: !showPreviousPhoto,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 250),
                                decoration: BoxDecoration(
                                    border: Border(
                                  right: BorderSide(
                                      width: 1,
                                      color: Theme.of(context).dividerColor),
                                  bottom: BorderSide(
                                      width: 1,
                                      color: Theme.of(context).dividerColor),
                                )),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: previousPhoto!.photoLink,
                                      height: 150,
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: IconButton(
                                          onPressed: () {
                                            viewImage(context,
                                                imageUrl:
                                                    previousPhoto!.photoLink);
                                          },
                                          icon: const Icon(Icons.fullscreen),
                                          iconSize: 30,
                                          color: Colors.white,
                                        ))
                                  ],
                                ),
                              ),
                            )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          RotatedBox(
                            quarterTurns: 3,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const RotatedBox(
                                  quarterTurns: 3,
                                  child:
                                      Icon(Icons.remove, color: Colors.white),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: _currentZoomLevel,
                                    min: _minZoomLevel,
                                    max: _maxZoomLevel,
                                    onChanged: (zoomLevel) {
                                      _setZoomLevel(zoomLevel);
                                    },
                                    activeColor: Colors.grey.shade100,
                                    inactiveColor: Colors.grey.shade100,
                                    thumbColor: Colors.purple.shade100,
                                  ),
                                ),
                                const Icon(Icons.add, color: Colors.white),
                              ],
                            ),
                          ),
                          Container(
                            width: 120,
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 48,
                                    child: IconButton(
                                      onPressed: showFlashDialog,
                                      icon: getFlashIcon(),
                                      iconSize: 30,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _takePicture,
                                    icon: const Icon(Icons.circle,
                                        color: Colors.white),
                                    iconSize: 70,
                                  ),
                                  SizedBox(
                                    height: 48,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (capturedPhotos.isNotEmpty) {
                                          _navigateToPreview();
                                        }
                                      },
                                      child: Badge(
                                        isLabelVisible:
                                            capturedPhotos.isNotEmpty,
                                        label: Text(
                                            capturedPhotos.length.toString()),
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundImage:
                                              capturedPhotos.isNotEmpty
                                                  ? FileImage(
                                                      File(capturedPhotos.last))
                                                  : null,
                                          child: capturedPhotos.isEmpty
                                              ? const Icon(
                                                  Icons.photo_library_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
