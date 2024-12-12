import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/providers/update.provider.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestInstallPermission() async {
  if (Platform.isAndroid) {
    if (!await Permission.requestInstallPackages.isGranted) {
      final status = await Permission.requestInstallPackages.request();
      if (!status.isGranted) {
        throw Exception('Permission to install packages is not granted.');
      }
    }
  }
}

class UpdateService {
  final log = Logger('UpdateService');
  final String currentVersion = dotenv.env['CURRENT_VERSION'] ?? '';
  final String buildEnv = dotenv.env['BUILD_ENV'] ?? 'dev';
  
  Future<void> checkAndUpdateApp(WidgetRef ref) async {
    String? fileUrl = '';
    String? newVersion = '';
    try {
      
      final updateResponse = ref.watch(updateApkProvider).when(
        data: (data) => data,
        loading: () {
          throw Exception("Still loading...");
        },
        error: (err, stack) {
          throw Exception("Failed to fetch update details: $err");
        },
      );
     

      if (buildEnv == 'dev') {
        fileUrl = updateResponse.dev?.fileName;
        newVersion = updateResponse.dev?.version;
      } else if (buildEnv == 'stg') {
        fileUrl = updateResponse.stg?.fileName;
        newVersion = updateResponse.stg?.version;
      }
      if (newVersion == currentVersion) {
        return;
      }
      if (fileUrl == '' || fileUrl!.isEmpty) {
        throw Exception("No file URL available for download.");
      }

      await requestInstallPermission();
      final tempDir = await getTemporaryDirectory();
      final apkPath = '${tempDir.path}/app_update.apk';

      Dio dio = Dio();
      await dio.download(fileUrl, apkPath, onReceiveProgress: (received, total) {
      });
      
      final apkFile = File(apkPath);
      if (!apkFile.existsSync()) {
        throw Exception("Failed to download APK.");
      }
      final result = await OpenFile.open(apkPath);

      if (result.type == ResultType.done) {
        log.info('App update initiated successfully.');
      } else {
        log.severe('Failed to initiate app update: ${result.message}');
        throw Exception('Failed to initiate app update.');
      }
    } catch (e, stack) {
      log.severe('Error during app update process: $e', e, stack);
      rethrow; // Re-throw the exception after logging
    }
  }
}