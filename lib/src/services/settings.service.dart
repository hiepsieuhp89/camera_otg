import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/constants/shared_keys.dart';
import 'package:kyoryo/src/providers/shared_preferences.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.service.g.dart';

@Riverpod(keepAlive: true)
SettingsService settingsService(Ref ref) {
  return SettingsService(
    ref.watch(sharedPreferencesProvider).requireValue,
  );
}

class SettingsService {
  final SharedPreferences _sharedPreferences;

  SettingsService(this._sharedPreferences);

  String? getSelectedMunicipalityCode() {
    return _sharedPreferences.getString(SharedKeys.selectedMunicipalityCode);
  }

  String? getSelectedContractorCode() {
    return _sharedPreferences.getString(SharedKeys.selectedContractorCode);
  }

  void updateSelectedMunicipalityCode(String code) {
    _sharedPreferences.setString(SharedKeys.selectedMunicipalityCode, code);
  }

  void updatedSelectedContractorCode(String code) {
    _sharedPreferences.setString(SharedKeys.selectedContractorCode, code);
  }

  bool isSettingsComplete() {
    return getSelectedMunicipalityCode() != null &&
        getSelectedContractorCode() != null;
  }
}
