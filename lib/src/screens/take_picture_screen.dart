import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';
import 'package:kyoryo/src/screens/bridge_inspection_screen.dart';
import 'package:kyoryo/src/screens/preview_pictures_screen.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/ui/collapsible_panel.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';
import 'package:audioplayers/audioplayers.dart';

class TakePictureScreenArguments {
  final InspectionPoint inspectionPoint;
  final InspectionPointReport? createdReport;

  TakePictureScreenArguments(
      {required this.inspectionPoint, this.createdReport});
}

class TakePictureScreen extends ConsumerStatefulWidget {
  const TakePictureScreen({super.key, required this.arguments});

  final TakePictureScreenArguments arguments;
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
  List<String> capturedPhotoPaths = [];
  List<Photo> uploadedPhotos = [];
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
    _initPhotos();
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

  void _initPhotos() {
    final previousReport = ref
        .read(
            bridgeInspectionProvider(widget.arguments.inspectionPoint.bridgeId!)
                .notifier)
        .findPreviousReportFromPoint(widget.arguments.inspectionPoint.id!);

    final preferredPhotoFromPreviousReport = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    setState(() {
      uploadedPhotos = widget.arguments.createdReport?.photos ?? [];
      previousPhoto = preferredPhotoFromPreviousReport;
      showPreviousPhoto = preferredPhotoFromPreviousReport != null;
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

      final XFile image = await _controller!.takePicture();

      AudioPlayer().play(AssetSource('sounds/camera_shoot.mp3'));

      setState(() {
        capturedPhotoPaths.add(image.path);
      });

      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _navigateToPreview() {
    Navigator.push<PreviewPicturesScreenResult>(
        context,
        MaterialPageRoute(
            builder: (context) => PreviewPicturesScreen(
                arguments: PreviewPicturesScreenArguments(
                    imagePaths: capturedPhotoPaths,
                    photos: uploadedPhotos)))).then((result) {
      if (result != null) {
        setState(() {
          capturedPhotoPaths = result.updatedImagePaths;
          uploadedPhotos = result.updatedUploadedPhotos;
        });
      }
    });
  }

  void _navigateToReportScreen() {
    _resetOrientation();
    _exitFullScreen();
    Navigator.pushNamed(context, BridgeInspectionEvaluationScreen.routeName,
            arguments: BridgeInspectionEvaluationScreenArguments(
                point: widget.arguments.inspectionPoint,
                capturedPhotos: capturedPhotoPaths,
                uploadedPhotos: uploadedPhotos,
                createdReport: widget.arguments.createdReport))
        .then((_) {
      _setLandscapeOrientation();
    });
  }

  void _confirmSkippingPoint() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.confirmationForNoPhoto),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.noOption),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesOption),
              onPressed: () {
                ref
                    .read(bridgeInspectionProvider(
                            widget.arguments.inspectionPoint.bridgeId!)
                        .notifier)
                    .createReport(
                        pointId: widget.arguments.inspectionPoint.id!,
                        capturedPhotoPaths: [],
                        metadata: {'remark': '点検をスキップした。'},
                        isSkipped: true);

                Navigator.popUntil(context,
                    ModalRoute.withName(BridgeInspectionScreen.routeName));
              },
            ),
          ],
        );
      },
    );
  }

  Widget getFlashIcon() {
    switch (_controller?.value.flashMode) {
      case FlashMode.off:
        return const Icon(Icons.flash_off, color: Colors.white);
      case FlashMode.auto:
        return const Icon(Icons.flash_auto, color: Colors.white);
      case FlashMode.always:
        return const Icon(Icons.flash_on, color: Colors.white);
      case FlashMode.torch:
        return const Icon(Icons.lightbulb, color: Colors.white);
      default:
        return const Icon(Icons.flash_auto, color: Colors.white);
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
      body: Row(
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
                  onPressed: capturedPhotoPaths.isEmpty
                      ? _confirmSkippingPoint
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
                    imageUrl: widget
                            .arguments.inspectionPoint.diagramMarkedPhotoLink ??
                        widget.arguments.inspectionPoint.diagramUrl!,
                    marking: widget.arguments.inspectionPoint.diagramMarkingX !=
                                null &&
                            widget.arguments.inspectionPoint.diagramMarkingY !=
                                null
                        ? Marking(
                            x: widget
                                .arguments.inspectionPoint.diagramMarkingX!,
                            y: widget
                                .arguments.inspectionPoint.diagramMarkingY!)
                        : null);
              }
            },
            destinations: [
              NavigationRailDestination(
                disabled: previousPhoto == null,
                icon: const Icon(Icons.photo_outlined),
                selectedIcon: const Icon(Icons.photo),
                label: Text(AppLocalizations.of(context)!.lastInspectionPhoto),
              ),
              NavigationRailDestination(
                  disabled:
                      widget.arguments.inspectionPoint.diagramMarkedPhotoLink ==
                              null &&
                          widget.arguments.inspectionPoint.diagramUrl == null,
                  icon: const Icon(Icons.schema_outlined),
                  selectedIcon: const Icon(Icons.schema),
                  label: Text(AppLocalizations.of(context)!.diagramPicture)),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Positioned.fill(
                  child: FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_controller!);
                      } else {
                        return Container(
                          color: Colors.black,
                        );
                      }
                    },
                  ),
                ),
                if (previousPhoto != null)
                  Positioned(
                      top: 0,
                      left: 0,
                      child: CollapsiblePanel(
                        collapsed: !showPreviousPhoto,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 250),
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
                                          imageUrl: previousPhoto!.photoLink);
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
                            child: Icon(Icons.remove, color: Colors.white),
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
                              icon:
                                  const Icon(Icons.circle, color: Colors.white),
                              iconSize: 70,
                            ),
                            SizedBox(
                              height: 48,
                              child: _buildLatestPhotoPreview(),
                            ),
                          ]),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLatestPhotoPreview() {
    ImageProvider? latestPhotoProvider;

    if (capturedPhotoPaths.isNotEmpty) {
      latestPhotoProvider = FileImage(File(capturedPhotoPaths.last));
    } else if (uploadedPhotos.isNotEmpty) {
      latestPhotoProvider = NetworkImage(uploadedPhotos.last.photoLink);
    }

    return GestureDetector(
      onTap: () {
        if (latestPhotoProvider != null) {
          _navigateToPreview();
        }
      },
      child: Badge(
        isLabelVisible: latestPhotoProvider != null,
        label: Text(
            (capturedPhotoPaths.length + uploadedPhotos.length).toString()),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: latestPhotoProvider,
          child: latestPhotoProvider == null
              ? const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      ),
    );
  }
}
