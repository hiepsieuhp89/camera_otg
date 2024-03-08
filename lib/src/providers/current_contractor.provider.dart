import 'package:kyoryo/src/models/contractor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_contractor.provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentContractor extends _$CurrentContractor {
  @override
  Contractor? build() => null;

  void set(Contractor? contractor) {
    state = contractor;
  }
}
