import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:photo_view/photo_view.dart';

class InpsectionPointListItem extends ConsumerWidget {
  final Bridge bridge;
  final InspectionPoint point;
  final bool isInspecting;
  final Function(InspectionPoint) startInspect;

  const InpsectionPointListItem(
      {super.key,
      required this.point,
      required this.bridge,
      this.isInspecting = false,
      required this.startInspect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdReport =
        ref.watch(bridgeInspectionProvider(bridge.id!))[point.id!];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: SizedBox(
        height: 150,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _imageGroup(context),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Text(
                    point.name ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.left,
                  ),
                )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    AppLocalizations.of(context)!.lastInspectionDate(
                        DateFormat('yy年MM月dd日 HH:mm')
                            .format(point.lastInspectionDate!)),
                    style: Theme.of(context).textTheme.bodySmall),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    createdReport != null
                        ? Chip(
                            backgroundColor: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.15),
                            label: Row(
                              children: [
                                Icon(Icons.check,
                                    color: Theme.of(context).primaryColor,
                                    size: 20.0),
                                const SizedBox(width: 5.0),
                                Text(AppLocalizations.of(context)!.finished)
                              ],
                            ))
                        : IconButton.filled(
                            onPressed: isInspecting
                                ? () {
                                    startInspect(point);
                                  }
                                : null,
                            icon: const Icon(Icons.manage_search_rounded)),
                  ],
                ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Container _imageGroup(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12.0)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(point.name ?? ''),
                    ),
                    body: Center(
                        child: PhotoView(
                      imageProvider: NetworkImage(point.photoUrl!),
                    )),
                  ),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                constraints:
                    const BoxConstraints.expand(height: 100, width: 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  image: DecorationImage(
                    image: NetworkImage(point.photoUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text(point.name ?? ''),
                    ),
                    body: Center(
                        child: PhotoView(
                      imageProvider: NetworkImage(point.diagramUrl!),
                    )),
                  ),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                constraints:
                    const BoxConstraints.expand(height: 100, width: 100),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  image: DecorationImage(
                    image: NetworkImage(point.diagramUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12.0)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
