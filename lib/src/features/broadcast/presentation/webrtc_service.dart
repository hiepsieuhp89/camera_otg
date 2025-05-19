import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRTCService {
  final String userId;
  final String? pairedUserId;
  final bool isBroadcaster;
  
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _offerSubscription;
  StreamSubscription? _answerSubscription;
  StreamSubscription? _iceCandidatesSubscription;
  
  Function(String)? onConnectionStateChange;

  WebRTCService({
    required this.userId,
    this.pairedUserId,
    required this.isBroadcaster,
  });

  Future<void> startBroadcast(RTCVideoRenderer localRenderer) async {
    if (pairedUserId == null) {
      throw Exception('Not paired with any device');
    }

    await _initPeerConnection();
    
    // Create local stream
    final Map<String, dynamic> mediaConstraints = {
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
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    localRenderer.srcObject = _localStream;
    
    // Add tracks to peer connection
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // Create and send offer
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    
    await _firestore.collection('webrtc').doc(pairedUserId).set({
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      },
      'fromUserId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Listen for answer
    _answerSubscription = _firestore
        .collection('webrtc')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['answer'] != null) {
        final answer = RTCSessionDescription(
          snapshot.data()!['answer']['sdp'],
          snapshot.data()!['answer']['type'],
        );
        
        await _peerConnection!.setRemoteDescription(answer);
      }
    });

    // Listen for ICE candidates
    _iceCandidatesSubscription = _firestore
        .collection('webrtc')
        .doc(userId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            final candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );
            _peerConnection!.addCandidate(candidate);
          }
        }
      });
    });
  }

  Future<void> startViewing(RTCVideoRenderer remoteRenderer) async {
    if (pairedUserId == null) {
      throw Exception('Not paired with any device');
    }

    await _initPeerConnection();
    
    // Listen for offer
    _offerSubscription = _firestore
        .collection('webrtc')
        .doc(userId)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.exists && snapshot.data()?['offer'] != null) {
        final offer = RTCSessionDescription(
          snapshot.data()!['offer']['sdp'],
          snapshot.data()!['offer']['type'],
        );
        
        await _peerConnection!.setRemoteDescription(offer);
        
        // Create and send answer
        RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        
        await _firestore.collection('webrtc').doc(pairedUserId).set({
          'answer': {
            'type': answer.type,
            'sdp': answer.sdp,
          },
          'fromUserId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });

    // Set remote stream to renderer
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Listen for ICE candidates
    _iceCandidatesSubscription = _firestore
        .collection('webrtc')
        .doc(userId)
        .collection('candidates')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            final candidate = RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            );
            _peerConnection!.addCandidate(candidate);
          }
        }
      });
    });
  }

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
      if (pairedUserId != null) {
        await _firestore
            .collection('webrtc')
            .doc(pairedUserId)
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
      if (onConnectionStateChange != null) {
        onConnectionStateChange!(state.toString().split('.')[1]);
      }
    };
  }

  Future<void> stopBroadcast() async {
    await _localStream?.dispose();
    _localStream = null;
    await _cleanup();
  }

  Future<void> stopViewing() async {
    await _cleanup();
  }

  Future<void> _cleanup() async {
    _offerSubscription?.cancel();
    _answerSubscription?.cancel();
    _iceCandidatesSubscription?.cancel();
    
    await _peerConnection?.close();
    _peerConnection = null;
    
    if (pairedUserId != null) {
      try {
        await _firestore.collection('webrtc').doc(pairedUserId).delete();
        await _firestore.collection('webrtc').doc(userId).delete();
        
        // Delete ICE candidates
        final candidatesDocs = await _firestore
            .collection('webrtc')
            .doc(pairedUserId)
            .collection('candidates')
            .get();
        
        for (var doc in candidatesDocs.docs) {
          await doc.reference.delete();
        }
        
        final myCandidatesDocs = await _firestore
            .collection('webrtc')
            .doc(userId)
            .collection('candidates')
            .get();
        
        for (var doc in myCandidatesDocs.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        print('Error cleaning up WebRTC data: $e');
      }
    }
  }

  void dispose() {
    stopBroadcast();
    stopViewing();
  }
}
