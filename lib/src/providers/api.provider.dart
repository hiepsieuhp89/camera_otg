import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/services/api.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api.provider.g.dart';

@Riverpod(keepAlive: true)
ApiService apiService(Ref ref) => ApiService();
