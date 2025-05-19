import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lavie/src/core/utils/vibration_handler.dart';
import 'package:lavie/src/features/auth/data/auth_service.dart';
import 'package:lavie/src/features/broadcast/data/webrtc_connection_service.dart';
import 'package:lavie/src/routes/app_router.dart';
import 'package:lavie/src/theme/app_theme.dart';
import 'package:vibration/vibration.dart';
import 'package:lavie/src/core/constants/ui_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@RoutePage()
class ViewerScreen extends ConsumerStatefulWidget {
  const ViewerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  final _remoteRenderer = RTCVideoRenderer();
  bool _isInitialized = false;
  bool _isConnected = false;
  bool _isVibrating = false;
  String? _selectedBroadcasterId;
  String? _selectedBroadcasterName;
  List<Map<String, dynamic>> _activeBroadcasters = [];
  late WebRTCConnectionService _webRTCService;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _webRTCService.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _remoteRenderer.initialize();
      
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        debugPrint('Error: No user logged in');
        return;
      }
      
      // Initialize WebRTC service
      _webRTCService = WebRTCConnectionService(
        userId: currentUser.id,
        isBroadcaster: false,
      );
      
      // Setup callback for receiving remote stream
      _webRTCService.onRemoteStreamAvailable = (stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {
          _isConnected = true;
        });
      };
      
      // Setup callback for connection state changes
      _webRTCService.onConnectionStateChange = (state) {
        debugPrint('WebRTC connection state changed: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected || 
            state == RTCPeerConnectionState.RTCPeerConnectionStateFailed || 
            state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          setState(() {
            _isConnected = false;
          });
        }
      };
      
      // Setup callback for active broadcasters
      _webRTCService.onAvailableStreamsChanged = (broadcasters) {
        setState(() {
          _activeBroadcasters = broadcasters;
        });
      };
      
      // Start listening for active broadcasters
      _webRTCService.listenForActiveStreams();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing viewer screen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing viewer: $e')),
      );
    }
  }

  Future<void> _connectToBroadcaster(String broadcasterId, String broadcasterName) async {
    if (_isConnected) {
      await _disconnectFromBroadcaster();
    }
    
    setState(() {
      _selectedBroadcasterId = broadcasterId;
      _selectedBroadcasterName = broadcasterName;
    });
    
    try {
      await _webRTCService.startViewing(broadcasterId);
      // The connection will be established asynchronously and onRemoteStreamReceived will be called
    } catch (e) {
      debugPrint('Error connecting to broadcaster: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to broadcast: $e')),
      );
    }
  }
  
  Future<void> _disconnectFromBroadcaster() async {
    if (_isConnected) {
      await _webRTCService.stopViewing();
      _remoteRenderer.srcObject = null;
      setState(() {
        _isConnected = false;
        _selectedBroadcasterId = null;
        _selectedBroadcasterName = null;
      });
    }
  }

  Future<void> _sendVibration(int pattern) async {
    if (_selectedBroadcasterId == null) return;
    
    setState(() {
      _isVibrating = true;
    });
    
    try {
      await _webRTCService.sendVibrationToBroadcaster(
        _selectedBroadcasterId!,
        pattern,
      );
    } catch (e) {
      debugPrint('Error sending vibration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending vibration: $e')),
      );
    } finally {
      setState(() {
        _isVibrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xem trực tiếp'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: Icon(Icons.call_end),
              onPressed: _disconnectFromBroadcaster,
            ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : _isConnected
              ? _buildConnectedView()
              : _buildBroadcastersList(),
    );
  }
  
  Widget _buildBroadcastersList() {
    if (_activeBroadcasters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có phát trực tiếp nào đang hoạt động',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('Làm mới'),
              onPressed: () => _webRTCService.listenForActiveStreams(),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _activeBroadcasters.length,
      itemBuilder: (context, index) {
        final broadcaster = _activeBroadcasters[index];
        final id = broadcaster['broadcasterId'] as String;
        final name = broadcaster['broadcasterName'] as String? ?? 'Broadcaster';
        final timestamp = broadcaster['timestamp'] as Timestamp?;
        final startTime = timestamp?.toDate() ?? DateTime.now();
        
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.videocam),
            ),
            title: Text(name),
            subtitle: Text('Live since ${_formatDateTime(startTime)}'),
            trailing: ElevatedButton(
              child: Text('Xem'),
              onPressed: () => _connectToBroadcaster(id, name),
            ),
          ),
        );
      },
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} phút';
    } else {
      return '${duration.inHours} giờ ${duration.inMinutes % 60} phút';
    }
  }

  Widget _buildConnectedView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.black,
            child: RTCVideoView(
              _remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
        ),
        if (_selectedBroadcasterName != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Đang xem: $_selectedBroadcasterName',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildVibrationButton(
                icon: Icons.vibration,
                label: 'Nhẹ',
                pattern: 1,
              ),
              _buildVibrationButton(
                icon: Icons.tap_and_play,
                label: 'Mạnh',
                pattern: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVibrationButton({
    required IconData icon,
    required String label,
    required int pattern,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: _isVibrating ? null : () => _sendVibration(pattern),
    );
  }
}
