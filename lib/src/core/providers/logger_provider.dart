import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lavie/src/core/utils/logger_service.dart';

final loggerProvider = Provider<LoggerService>((ref) {
  final logger = LoggerService();
  return logger;
}); 