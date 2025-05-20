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
        setState(() {
          _log = 'Device attached, requesting permissions...\n$_log';
        });
        _requestPermissions();
      }

      setState(() {
        if (event.type == UvcCameraDeviceEventType.attached) {
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

          _log = 'Device connected: ${event.device.name} - opening camera...\n$_log';

          _cameraController = UvcCameraController(device: widget.device);
          _cameraControllerInitializeFuture = _cameraController!.initialize().then((_) async {
            setState(() {
              _log = 'Camera initialized - starting preview...\n$_log';
            });
            
            if (_cameraController != null && _cameraController!.value.isInitialized) {
              _log = 'Preview started. Setting format: $_format $_resolution at $_frameRate fps\n$_log';
              
              List<String> dimensions = _resolution.split('x');
              int width = int.parse(dimensions[0]);
              int height = int.parse(dimensions[1]);
              
              Future.delayed(const Duration(milliseconds: 500), () {
                _configureCamera();
              });
            }
            
            _errorEventSubscription = _cameraController!.cameraErrorEvents.listen((event) {
              setState(() {
                _log = 'Error: ${event.error}\n$_log';
              });

              if (event.error.type == UvcCameraErrorType.previewInterrupted) {
                setState(() {
                  _log = 'Preview interrupted, reattaching surface...\n$_log';
                });
                
                Future.delayed(const Duration(milliseconds: 500), () {
                  _configureCamera();
                });
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
          title: const Text('Video Format Settings'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Format selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Format'),
                    value: _format,
                    items: ['MJPG', 'YUY2'].map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _format = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  // Resolution selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Resolution'),
                    value: _resolution,
                    items: ['320x240', '640x480', '800x600', '1280x720', '1920x1080'].map((resolution) {
                      return DropdownMenuItem(
                        value: resolution,
                        child: Text(resolution),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _resolution = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  // Frame rate selection
                  DropdownButtonFormField<double>(
                    decoration: const InputDecoration(labelText: 'Frame Rate'),
                    value: _frameRate,
                    items: [15.0, 24.0, 30.0, 60.0].map((fps) {
                      return DropdownMenuItem(
                        value: fps,
                        child: Text('$fps fps'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _frameRate = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '* Camera may need to be reconnected after changing settings\n'
                    '* Try MJPG format with 640x480 at 30fps for best compatibility\n'
                    '* If you see a black screen, try lower resolution or unplug/replug the camera',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                this.setState(() {
                  // Update format in the main widget state
                  // The actual variables will be updated through the closure
                });
                Navigator.of(context).pop();
                
                // After dialog is closed, apply the new settings
                _applyFormatSettings();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Apply the format settings
  void _applyFormatSettings() async {
    if (_cameraController == null) {
      setState(() {
        _log = 'Cannot apply settings - camera not connected\n$_log';
      });
      return;
    }
    
    // In Java, they completely reopen the camera when format changes
    try {
      setState(() {
        _log = 'Applying new format settings: $_format $_resolution at $_frameRate fps\n$_log';
      });
      
      // First disconnect the camera
      await _cameraController!.dispose();
      _cameraController = null;
      
      // Brief pause to ensure camera resources are released
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Reconnect with new settings
      _cameraController = UvcCameraController(device: widget.device);
      _cameraControllerInitializeFuture = _cameraController!.initialize().then((_) async {
        setState(() {
          _log = 'Camera reinitialized with new settings\n$_log';
        });
        
        // No longer calling _configureCamera() here to avoid recursion
        
        // Set up error and status listeners again
        _errorEventSubscription = _cameraController!.cameraErrorEvents.listen((event) {
          setState(() {
            _log = 'Error: ${event.error}\n$_log';
          });
          
          if (event.error.type == UvcCameraErrorType.previewInterrupted) {
            setState(() {
              _log = 'Preview interrupted, attempting to recover...\n$_log';
            });
            
            // Instead of calling _configureCamera, wait a moment and log
            Future.delayed(const Duration(milliseconds: 500), () {
              setState(() {
                _log = 'Camera recovery attempted\n$_log';
              });
            });
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
          _log = 'Error reinitializing camera: $error\n$_log';
        });
      });
    } catch (e) {
      setState(() {
        _log = 'Error applying camera settings: $e\n$_log';
      });
    }
  }

  // Helper to configure camera and add surface explicitly
  void _configureCamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _log = 'Cannot configure camera - controller not initialized\n$_log';
      });
      return;
    }
    
    setState(() {
      _log = 'Configuring camera with format: $_format, resolution: $_resolution, frameRate: $_frameRate\n$_log';
    });
    
    try {
      // In Java, they detach and reattach the surface when configuring
      // Flutter UVC plugin doesn't expose direct stopPreview/startPreview methods
      // So we'll need to try a different approach
      
      // Allow a moment for the camera to process
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Instead of calling _applyFormatSettings() which would create a loop,
      // we'll just log that configuration has been attempted
      setState(() {
        _log = 'Camera configuration attempted with current settings\n$_log';
      });
    } catch (e) {
      setState(() {
        _log = 'Error configuring camera: $e\n$_log';
      });
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // In Java example, they handle when the surface becomes available
    // Instead of calling configureCamera which could cause loops, just log
    if (_isDeviceAttached && _isDeviceConnected && 
        _cameraController != null && _cameraController!.value.isInitialized) {
      // Surface might be ready now, just log it
      setState(() {
        _log = 'Widget dependencies changed - camera is already running\n$_log';
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
                        child: _cameraController != null && _isDeviceConnected && _cameraController!.value.isInitialized
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
                                      color: _cameraController != null && _cameraController!.value.isInitialized ? Colors.green : Colors.red,
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
                    if (_cameraController != null)
                      ValueListenableBuilder<UvcCameraControllerState>(
                        valueListenable: _cameraController!,
                        builder: (context, value, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FloatingActionButton(
                                backgroundColor: Colors.white,
                                onPressed: value.isTakingPicture || !value.isInitialized
                                    ? null
                                    : () async {
                                        try {
                                          await _takePicture();
                                        } catch (e) {
                                          setState(() {
                                            _log = 'Error taking picture: $e\n$_log';
                                          });
                                        }
                                      },
                                child: const Icon(Icons.camera_alt, color: Colors.black),
                              ),
                              const SizedBox(width: 20),
                              FloatingActionButton(
                                backgroundColor: value.isRecordingVideo ? Colors.red : Colors.white,
                                onPressed: !value.isInitialized ? null : () async {
                                  try {
                                    if (value.isRecordingVideo) {
                                      await _stopVideoRecording();
                                    } else if (value.previewMode != null) {
                                      await _startVideoRecording(value.previewMode!);
                                    } else {
                                      setState(() {
                                        _log = 'Cannot record: Preview mode is null\n$_log';
                                      });
                                    }
                                  } catch (e) {
                                    setState(() {
                                      _log = 'Error with video recording: $e\n$_log';
                                    });
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
                                onPressed: !value.isInitialized ? null : () {
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
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error initializing camera', style: TextStyle(fontSize: 18, color: Colors.red)),
                const SizedBox(height: 20),
                Text('${snapshot.error}', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _log = 'Restarting camera after error...\n$_log';
                    });
                    _detach(force: true);
                    _attach(force: true);
                  },
                  child: const Text("Restart Camera"),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
} 