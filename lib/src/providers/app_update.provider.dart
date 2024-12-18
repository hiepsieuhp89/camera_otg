import 'package:kyoryo/src/models/version.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'app_update.provider.g.dart';

class AppUpdateState {
  final Version? latestVersion;
  final String? currentVersion = dotenv.env['CURRENT_VERSION'];
  final String? buildEnv = dotenv.env['BUILD_ENV'];

  AppUpdateState({
    this.latestVersion,
  });

  get isOutdated =>
      latestVersion != null &&
      currentVersion != null &&
      int.parse(latestVersion!.version) > int.parse(currentVersion!);

  get shoudUpdate => buildEnv != null && currentVersion != null && isOutdated;

  AppUpdateState copyWith({
    Version? latestVersion,
  }) {
    return AppUpdateState(
      latestVersion: latestVersion ?? this.latestVersion,
    );
  }
}

@Riverpod(keepAlive: true)
class AppUpdate extends _$AppUpdate {
  @override
  AppUpdateState build() {
    return AppUpdateState(
      latestVersion: null,
    );
  }

  Future<void> getLatestVersion() async {
    Version? version;

    final versions = await ref.read(apiServiceProvider).fetchVersions();

    switch (state.buildEnv) {
      case 'dev':
        version = versions.dev;
      case 'stg':
        version = versions.stg;
      default:
        version = null;
    }

    state = state.copyWith(
      latestVersion: version,
    );

    return;
  }
}
