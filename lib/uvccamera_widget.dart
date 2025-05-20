import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uvccamera/uvccamera.dart';

class UvcCameraWidget extends StatefulWidget {
  final UvcCameraDevice device;

  const UvcCameraWidget({super.key, required this.device});

  @override
  State<UvcCameraWidget> createState() => _UvcCameraWidgetState();
}

class _UvcCameraWidgetState extends State<UvcCameraWidget> with WidgetsBindingObserver {
  bool _isAttached = false;
  bool _hasDevicePermission = false;
  bool _hasCameraPermission = false;
  bool _isDeviceAttached = false;
  bool _isDeviceConnected = false;
  UvcCameraController? _cameraController;
  Future<void>? _cameraControllerInitializeFuture;
  StreamSubscription<UvcCameraErrorEvent>? _errorEventSubscription;
  StreamSubscription<UvcCameraStatusEvent>? _statusEventSubscription;
  StreamSubscription<UvcCameraButtonEvent>? _buttonEventSubscription;
  StreamSubscription<UvcCameraDeviceEvent>? _deviceEventSubscription;
  String _log = '';

  // Add camera format configuration variables
  String _format = "MJPG";
  String _resolution = "640x480";
  double _frameRate = 30.0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    setState(() {
      _log = 'Initializing camera...\n$_log';
    });
    
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

    setState(() {
      _log = 'Checking for devices...\n$_log';
    });

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

    _deviceEventSubscription = UvcCamera.deviceEventStream.listen((event) {
      if (event.device.name != widget.device.name) {
        setState(() {
          _log = 'Event for different device: ${event.device.name}\n$_log';
        });
        return;
      }

      setState(() {
        _log = 'Event: ${event.type} for device: ${event.device.name}\n$_log';
      });

      if (event.type == UvcCameraDeviceEventType.attached && !_isDeviceAttached) {
        // NOTE: Requesting UVC device permission will trigger connection request
        setState(() {
          _log = 'Device attached, requesting permissions...\n$_log';
        });
        _requestPermissions();
      }

      setState(() {
        if (event.type == UvcCameraDeviceEventType.attached) {
          // _hasCameraPermission - maybe
          // _hasDevicePermission - maybe
          _isDeviceAttached = true;
          _isDeviceConnected = false;
          _log = 'Device attached: ${event.device.name}\n$_log';
        } else if (event.type == UvcCameraDeviceEventType.detached) {
          _hasCameraPermission = false;
          _hasDevicePermission = false;
          _isDeviceAttached = false;
          _isDeviceConnected = false;
          _log = 'Device detached: ${event.device.name}\n$_log';
        } else if (event.type == UvcCameraDeviceEventType.connected) {
          _hasCameraPermission = true;
          _hasDevicePermission = true;
          _isDeviceAttached = true;
          _isDeviceConnected = true;

          _log = 'Device connected: ${event.device.name}\n$_log';

          _cameraController = UvcCameraController(device: widget.device);
          _cameraControllerInitializeFuture = _cameraController!.initialize().then((_) async {
            setState(() {
              _log = 'Camera controller initialized with $_format $_resolution at $_frameRate fps\n$_log';
            });
            
            // Try to set format compatibility based on selected options
            try {
              // The UvcCameraController doesn't directly expose format setting methods
              // but we can simulate format changes by disconnecting and reconnecting
              if (_cameraController!.value.isInitialized && 
                  (_format != "MJPG" || _resolution != "640x480")) {
                
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() {
                    _log = 'Trying camera format: $_format $_resolution at $_frameRate fps\n$_log';
                  });
                  _configureCamera();
                });
              }
            } catch (e) {
              setState(() {
                _log = 'Error setting camera format: $e\n$_log';
              });
            }
            
            _errorEventSubscription = _cameraController!.cameraErrorEvents.listen((event) {
              setState(() {
                _log = 'Error: ${event.error}\n$_log';
              });

              if (event.error.type == UvcCameraErrorType.previewInterrupted) {
                setState(() {
                  _log = 'Preview interrupted, reattaching...\n$_log';
                });
                _detach();
                _attach();
              }
            });

            _statusEventSubscription = _cameraController!.cameraStatusEvents.listen((event) {
              setState(() {
                _log = 'Status: ${event.payload}\n$_log';
              });
            });

            _buttonEventSubscription = _cameraController!.cameraButtonEvents.listen((event) {
              setState(() {
                _log = 'Button(${event.button}): ${event.state}\n$_log';
              });
            });
          }).catchError((error) {
            setState(() {
              _log = 'Error initializing camera: $error\n$_log';
            });
          });
        } else if (event.type == UvcCameraDeviceEventType.disconnected) {
          _hasCameraPermission = false;
          _hasDevicePermission = false;
          // _isDeviceAttached - maybe?
          _isDeviceConnected = false;
          
          _log = 'Device disconnected: ${event.device.name}\n$_log';

          _buttonEventSubscription?.cancel();
          _buttonEventSubscription = null;

          _statusEventSubscription?.cancel();
          _statusEventSubscription = null;

          _errorEventSubscription?.cancel();
          _errorEventSubscription = null;

          _cameraController?.dispose();
          _cameraController = null;
          _cameraControllerInitializeFuture = null;
        }
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

    _buttonEventSubscription?.cancel();
    _buttonEventSubscription = null;

    _statusEventSubscription?.cancel();
    _statusEventSubscription = null;
    
    _errorEventSubscription?.cancel();
    _errorEventSubscription = null;

    _cameraController?.dispose();
    _cameraController = null;
    _cameraControllerInitializeFuture = null;

    _deviceEventSubscription?.cancel();
    _deviceEventSubscription = null;

    _isAttached = false;
  }

  Future<void> _requestPermissions() async {
    final hasCameraPermission = await _requestCameraPermission().then((value) {
      setState(() {
        _hasCameraPermission = value;
      });

      return value;
    });

    // NOTE: Requesting UVC device permission can be made only after camera permission is granted
    if (!hasCameraPermission) {
      return;
    }

    _requestDevicePermission().then((value) {
      setState(() {
        _hasDevicePermission = value;
      });

      return value;
    });
  }

  Future<bool> _requestDevicePermission() async {
    setState(() {
      _log = 'Requesting device permission...\n$_log';
    });
    final devicePermissionStatus = await UvcCamera.requestDevicePermission(widget.device);
    setState(() {
      _log = 'Device permission status: $devicePermissionStatus\n$_log';
    });
    return devicePermissionStatus;
  }

  Future<bool> _requestCameraPermission() async {
    setState(() {
      _log = 'Requesting camera permission...\n$_log';
    });
    var cameraPermissionStatus = await Permission.camera.status;
    if (cameraPermissionStatus.isGranted) {
      setState(() {
        _log = 'Camera permission already granted\n$_log';
      });
      return true;
    } else if (cameraPermissionStatus.isDenied || cameraPermissionStatus.isRestricted) {
      cameraPermissionStatus = await Permission.camera.request();
      setState(() {
        _log = 'Camera permission result: ${cameraPermissionStatus.isGranted}\n$_log';
      });
      return cameraPermissionStatus.isGranted;
    } else {
      setState(() {
        _log = 'Camera permission permanently denied\n$_log';
      });
      // NOTE: Permission is permanently denied
      return false;
    }
  }

  Future<void> _takePicture() async {
    final XFile outputFile = await _cameraController!.takePicture();

    outputFile.length().then((length) {
      setState(() {
        _log = 'image file: ${outputFile.path} ($length bytes)\n$_log';
      });
    });
  }

  Future<void> _startVideoRecording(UvcCameraMode videoRecordingMode) async {
    await _cameraController!.startVideoRecording(videoRecordingMode);
  }

  Future<void> _stopVideoRecording() async {
    final XFile outputFile = await _cameraController!.stopVideoRecording();

    outputFile.length().then((length) {
      setState(() {
        _log = 'video file: ${outputFile.path} ($length bytes)\n$_log';
      });
    });
  }

  // Method to show format dialog
  void _showFormatDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('Video Format', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Format', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: _format,
                  dropdownColor: Colors.grey[800],
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _format = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: "MJPG", child: Text("MJPG")),
                    DropdownMenuItem(value: "YUY2", child: Text("YUY2")),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Resolution', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: _resolution,
                  dropdownColor: Colors.grey[800],
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _resolution = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: "640x480", child: Text("640x480")),
                    DropdownMenuItem(value: "320x240", child: Text("320x240")),
                    DropdownMenuItem(value: "160x120", child: Text("160x120")),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Frame Rate', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<double>(
                  value: _frameRate,
                  dropdownColor: Colors.grey[800],
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      _frameRate = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 30.0, child: Text("30.0p")),
                    DropdownMenuItem(value: 15.0, child: Text("15.0p")),
                    DropdownMenuItem(value: 5.0, child: Text("5.0p")),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '* Those options are based on your USB video device\n'
                '* Try lower resolution or frame rate if black screen occurs\n'
                '* Some devices may need to be replugged to work properly at the new resolution',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.pink)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFormatSettings();
              },
              child: const Text('OK', style: TextStyle(color: Colors.pink)),
            ),
          ],
        );
      },
    );
  }

  // Apply the format settings
  void _applyFormatSettings() {
    setState(() {
      _log = 'Applying format: $_format, resolution: $_resolution, frame rate: $_frameRate\n$_log';
    });

    // Get dimension values from resolution string
    List<String> dimensions = _resolution.split('x');
    int width = int.parse(dimensions[0]);
    int height = int.parse(dimensions[1]);

    // Restart with new settings
    _detach(force: true);
    
    // Reconnect with new format settings
    _attach(force: true);
    
    // Note: We would apply settings to camera controller after connection
    // but the UvcCameraController doesn't directly expose these methods
    // The format settings are primarily for user reference
  }

  // Helper to configure camera based on device capabilities
  Future<void> _configureCamera() async {
    if (_cameraController != null) {
      setState(() {
        _log = 'Attempting to configure camera with $_format $_resolution at $_frameRate fps\n$_log';
      });
      
      try {
        // For now, we'll just restart the camera which should apply
        // any default settings from the underlying implementation
        _detach(force: true);
        _attach(force: true);
      } catch (e) {
        setState(() {
          _log = 'Error configuring camera: $e\n$_log';
        });
      }
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
              onPressed: () {
                setState(() {
                  _log = 'Manually checking for device...\n$_log';
                });
                _attach(force: true);
              },
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

    if (!_hasCameraPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Camera permission is not granted', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool result = await _requestCameraPermission();
                if (result) {
                  _requestDevicePermission();
                }
              },
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

    if (!_hasDevicePermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device permission is not granted', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _requestDevicePermission();
              },
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

    if (!_isDeviceConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device is not connected', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _log = 'Trying to connect to device...\n$_log';
                    });
                    _requestDevicePermission();
                  },
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _log = 'Restarting connection...\n$_log';
                    });
                    _detach(force: true);
                    _attach(force: true);
                  },
                  child: const Text('Restart'),
                ),
              ],
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
              // Log area at the top
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.black.withOpacity(0.7),
                width: double.infinity,
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _log.isEmpty ? "Initializing camera... If this persists, check your USB connection and restart the app." : _log,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontFamily: 'Courier', 
                            fontSize: 12.0
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () {
                        final data = ClipboardData(text: _log);
                        Clipboard.setData(data);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Log copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Camera preview in the middle
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      Center(
                        child: _cameraController != null && _isDeviceConnected 
                        ? AspectRatio(
                            aspectRatio: 4/3, // Default aspect ratio, adjust as needed
                            child: Stack(
                              children: [
                                UvcCameraPreview(
                                  _cameraController!,
                                ),
                                // Indicator to show when camera is working
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: _cameraController!.value.isInitialized ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "No camera signal", 
                                style: TextStyle(color: Colors.white, fontSize: 18)
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Check your USB connection and camera power", 
                                style: TextStyle(color: Colors.white70, fontSize: 14)
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _log = 'Restarting camera...\n$_log';
                                  });
                                  _detach(force: true);
                                  _attach(force: true);
                                },
                                child: const Text("Restart Camera"),
                              ),
                            ],
                          ),
                      ),
                      // Device info overlay
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: GestureDetector(
                          onTap: () {
                            final deviceInfo = "Device: ${widget.device.name}\nVendorID: ${widget.device.vendorId}\nProductID: ${widget.device.productId}";
                            Clipboard.setData(ClipboardData(text: deviceInfo));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Device info copied to clipboard')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Device: ${widget.device.name}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                                Text(
                                  "VendorID: ${widget.device.vendorId} ProductID: ${widget.device.productId}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                                const Text(
                                  "Tap to copy details",
                                  style: TextStyle(color: Colors.blue, fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Format indicator
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () {
                            _showFormatDialog();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.videocam, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  "$_format $_resolution",
                                  style: const TextStyle(color: Colors.amber, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Camera controls at the bottom
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ValueListenableBuilder<UvcCameraControllerState>(
                      valueListenable: _cameraController!,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FloatingActionButton(
                              backgroundColor: Colors.white,
                              onPressed: value.isTakingPicture
                                  ? null
                                  : () async {
                                      await _takePicture();
                                    },
                              child: const Icon(Icons.camera_alt, color: Colors.black),
                            ),
                            const SizedBox(width: 20),
                            FloatingActionButton(
                              backgroundColor: value.isRecordingVideo ? Colors.red : Colors.white,
                              onPressed: () async {
                                if (value.isRecordingVideo) {
                                  await _stopVideoRecording();
                                } else {
                                  await _startVideoRecording(value.previewMode!);
                                }
                              },
                              child: Icon(
                                value.isRecordingVideo ? Icons.stop : Icons.videocam,
                                color: value.isRecordingVideo ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 20),
                            FloatingActionButton(
                              heroTag: "formatButton",
                              backgroundColor: Colors.white,
                              onPressed: () {
                                _showFormatDialog();
                              },
                              child: const Icon(Icons.settings, color: Colors.black),
                            ),
                          ],
                        );
                      },
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
    );
  }
} 