import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bridges.provider.g.dart';

@riverpod
class Bridges extends _$Bridges {
  @override
  Future<List<Bridge>> build() async {
    return ref.watch(bridgeServiceProvider).fetchBridges();
  }
}
