import 'package:kyoryo_flutter/src/models/municipality.dart';
import 'package:kyoryo_flutter/src/services/municipality.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'municipalities.provider.g.dart';

@riverpod
class Municipalities extends _$Municipalities {
  @override
  Future<List<Municipality>> build() {
    return ref.watch(municipalityServiceProvider).fetchMunicipalities();
  }
}
