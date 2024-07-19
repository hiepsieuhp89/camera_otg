import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/providers/authentication.provider.dart';
import 'package:kyoryo/src/providers/bridges.provider.dart';
import 'package:kyoryo/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/ui/bridge_list_item.dart';

@RoutePage()
class BridgeListScreen extends ConsumerWidget {
  const BridgeListScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final municipality = ref.watch(currentMunicipalityProvider);
    final bridges = ref.watch(bridgesProvider);

    Widget buildProfileIndicator() {
      final user = ref.watch(authenticationProvider).user;

      return MenuAnchor(
          builder: (context, controller, child) {
            return GestureDetector(
              onTap: () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
              child: CircleAvatar(
                  radius: 15,
                  child: user?.picture != null
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          child: CachedNetworkImage(
                            imageUrl: user!.picture,
                            width: 30,
                            height: 30,
                          ),
                        )
                      : Text(
                          user!.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )),
            );
          },
          menuChildren: [
            MenuItemButton(
                onPressed: () {
                  ref.read(authenticationProvider.notifier).logout().then((_) {
                    context.pushRoute(const LoginRoute());
                  });
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(AppLocalizations.of(context)!.logoutButton)
                  ],
                ))
          ]);
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.bridgeListTitle),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: Text(municipality?.nameKanji ?? ''),
              onPressed: () {
                context.pushRoute(const BridgeFiltersRoute());
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: buildProfileIndicator(),
            )
          ],
        ),
        body: bridges.when(
            data: (data) => RefreshIndicator(
                onRefresh: () => ref.refresh(bridgesProvider.future),
                child: _bridgeList(data)),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
            error: (error, stackTrace) {
              debugPrint('Error: $error, stack: $stackTrace');

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppLocalizations.of(context)!.unableToLoadBridges),
                    IconButton(
                      onPressed: () => ref.invalidate(bridgesProvider),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              );
            }));
  }

  ListView _bridgeList(List<Bridge> bridges) {
    return ListView.builder(
      restorationId: 'bridgeListView',
      itemCount: bridges.length,
      itemBuilder: (BuildContext context, int index) {
        final bridge = bridges[index];

        return BridgeListItem(bridge: bridge);
      },
    );
  }
}
