import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:uvccamera/uvccamera.dart';

@RoutePage()
class UVCCameraScreen extends StatefulWidget {
  const UVCCameraScreen({super.key});

  @override
  State<UVCCameraScreen> createState() => _UVCCameraScreenState();
}

class _UVCCameraScreenState extends State<UVCCameraScreen> {
  bool _isSupported = false;
  final Map<String, UvcCameraDevice> _devices = {};

  @override
  void initState() {
    super.initState();

    UvcCamera.isSupported().then((value) {
      setState(() {
        _isSupported = value;
      });
    });

    UvcCamera.getDevices().then((devices) {
      setState(() {
        _devices.clear();
        for (var device in devices.values) {
          _devices[device.name] = device;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('UVC Camera Test'),
        ),
        body: const Center(
          child: Text(
            'UVC Camera is not supported on this device.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('UVC Camera Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              UvcCamera.getDevices().then((devices) {
                setState(() {
                  _devices.clear();
                  for (var device in devices.values) {
                    _devices[device.name] = device;
                  }
                });
              });
            },
          ),
        ],
      ),
      body: _devices.isEmpty
          ? const Center(
              child: Text(
                'No UVC devices connected.\nConnect a USB camera to your device.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              children: _devices.values.map((device) {
                return ListTile(
                  leading: const Icon(Icons.videocam),
                  title: Text(device.name),
                  subtitle: Text(
                      'Vendor ID: ${device.vendorId}, Product ID: ${device.productId}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => _UVCCameraDeviceScreen(device: device),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}

class _UVCCameraDeviceScreen extends StatelessWidget {
  final UvcCameraDevice device;

  const _UVCCameraDeviceScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Center(
        child: _UVCCameraWidget(device: device),
      ),
    );
  }
}

class _UVCCameraWidget extends StatefulWidget {
  final UvcCameraDevice device;

  const _UVCCameraWidget({required this.device});

  @override
  State<_UVCCameraWidget> createState() => _UVCCameraWidgetState();
}

class _UVCCameraWidgetState extends State<_UVCCameraWidget> with WidgetsBindingObserver {
  bool _isAttached = false;
  bool _hasDevicePermission = false;
  bool _hasCameraPermission = false;
  bool _isDeviceAttached = false;
  bool _isDeviceConnected = false;
  UvcCameraController? _cameraController;
  Future<void>? _cameraControllerInitializeFuture;
  String _log = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attach();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detach(force: true);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _attach();
    } else if (state == AppLifecycleState.paused) {
      _detach();
    }
  }

  void _attach({bool force = false}) {
    if (_isAttached && !force) {
      return;
    }

    UvcCamera.getDevices().then((devices) {
      setState(() {
        _log = 'Found devices: ${devices.length}\n$_log';
      });

      if (!devices.containsKey(widget.device.name)) {
        setState(() {
          _log = 'Device ${widget.device.name} not found\n$_log';
        });
        return;
      }

      setState(() {
        _log = 'Device ${widget.device.name} found\n$_log';
        _isDeviceAttached = true;
      });

      _requestPermissions();
    }).catchError((error) {
      setState(() {
        _log = 'Error getting devices: $error\n$_log';
      });
    });

    _isAttached = true;
  }

  void _detach({bool force = false}) {
    if (!_isAttached && !force) {
      return;
    }

    _hasDevicePermission = false;
    _hasCameraPermission = false;
    _isDeviceAttached = false;
    _isDeviceConnected = false;

    _cameraController?.dispose();
    _cameraController = null;
    _cameraControllerInitializeFuture = null;

    _isAttached = false;
  }

  Future<void> _requestPermissions() async {
    try {
      setState(() {
        _log = 'Requesting device permission...\n$_log';
      });
      
      final devicePermissionStatus = await UvcCamera.requestDevicePermission(widget.device);
      
      setState(() {
        _log = 'Device permission status: $devicePermissionStatus\n$_log';
        _hasDevicePermission = devicePermissionStatus;
      });
      
      if (devicePermissionStatus) {
        _initializeCamera();
      }
    } catch (e) {
      setState(() {
        _log = 'Error requesting permissions: $e\n$_log';
      });
    }
  }

  Future<void> _initializeCamera() async {
    if (!_hasDevicePermission || !_isDeviceAttached) {
      return;
    }

    setState(() {
      _log = 'Initializing camera...\n$_log';
    });

    try {
      _cameraController = UvcCameraController(device: widget.device);
      _cameraControllerInitializeFuture = _cameraController!.initialize().then((_) {
        setState(() {
          _isDeviceConnected = true;
          _log = 'Camera initialized\n$_log';
        });
      });
    } catch (e) {
      setState(() {
        _log = 'Error initializing camera: $e\n$_log';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDeviceAttached) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device is not attached', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _attach(force: true),
              child: const Text('Check for device'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SelectableText(_log),
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasDevicePermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device permission not granted', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: const Text('Grant Permission'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: SelectableText(_log),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<void>(
      future: _cameraControllerInitializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              Expanded(
                child: _cameraController != null && _isDeviceConnected
                    ? UvcCameraPreview(_cameraController!)
                    : const Center(child: Text('Camera not connected')),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Connected to: ${widget.device.name}'),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
} 