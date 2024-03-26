import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';
import 'package:kyoryo/src/screens/preview_pictures_screen.dart';
import 'package:kyoryo/src/ui/side_sheet.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.inspectionPoint});

  final InspectionPoint inspectionPoint;
  static const routeName = '/take-picture';

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  Orientation? currentOrientation;
  List<String> capturedPhotos = [];
  List<XFile> processingQueue = [];
  bool isProcessing = false;

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
      _initializeControllerFuture = _controller?.initialize();
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

  void _takePicture() async {
    try {
      await _initializeControllerFuture;

      final XFile rawImage = await _controller!.takePicture();

      processingQueue.add(rawImage);
      processNextImage();
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
      String imagePath =
          await compressAndRotateImage(image, currentOrientation);
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
                      showSideSheet(context,
                          header:
                              AppLocalizations.of(context)!.lastInspectionPhoto,
                          body: InteractiveViewer(
                              constrained: true,
                              child: Image.network(
                                  widget.inspectionPoint.photoUrl!)));
                    }

                    if (index == 1) {
                      showSideSheet(context,
                          header: AppLocalizations.of(context)!.diagramPicture,
                          body: InteractiveViewer(
                              child: Image.network(
                                  widget.inspectionPoint.diagramUrl!)));
                    }
                  },
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.photo_outlined),
                      selectedIcon: const Icon(Icons.photo),
                      label: Text(
                          AppLocalizations.of(context)!.lastInspectionPhoto),
                    ),
                    NavigationRailDestination(
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
                      Container(
                        width: 120,
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    isLabelVisible: capturedPhotos.isNotEmpty,
                                    label:
                                        Text(capturedPhotos.length.toString()),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundImage: capturedPhotos.isNotEmpty
                                          ? FileImage(File(capturedPhotos.last))
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
