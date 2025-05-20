import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

enum PeerConnectionType {
  broadcaster,
  viewer
}

class WebRTCService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  RTCVideoRenderer? _localRenderer;
  RTCVideoRenderer? _remoteRenderer;
  bool _isInitialized = false;
  String? _currentDeviceId;
  PeerConnectionType? _connectionType;
  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _iceCandidatesSubscription;
  
  Future<RTCVideoRenderer> get localRenderer async {
    if (_localRenderer == null) {
      _localRenderer = RTCVideoRenderer();
      await _localRenderer!.initialize();
    }
    return _localRenderer!;
  }
  
  Future<RTCVideoRenderer> get remoteRenderer async {
    if (_remoteRenderer == null) {
      _remoteRenderer = RTCVideoRenderer();
      await _remoteRenderer!.initialize();
    }
    return _remoteRenderer!;
  }
  
  bool get isInitialized => _isInitialized;
  bool get isConnected => _peerConnection != null && _isInitialized;
  
  // Initialize WebRTC for broadcaster
  Future<void> initializeBroadcaster(String deviceId) async {
    if (_isInitialized) {
      await dispose();
    }
    
    _currentDeviceId = deviceId;
    _connectionType = PeerConnectionType.broadcaster;
    
    // Create peer connection
    await _createPeerConnection();
    
    // Get user media (camera access)
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    });
    
    // Add tracks to peer connection
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
    
    // Set local stream to renderer
    (await localRenderer).srcObject = _localStream;
    
    // Listen for viewers connecting
    _listenForAnswers();
    
    _isInitialized = true;
  }
  
  // Initialize WebRTC for viewer
  Future<void> initializeViewer(String deviceId) async {
    if (_isInitialized) {
      await dispose();
    }
    
    _currentDeviceId = deviceId;
    _connectionType = PeerConnectionType.viewer;
    
    // Create peer connection
    await _createPeerConnection();
    
    // Listen for broadcaster offers
    _listenForOffers();
    
    _isInitialized = true;
  }
  
  Future<void> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ]
    };
    
    _peerConnection = await createPeerConnection(configuration);
    
    // Set up event handlers
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _addIceCandidate(candidate);
    };
    
    _peerConnection!.onAddStream = (MediaStream stream) {
      _handleRemoteStream(stream);
    };
    
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };
  }
  
  // Create and publish offer (broadcaster)
  Future<void> createAndPublishOffer() async {
    if (_peerConnection == null || _connectionType != PeerConnectionType.broadcaster) {
      throw Exception('Cannot create offer: not initialized as broadcaster');
    }
    
    try {
      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': false,
        'offerToReceiveVideo': false
      });
      
      await _peerConnection!.setLocalDescription(offer);
      
      // Format offer for Firebase
      final offerMap = parse(offer.sdp!);
      final offerJson = jsonEncode(offerMap);
      
      // Save offer to Firestore
      await _firestore
          .collection('devices')
          .doc(_currentDeviceId)
          .collection('webrtc')
          .doc('offer')
          .set({
            'type': offer.type,
            'sdp': offerJson,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
      print('Offer created and published');
    } catch (e) {
      print('Error creating offer: $e');
      throw Exception('Failed to create offer: $e');
    }
  }
  
  // Listen for offers (viewer)
  void _listenForOffers() {
    _offerSubscription?.cancel();
    
    _offerSubscription = _firestore
        .collection('devices')
        .doc(_currentDeviceId)
        .collection('webrtc')
        .doc('offer')
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists) return;
          
          try {
            final data = snapshot.data() as Map<String, dynamic>;
            final sdpMap = jsonDecode(data['sdp']);
            final sdp = write(sdpMap, null);
            
            final offer = RTCSessionDescription(sdp, data['type']);
            
            await _peerConnection!.setRemoteDescription(offer);
            await _createAndPublishAnswer();
            
            // Start listening for ICE candidates
            _listenForIceCandidates();
          } catch (e) {
            print('Error processing offer: $e');
          }
        });
  }
  
  // Create and publish answer (viewer)
  Future<void> _createAndPublishAnswer() async {
    if (_peerConnection == null || _connectionType != PeerConnectionType.viewer) {
      throw Exception('Cannot create answer: not initialized as viewer');
    }
    
    try {
      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      // Format answer for Firebase
      final answerMap = parse(answer.sdp!);
      final answerJson = jsonEncode(answerMap);
      
      // Save answer to Firestore
      await _firestore
          .collection('devices')
          .doc(_currentDeviceId)
          .collection('webrtc')
          .doc('answer')
          .set({
            'type': answer.type,
            'sdp': answerJson,
            'timestamp': FieldValue.serverTimestamp(),
          });
          
      print('Answer created and published');
    } catch (e) {
      print('Error creating answer: $e');
      throw Exception('Failed to create answer: $e');
    }
  }
  
  // Listen for answers (broadcaster)
  void _listenForAnswers() {
    _answerSubscription?.cancel();
    
    _answerSubscription = _firestore
        .collection('devices')
        .doc(_currentDeviceId)
        .collection('webrtc')
        .doc('answer')
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists) return;
          
          try {
            final data = snapshot.data() as Map<String, dynamic>;
            final sdpMap = jsonDecode(data['sdp']);
            final sdp = write(sdpMap, null);
            
            final answer = RTCSessionDescription(sdp, data['type']);
            
            await _peerConnection!.setRemoteDescription(answer);
            
            // Start listening for ICE candidates
            _listenForIceCandidates();
          } catch (e) {
            print('Error processing answer: $e');
          }
        });
  }
  
  // Add ICE candidate to peer connection
  Future<void> _addIceCandidate(RTCIceCandidate candidate) async {
    if (_peerConnection == null) return;
    
    try {
      // Save candidate to Firestore
      await _firestore
          .collection('devices')
          .doc(_currentDeviceId)
          .collection('webrtc')
          .doc(_connectionType == PeerConnectionType.broadcaster ? 'broadcasterCandidates' : 'viewerCandidates')
          .collection('candidates')
          .add({
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error adding ICE candidate: $e');
    }
  }
  
  // Listen for ICE candidates
  void _listenForIceCandidates() {
    _iceCandidatesSubscription?.cancel();
    
    final candidatesDoc = _connectionType == PeerConnectionType.broadcaster
        ? 'viewerCandidates'
        : 'broadcasterCandidates';
    
    _iceCandidatesSubscription = _firestore
        .collection('devices')
        .doc(_currentDeviceId)
        .collection('webrtc')
        .doc(candidatesDoc)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) async {
          for (var doc in snapshot.docChanges) {
            if (doc.type == DocumentChangeType.added) {
              try {
                final data = doc.doc.data() as Map<String, dynamic>;
                final candidate = RTCIceCandidate(
                  data['candidate'],
                  data['sdpMid'],
                  data['sdpMLineIndex'],
                );
                
                await _peerConnection!.addCandidate(candidate);
              } catch (e) {
                print('Error processing ICE candidate: $e');
              }
            }
          }
        });
  }
  
  // Handle remote stream
  void _handleRemoteStream(MediaStream stream) async {
    print('Got remote stream');
    (await remoteRenderer).srcObject = stream;
  }
  
  // Dispose resources
  Future<void> dispose() async {
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _iceCandidatesSubscription?.cancel();
    
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _peerConnection?.close();
    
    _localRenderer?.dispose();
    _remoteRenderer?.dispose();
    
    _localStream = null;
    _peerConnection = null;
    _localRenderer = null;
    _remoteRenderer = null;
    _isInitialized = false;
    _currentDeviceId = null;
    _connectionType = null;
  }
}

// WebRTC service provider
final webRTCServiceProvider = Provider<WebRTCService>((ref) {
  return WebRTCService();
}); 