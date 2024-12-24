import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/providers/app_update.provider.dart';
import 'package:kyoryo/src/providers/install_permission.provider.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

@RoutePage()
class AppUpdateScreen extends ConsumerStatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => AppUpdateScreenState();
}

class AppUpdateScreenState extends ConsumerState<AppUpdateScreen> {
  int received = 0;
  int total = 0;
  bool fileDownloaded = false;
  String filePath = '';

  void downloadAndUpdate() async {
    final appUpdate = ref.read(appUpdateProvider);
    final tempDir = await getTemporaryDirectory();

    if (!appUpdate.shoudUpdate) {
      return;
    }

    setState(() {
      filePath =
          '${tempDir.path}/smartbuddy_${appUpdate.latestVersion!.version}.apk';
    });

    if (!fileDownloaded) {
      Dio client = Dio();

      await client.download(appUpdate.latestVersion!.downloadUrl, filePath,
          onReceiveProgress: (r, t) {
        setState(() {
          received = r;
          total = t;
        });
      });

      setState(() {
        fileDownloaded = true;
      });
    }

    final hasPermission = await ref
        .read(installPermissionProvider.notifier)
        .hasInstallPermission();

    if (!hasPermission) {
      final permission = await ref
          .read(installPermissionProvider.notifier)
          .requestInstallPermission();

      if (permission != PermissionStatus.granted) {
        showInstallPermissionRequiredMessage();

        return;
      }
    }

    await OpenFile.open(filePath);
  }

  void showInstallPermissionRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            AppLocalizations.of(context)!.appUpdateInstallPermissionRequired),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appUpdate = ref.watch(appUpdateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.appUpdateMessage),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appUpdate),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)!.appUpdateTitle,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!
                              .currentVersion(appUpdate.currentVersion ?? '')),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.updateVersion(
                                appUpdate.latestVersion?.version ?? ''),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (total > 0)
                      LinearProgressIndicator(
                        value: received / total,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: (!fileDownloaded && total != 0)
                          ? null
                          : downloadAndUpdate,
                      icon: const Icon(Icons.download),
                      label: Text(AppLocalizations.of(context)!.install),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
