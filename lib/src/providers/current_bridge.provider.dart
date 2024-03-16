import 'package:kyoryo/src/models/bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_bridge.provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentBridge extends _$CurrentBridge {
  @override
  Bridge? build() => null;

  void set(Bridge? bridge) {
    state = bridge;
  }
}
