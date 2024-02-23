import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BridgeInspectionScreen extends ConsumerWidget {
  const BridgeInspectionScreen({super.key, required this.bridge});

  final Bridge bridge;

  static const routeName = '/bridge_actions';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
              bottom: TabBar(tabs: [
                Tab(
                  text: AppLocalizations.of(context)!.generalInspection,
                  icon: const Icon(Icons.generating_tokens_outlined),
                ),
                Tab(
                  text: AppLocalizations.of(context)!.damangeInspection,
                  icon: Icon(Icons.broken_image),
                )
              ]),
              title: Row(
                children: <Widget>[
                  Text(bridge.nameKanji),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline_rounded)),
                ],
              )),
          body: TabBarView(
            children: [
              ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return const ListTile(
                      isThreeLine: true,
                      title: Text('test 1'),
                      subtitle: Text('subtitle'),
                    );
                  }),
              Center(
                child: Text(AppLocalizations.of(context)!.noDamageFound,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
          bottomSheet: BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          )),
    );
  }
}
