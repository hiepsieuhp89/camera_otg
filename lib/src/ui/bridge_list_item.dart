import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/screens/bridge_inspection_screen.dart';

class BridgeListItem extends ConsumerWidget {
  final Bridge bridge;

  const BridgeListItem({super.key, required this.bridge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                viewImage(context, imageUrl: bridge.photoLink);
              },
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    image: DecorationImage(
                      image: NetworkImage(bridge.photoLink),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      bridge.nameKanji,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                    Expanded(
                      child: Text(
                        '橋梁管理番号:${bridge.managementNo}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    bridge.lastInspectionDate != null
                        ? Text(
                            AppLocalizations.of(context)!.lastInspectionDate(
                                DateFormat('yy年MM月dd日 HH:mm')
                                    .format(bridge.lastInspectionDate!)),
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.manage_search_rounded),
                      onPressed: () {
                        ref.watch(currentBridgeProvider.notifier).set(bridge);

                        Navigator.pushNamed(
                            context, BridgeInspectionScreen.routeName);
                      })
                ])
          ],
        ),
      ),
    );
  }
}
