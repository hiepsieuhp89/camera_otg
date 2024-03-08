import 'package:kyoryo/src/models/municipality.dart';
import 'package:kyoryo/src/services/misc.service.dart';
import 'package:kyoryo/src/services/settings.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_municipalitiy.provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentMunicipality extends _$CurrentMunicipality {
  @override
  Municipality? build() => null;

  void set(Municipality? municipality) {
    state = municipality;
  }

  Future<void> fetch() async {
    final code =
        ref.watch(settingsServiceProvider).getSelectedMunicipalityCode();

    if (code == null) {
      return set(null);
    }

    final municipality =
        await ref.watch(miscServiceProvider).getMunicipalityByCode(code);

    set(municipality);
  }
}
