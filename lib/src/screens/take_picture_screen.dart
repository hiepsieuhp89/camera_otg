import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/screens/bridge_inspection_evaluation_screen.dart';
import 'package:kyoryo/src/screens/preview_pictures_screen.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.inspectionPoint});

  final InspectionPoint inspectionPoint;
  static const routeName = '/take-picture';

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  List<String> capturedPhotos = [];
  int _selectedIndex = 1;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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
      _controller = CameraController(backCamera, ResolutionPreset.medium,
          enableAudio: false);
      _initializeControllerFuture = _controller?.initialize();
    });
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void _resetOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _takePicture() async {
    setState(() {
      _isCapturing = true;
    });
    try {
      await _initializeControllerFuture;

      // Capture the image and get an XFile
      final XFile rawImage = await _controller!.takePicture();

      // Compress the image and get a new XFile
      final XFile? compressedImage = await compressImage(rawImage.path, 90);

      if (compressedImage != null) {
        capturedPhotos.add(compressedImage.path);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        _isCapturing = false;
      });
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
    Navigator.pushNamed(context, BridgeInspectionEvaluationScreen.routeName,
            arguments: BridgeInspectionEvaluationScreenArguments(
                point: widget.inspectionPoint, capturedPhotos: capturedPhotos))
        .then((_) {
      _setLandscapeOrientation();
    });
  }

  @override
  void dispose() {
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
            final cameraAspectRatio = _controller!.value.aspectRatio;

            return Row(
              children: <Widget>[
                NavigationRail(
                    leading: Column(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        const SizedBox(height: 12),
                        FloatingActionButton(
                          elevation: 0,
                          onPressed: capturedPhotos.isEmpty
                              ? null
                              : _navigateToReportScreen,
                          child: const Icon(Icons.check),
                        ),
                      ],
                    ),
                    labelType: NavigationRailLabelType.all,
                    onDestinationSelected: (int index) {
                      if (index == 0) {
                        return _navigateToPreview();
                      }

                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    destinations: [
                      NavigationRailDestination(
                        disabled: capturedPhotos.isEmpty,
                        icon: capturedPhotos.isEmpty
                            ? const Icon(Icons.photo_library_outlined)
                            : Badge(
                                label: Text(capturedPhotos.length.toString()),
                                child: const Icon(Icons.photo_library_outlined),
                              ),
                        selectedIcon: capturedPhotos.isEmpty
                            ? const Icon(Icons.photo_library)
                            : Badge(
                                label: Text(capturedPhotos.length.toString()),
                                child: const Icon(Icons.photo_library),
                              ),
                        label:
                            Text(AppLocalizations.of(context)!.capturedPhotos),
                      ),
                      NavigationRailDestination(
                        icon: const Icon(Icons.photo_outlined),
                        selectedIcon: const Icon(Icons.photo),
                        label: Text(
                            AppLocalizations.of(context)!.lastInspectionPhoto),
                      ),
                      NavigationRailDestination(
                          icon: const Icon(Icons.schema_outlined),
                          selectedIcon: const Icon(Icons.schema),
                          label: Text(
                              AppLocalizations.of(context)!.diagramPicture)),
                    ],
                    selectedIndex: _selectedIndex),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                    flex: 4,
                    child: _selectedIndex == 1
                        ? InteractiveViewer(
                            constrained: true,
                            child:
                                Image.network(widget.inspectionPoint.photoUrl!))
                        : InteractiveViewer(
                            child: Image.network(
                                widget.inspectionPoint.diagramUrl!))),
                Expanded(
                  flex: 8,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        color: Colors.black,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: cameraAspectRatio,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.height *
                                    cameraAspectRatio,
                                height: MediaQuery.of(context).size.height,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        bottom: 20,
                        child: FloatingActionButton(
                          heroTag: "take-picture",
                          onPressed: _isCapturing ? null : _takePicture,
                          child: Icon(Icons.camera_alt,
                              color: _isCapturing ? Colors.grey : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
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
