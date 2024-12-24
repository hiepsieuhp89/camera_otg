import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:kyoryo/src/providers/shared_preferences.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.provider.g.dart';

@Riverpod(keepAlive: true)
Raw<KyoryoAppRouter> appRouter(Ref ref) {
  return KyoryoAppRouter(ref.watch(apiServiceProvider),
      ref.watch(sharedPreferencesProvider).requireValue);
}
