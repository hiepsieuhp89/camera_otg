import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:kyoryo/src/models/photo_inspection_result.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_photo_inspection_result.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/ui/collapsible_panel.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';
import 'package:audioplayers/audioplayers.dart';

@RoutePage()
class TakePictureScreen extends ConsumerStatefulWidget {
  final InspectionPoint inspectionPoint;
  final InspectionPointReport? createdReport;

  const TakePictureScreen(
      {super.key, required this.inspectionPoint, this.createdReport});

  @override
  ConsumerState<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends ConsumerState<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  InspectionPointReportPhoto? previousPhoto;
  List<InspectionPointReportPhoto> photos = [];
  bool showPreviousPhoto = false;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  double _maxExposureOffset = 0.0;
  double _minExposureOffset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enterFullScreen();
    _initCamera();
    _initPhotos();
    _setLandscapeOrientation();
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
        final maxExposureLevel = await _controller!.getMaxExposureOffset();
        final minExposureLevel = await _controller!.getMinExposureOffset();

        setState(() {
          _maxZoomLevel = maxZoomLevel;
          _minZoomLevel = minZoomLevel;
          _maxExposureOffset = maxExposureLevel;
          _minExposureOffset = minExposureLevel;
        });
      });
    });
  }

  void _initPhotos() {
    final previousReport = ref
        .read(
            bridgeInspectionProvider(widget.inspectionPoint.bridgeId).notifier)
        .findPreviousReportFromPoint(widget.inspectionPoint.id!);

    final preferredPhotoFromPreviousReport = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    setState(() {
      photos = widget.createdReport?.photos ?? [];
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

  void _setExposureOffset(double offset) async {
    setState(() {
      _currentExposureOffset = offset;
    });

    try {
      await _initializeControllerFuture;
      await _controller!.setExposureOffset(offset);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _takePicture() async {
    try {
      await _initializeControllerFuture;

      if (_controller!.value.isTakingPicture) {
        return;
      }

      await _controller!.lockCaptureOrientation();
      _controller!.takePicture().then((image) {
        AudioPlayer().play(AssetSource('sounds/camera_shoot.mp3'));

        cropPhoto(image.path).then((_) {
          setState(() {
            photos = List.from(photos)
              ..add(InspectionPointReportPhoto(
                  localPath: image.path,
                  sequenceNumber: photos.isEmpty ? 1 : null));
          });
        });

        _controller!.unlockCaptureOrientation();
        // set the exposure and focus point back to the center
        _controller!.setFocusPoint(const Offset(0.5, 0.5));
        _controller!.setExposurePoint(const Offset(0.5, 0.5));
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _navigateToPreview({
    bool isSkipped = false,
    String? skipReason,
  }) {
    _resetOrientation();
    _exitFullScreen();

    ref.read(currentPhotoInspectionResultProvider.notifier).set(
        PhotoInspectionResult(
            skipReason: skipReason, isSkipped: isSkipped, photos: photos));

    context.router
        .push<PhotoInspectionResult>(BridgeInspectionPhotosTabRoute(
            createdReport: widget.createdReport, point: widget.inspectionPoint))
        .then((data) {
      _setLandscapeOrientation();

      if (data != null) {
        setState(() {
          photos = List.from(data.photos);
        });
      }
    });
  }

  void _navigateToReportScreen({bool isSkipped = false, String? skipReason}) {
    _resetOrientation();
    _exitFullScreen();

    ref.read(currentPhotoInspectionResultProvider.notifier).set(
        PhotoInspectionResult(
            skipReason: skipReason, isSkipped: isSkipped, photos: photos));

    context
        .pushRoute<PhotoInspectionResult>(BridgeInspectionEvaluationRoute(
      point: widget.inspectionPoint,
      createdReport: widget.createdReport,
    ))
        .then((result) {
      _setLandscapeOrientation();

      if (result != null) {
        setState(() {
          photos = List.from(result.photos);
        });
      }
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
                _navigateToReportScreen(
                    isSkipped: true,
                    skipReason:
                        AppLocalizations.of(context)!.inspectionWasSkipped);
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

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (_controller == null) {
      return;
    }

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );

    _controller!.setExposurePoint(offset);
    _controller!.setFocusPoint(offset);
  }

  Widget _buildCameraPreview() {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Stack(alignment: Alignment.centerLeft, children: [
      SizedBox(
        width: screenHeight / 3 * 4,
        height: screenHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            child: FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CustomPaint(
                    foregroundPainter: CameraGrid(),
                    child: FittedBox(
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: screenHeight * _controller!.value.aspectRatio,
                          height: screenHeight,
                          child: CameraPreview(_controller!, child:
                              LayoutBuilder(builder: (BuildContext context,
                                  BoxConstraints constraints) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (TapDownDetails details) =>
                                  _onViewFinderTap(details, constraints),
                            );
                          })),
                        )),
                  );
                } else {
                  return Container(
                    color: Colors.black,
                  );
                }
              },
            ),
          ),
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
                      width: 1, color: Theme.of(context).dividerColor),
                  bottom: BorderSide(
                      width: 1, color: Theme.of(context).dividerColor),
                )),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: previousPhoto!.url!,
                      height: 150,
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            viewImage(context, imageUrl: previousPhoto!.url!);
                          },
                          icon: const Icon(Icons.fullscreen),
                          iconSize: 30,
                          color: Colors.white,
                        ))
                  ],
                ),
              ),
            )),
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Row(
          children: [
            const SizedBox(width: 24),
            const Icon(Icons.exposure, color: Colors.white),
            Expanded(
              child: Slider(
                  activeColor: Colors.grey.shade100,
                  inactiveColor: Colors.grey.shade100,
                  thumbColor: Colors.purple.shade100,
                  value: _currentExposureOffset,
                  min: _minExposureOffset,
                  max: _maxExposureOffset,
                  onChanged: _minExposureOffset == _maxExposureOffset
                      ? null
                      : _setExposureOffset),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    ]);
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
                  onPressed: photos.isEmpty
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
                final showMarking =
                    widget.inspectionPoint.diagramMarkingX != null &&
                        widget.inspectionPoint.diagramMarkingY != null &&
                        widget.inspectionPoint.diagramMarkedPhotoLink == null;

                viewImage(context,
                    imageUrl: widget.inspectionPoint.diagramMarkedPhotoLink ??
                        widget.inspectionPoint.diagramUrl!,
                    marking: showMarking
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
                label: Text(AppLocalizations.of(context)!.lastInspectionPhoto),
              ),
              NavigationRailDestination(
                  disabled:
                      widget.inspectionPoint.diagramMarkedPhotoLink == null &&
                          widget.inspectionPoint.diagramUrl == null,
                  icon: const Icon(Icons.schema_outlined),
                  selectedIcon: const Icon(Icons.schema),
                  label: Text(AppLocalizations.of(context)!.diagramPicture)),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          _buildCameraPreview(),
          Expanded(
              child: Container(
            color: Colors.black,
            child: Row(
              children: [
                RotatedBox(
                  quarterTurns: 3,
                  child: Row(
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
                Expanded(
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
                          icon: const Icon(Icons.circle, color: Colors.white),
                          iconSize: 70,
                        ),
                        SizedBox(
                          height: 48,
                          child: _buildLatestPhotoPreview(),
                        ),
                      ]),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildLatestPhotoPreview() {
    ImageProvider? latestPhotoProvider;

    // if (capturedPhotoPaths.isNotEmpty) {
    //   latestPhotoProvider = FileImage(File(capturedPhotoPaths.last));
    // } else if (uploadedPhotos.isNotEmpty) {
    //   latestPhotoProvider = NetworkImage(uploadedPhotos.last.url);
    // }

    if (photos.isNotEmpty) {
      latestPhotoProvider = photos.last.localPath != null
          ? FileImage(File(photos.last.localPath!))
          : CachedNetworkImageProvider(photos.last.url!) as ImageProvider;
    }

    return GestureDetector(
      onTap: () {
        if (latestPhotoProvider != null) {
          _navigateToPreview();
        }
      },
      child: Badge(
        isLabelVisible: latestPhotoProvider != null,
        label: Text(photos.length.toString()),
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

class CameraGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(
        Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width / 3 * 2, 0),
        Offset(size.width / 3 * 2, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height / 3 * 2),
        Offset(size.width, size.height / 3 * 2), paint);
  }

  @override
  bool shouldRepaint(CameraGrid oldDelegate) => false;
}
