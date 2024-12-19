import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'install_permission.provider.g.dart';

@riverpod
class InstallPermission extends _$InstallPermission {
  @override
  PermissionStatus build() {
    return Platform.isAndroid
        ? PermissionStatus.granted
        : PermissionStatus.restricted;
  }

  Future<PermissionStatus> requestInstallPermission() async {
    final permission = await Permission.requestInstallPackages.request();

    state = permission;

    return permission;
  }

  Future<bool> hasInstallPermission() async {
    return Permission.requestInstallPackages.isGranted;
  }

  Future<PermissionStatus> getInstallPermission() async {
    final status = await Permission.requestInstallPackages.status;

    state = status;

    return status;
  }
}
