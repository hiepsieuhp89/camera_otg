import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences.provider.dart';

part 'app_start_up.provider.g.dart';

@Riverpod(keepAlive: true)
Future<void> appStartup(AppStartupRef ref) async {
  ref.onDispose(() {
    ref.invalidate(sharedPreferencesProvider);
  });
  await ref.watch(sharedPreferencesProvider.future);
}
