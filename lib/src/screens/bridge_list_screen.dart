import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/providers/bridges.provider.dart';
import 'package:kyoryo/src/providers/current_municipalitiy.provider.dart';
import 'package:kyoryo/src/screens/bridge_filters_screen.dart';
import 'package:kyoryo/src/ui/bridge_list_item.dart';

class BridgeListScreen extends ConsumerWidget {
  const BridgeListScreen({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final municipality = ref.watch(currentMunicipalityProvider);
    final bridges = ref.watch(bridgesProvider);

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.bridgeListTitle),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: Text(municipality?.nameKanji ?? ''),
              onPressed: () {
                Navigator.restorablePushNamed(
                    context, BridgeFiltersScreen.routeName);
              },
            ),
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
              debugPrint('Error: $error');

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
