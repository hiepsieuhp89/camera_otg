import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Use lazy initialization for Firebase
  FirebaseFirestore? _firestore;
  final String _logCollection = 'camera_logs';
  final String _logFilename = 'camera_log.txt';
  String? _deviceId;
  bool _firebaseAvailable = false;

  // Initialize with device identifier
  Future<void> initialize() async {
    try {
      final deviceInfo = await getDeviceInfo();
      _deviceId = deviceInfo;
      
      // Don't try to access Firebase yet, just initialize local logging
      await _logToFile('[${_getCurrentTimestamp()}][INFO] Logger initialized');
      debugPrint('Logger initialized');
    } catch (e) {
      debugPrint('Failed to initialize logger: $e');
    }
  }

  // Enable Firebase logging once Firebase is initialized
  Future<void> enableFirebaseLogging() async {
    try {
      _firestore = FirebaseFirestore.instance;
      _firebaseAvailable = true;
      await _logToFirebase('Firebase logging enabled', 'INFO', DateTime.now());
      debugPrint('Firebase logging enabled');
    } catch (e) {
      _firebaseAvailable = false;
      debugPrint('Failed to enable Firebase logging: $e');
    }
  }

  String _getCurrentTimestamp() {
    final timestamp = DateTime.now();
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);
  }

  // Get device information for identification
  Future<String> getDeviceInfo() async {
    try {
      final deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      return deviceId;
    } catch (e) {
      return 'unknown-device';
    }
  }

  // Log to both Firebase and local file
  Future<void> _log(String message, String level) async {
    final timestamp = DateTime.now();
    final formattedTime = _getCurrentTimestamp();
    final logEntry = '[$formattedTime][$level] $message';
    
    debugPrint(logEntry);
    
    // Log to file first (more reliable)
    await _logToFile(logEntry);
    
    // Only log to Firebase if it's available
    if (_firebaseAvailable && _firestore != null) {
      await _logToFirebase(message, level, timestamp);
    }
  }

  // Write to local log file
  Future<void> _logToFile(String logEntry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFilename');
      
      // Append to file
      await file.writeAsString('$logEntry\n', mode: FileMode.append);
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  // Log to Firebase
  Future<void> _logToFirebase(String message, String level, DateTime timestamp) async {
    try {
      if (_firestore != null) {
        await _firestore!.collection(_logCollection).add({
          'deviceId': _deviceId ?? 'unknown',
          'message': message,
          'level': level,
          'timestamp': timestamp,
        });
      }
    } catch (e) {
      debugPrint('Failed to log to Firebase: $e');
    }
  }

  // Public logging methods
  Future<void> info(String message) async => await _log(message, 'INFO');
  Future<void> debug(String message) async => await _log(message, 'DEBUG');
  Future<void> warning(String message) async => await _log(message, 'WARNING');
  Future<void> error(String message) async => await _log(message, 'ERROR');

  // Get the log file path
  Future<String> getLogFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_logFilename';
  }

  // Clear local log file
  Future<void> clearLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_logFilename');
      
      if (await file.exists()) {
        await file.delete();
      }
      
      await _log('Log file cleared', 'INFO');
    } catch (e) {
      debugPrint('Failed to clear log file: $e');
    }
  }
} 