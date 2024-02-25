import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
  });

  static const routeName = '/take-picture';

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

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
      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
      );
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

  @override
  void dispose() {
    _resetOrientation();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.takePictureTitle)),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller != null) {
            final cameraAspectRatio = _controller!.value.aspectRatio;

            return Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Image.network('https://via.placeholder.com/150',
                      fit: BoxFit.cover),
                ),
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
                          onPressed: () async {
                            try {
                              await _initializeControllerFuture;

                              // Capture the image and get an XFile
                              final XFile rawImage =
                                  await _controller!.takePicture();

                              // Compress the image and get a new XFile
                              final XFile? compressedImage =
                                  await compressImage(rawImage.path, 70);

                              // Display or use the compressed XFile as needed
                              // For example, update your UI or state here
                            } catch (e) {
                              print(e);
                            }
                          },
                          child: const Icon(Icons.camera_alt),
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
