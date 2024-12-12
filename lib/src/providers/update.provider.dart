import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kyoryo/src/providers/api.provider.dart';

import '../models/update_response.dart';

part 'update.provider.g.dart';

@riverpod
class UpdateApk extends _$UpdateApk {
  @override
  Future<UpdateResponse> build() async {
    return ref.watch(apiServiceProvider).fetchLatestVersion();
  }
}