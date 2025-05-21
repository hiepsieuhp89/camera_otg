import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:vibration/vibration.dart';

/// Service to manage WebRTC connections for video streaming
class WebRTCConnectionService {
  final String userId;
  final String? pairedUserId;
  final bool isBroadcaster;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _iceCandidatesSubscription;
  StreamSubscription? _activeStreamsSubscription;
  
  /// Connection state change callback
  Function(RTCPeerConnectionState)? onConnectionStateChange;
  
  /// Remote stream available callback
  Function(MediaStream)? onRemoteStreamAvailable;
  
  /// Available streams callback
  Function(List<Map<String, dynamic>>)? onAvailableStreamsChanged;

  WebRTCConnectionService({
    required this.userId,
    this.pairedUserId,
    required this.isBroadcaster,
  }) {
    debugPrint('WebRTCConnectionService initialized:');
    debugPrint(' - User ID: $userId');
    debugPrint(' - Is Broadcaster: $isBroadcaster');
    
    if (userId.isEmpty) {
      debugPrint('WARNING: User ID is empty');
    }
  }

  /// Start broadcasting from the broadcaster device
  Future<void> startBroadcast(MediaStream localStream, String broadcasterName) async {
    debugPrint('Starting broadcast as $broadcasterName...');

    _localStream = localStream;
    debugPrint('Initializing peer connection...');
    await _initPeerConnection();
    
    debugPrint('Adding media tracks to peer connection...');
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    debugPrint('Creating WebRTC offer...');
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    
    debugPrint('Registering broadcast in active streams...');
    await _firestore.collection('activeStreams').doc(userId).set({
      'broadcasterName': broadcasterName,
      'broadcasterId': userId,
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      },
      'timestamp': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    debugPrint('Listening for answers from viewers...');
    _answerSubscription = _firestore
        .collection('broadcasters')
        .doc(userId)
        .collection('answers')
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            debugPrint('Answer received from viewer: ${data['viewerId']}');
            final answer = RTCSessionDescription(
              data['answer']['sdp'],
              data['answer']['type'],
            );
            
            await _peerConnection!.setRemoteDescription(answer);
            debugPrint('Remote description set');
          }
        }
      }
    });

    debugPrint('Listening for ICE candidates...');
    _listenForIceCandidates();
    debugPrint('Broadcast setup complete');
  }

  /// Get list of active broadcasts
  Future<List<Map<String, dynamic>>> getActiveStreams() async {
    debugPrint('Getting active streams...');
    
    final snapshot = await _firestore
        .collection('activeStreams')
        .where('isActive', isEqualTo: true)
        .get();
    
    final streams = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'broadcasterId': data['broadcasterId'],
        'broadcasterName': data['broadcasterName'],
        'timestamp': data['timestamp'],
      };
    }).toList();
    
    debugPrint('Found ${streams.length} active streams');
    return streams;
  }

  /// Listen for active broadcasts changes
  void listenForActiveStreams() {
    debugPrint('Starting to listen for active streams...');
    
    _activeStreamsSubscription = _firestore
        .collection('activeStreams')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      final streams = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'broadcasterId': data['broadcasterId'],
          'broadcasterName': data['broadcasterName'],
          'timestamp': data['timestamp'],
        };
      }).toList();
      
      debugPrint('Active streams updated, count: ${streams.length}');
      if (onAvailableStreamsChanged != null) {
        onAvailableStreamsChanged!(streams);
      }
    });
  }

  /// Start viewing a specific broadcaster's stream
  Future<void> startViewing(String broadcasterId) async {
    debugPrint('Starting to view broadcast from: $broadcasterId');

    try {
      await _cleanup();
      
      final broadcasterDoc = await _firestore.collection('activeStreams').doc(broadcasterId).get();
      if (!broadcasterDoc.exists) {
        debugPrint('Error: Broadcast not found');
        throw Exception('Broadcast not found');
      }
      
      final broadcastData = broadcasterDoc.data();
      if (broadcastData == null || !broadcastData['isActive']) {
        debugPrint('Error: Broadcast is not active');
        throw Exception('Broadcast is not active');
      }

      debugPrint('Initializing peer connection...');
      await _initPeerConnection();
      
      debugPrint('Setting up remote stream handler...');
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          debugPrint('Remote stream received from broadcaster');
          if (onRemoteStreamAvailable != null) {
            onRemoteStreamAvailable!(event.streams[0]);
          }
        }
      };
      
      final offer = RTCSessionDescription(
        broadcastData['offer']['sdp'],
        broadcastData['offer']['type'],
      );
      
      debugPrint('Setting remote description (broadcaster offer)...');
      await _peerConnection!.setRemoteDescription(offer);
      
      debugPrint('Creating answer...');
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      
      debugPrint('Setting local description...');
      await _peerConnection!.setLocalDescription(answer);
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      debugPrint('Sending answer to broadcaster: $broadcasterId');
      await _firestore
          .collection('broadcasters')
          .doc(broadcasterId)
          .collection('answers')
          .doc(userId)
          .set({
        'viewerId': userId, 
        'answer': {
          'type': answer.type,
          'sdp': answer.sdp,
        },
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('Listening for ICE candidates...');
      _listenForIceCandidates(broadcasterId);
      debugPrint('Viewing setup complete');
    } catch (e) {
      debugPrint('Error in startViewing: $e');
      await _cleanup();
      throw Exception('Unable to connect to broadcast: $e');
    }
  }

  /// Initialize the peer connection
  Future<void> _initPeerConnection() async {
    final Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'sdpSemantics': 'unified-plan'
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
      if (isBroadcaster) {
        await _firestore
            .collection('broadcasters')
            .doc(userId)
            .collection('candidates')
            .add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else if (pairedUserId != null && pairedUserId!.isNotEmpty) {
        await _firestore
            .collection('broadcasters')
            .doc(pairedUserId)
            .collection('viewerCandidates')
            .doc(userId)
            .collection('candidates')
            .add({
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    };

    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('WebRTC connection state changed: ${state.toString()}');
      if (onConnectionStateChange != null) {
        onConnectionStateChange!(state);
      }
    };
  }

  /// Listen for ICE candidates
  void _listenForIceCandidates([String? targetBroadcasterId]) {
    if (isBroadcaster) {
      _iceCandidatesSubscription = _firestore
          .collection('broadcasters')
          .doc(userId)
          .collection('viewerCandidates')
          .snapshots()
          .listen((viewersSnapshot) {
        for (final viewerDoc in viewersSnapshot.docs) {
          final viewerId = viewerDoc.id;
          _firestore
              .collection('broadcasters')
              .doc(userId)
              .collection('viewerCandidates')
              .doc(viewerId)
              .collection('candidates')
              .snapshots()
              .listen((candidatesSnapshot) {
            for (final change in candidatesSnapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data();
                if (data != null && _peerConnection != null) {
                  final candidate = RTCIceCandidate(
                    data['candidate'],
                    data['sdpMid'],
                    data['sdpMLineIndex'],
                  );
                  _peerConnection!.addCandidate(candidate);
                }
              }
            }
          });
        }
      });
    } else if (targetBroadcasterId != null) {
      _iceCandidatesSubscription = _firestore
          .collection('broadcasters')
          .doc(targetBroadcasterId)
          .collection('candidates')
          .snapshots()
          .listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data != null && _peerConnection != null) {
              final candidate = RTCIceCandidate(
                data['candidate'],
                data['sdpMid'],
                data['sdpMLineIndex'],
              );
              _peerConnection!.addCandidate(candidate);
            }
          }
        }
      });
    }
  }

  /// Stop broadcasting
  Future<void> stopBroadcast() async {
    if (isBroadcaster) {
      try {
        await _firestore.collection('activeStreams').doc(userId).update({
          'isActive': false,
        });
        debugPrint('Broadcast marked as inactive');
      } catch (e) {
        debugPrint('Error marking broadcast as inactive: $e');
      }
    }
    
    await _localStream?.dispose();
    _localStream = null;
    await _cleanup();
  }

  /// Stop viewing
  Future<void> stopViewing() async {
    await _cleanup();
  }

  /// Clean up resources
  Future<void> _cleanup() async {
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _iceCandidatesSubscription?.cancel();
    _activeStreamsSubscription?.cancel();
    
    await _peerConnection?.close();
    _peerConnection = null;
  }

  /// Send vibration to broadcaster
  Future<void> sendVibrationToBroadcaster(String broadcasterId, int pattern) async {
    debugPrint('Sending vibration pattern $pattern to broadcaster $broadcasterId');
    try {
      await _firestore.collection('vibrations').add({
        'toBroadcasterId': broadcasterId,
        'fromViewerId': userId,
        'pattern': pattern,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Vibration notification sent successfully');
    } catch (e) {
      debugPrint('Error sending vibration: $e');
      throw Exception('Failed to send vibration: $e');
    }
  }
  
  /// Start listening for vibrations (for broadcasters)
  void startListeningForVibrations() {
    if (!isBroadcaster) return;
    
    debugPrint('Starting to listen for vibrations from viewers...');
    
    _firestore
        .collection('vibrations')
        .where('toBroadcasterId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) async {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            debugPrint('Received vibration from viewer: ${data['fromViewerId']}');
            
            try {
              if (data.containsKey('pattern')) {
                final pattern = data['pattern'] as int;
                if (pattern == 1) {
                  await Vibration.vibrate(duration: 300);
                } else if (pattern == 2) {
                  await Vibration.vibrate(pattern: [0, 300, 100, 300]);
                }
              }
              
              await change.doc.reference.delete();
            } catch (e) {
              debugPrint('Error processing vibration: $e');
            }
          }
        }
      }
    });
  }

  /// Dispose resources
  void dispose() {
    if (isBroadcaster) {
      stopBroadcast();
    } else {
      stopViewing();
    }
  }
}

/// Provider for the WebRTC connection service
final webRTCConnectionServiceProvider = Provider.family<WebRTCConnectionService, WebRTCConnectionParams>(
  (ref, params) {
    final service = WebRTCConnectionService(
      userId: params.userId,
      pairedUserId: params.pairedUserId,
      isBroadcaster: params.isBroadcaster,
    );
    
    ref.onDispose(() {
      service.dispose();
    });
    
    return service;
  },
);

/// Parameters for WebRTC connection
class WebRTCConnectionParams {
  final String userId;
  final String? pairedUserId;
  final bool isBroadcaster;
  
  WebRTCConnectionParams({
    required this.userId,
    this.pairedUserId,
    required this.isBroadcaster,
  });
} 