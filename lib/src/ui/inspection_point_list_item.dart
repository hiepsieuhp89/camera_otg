import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class InpsectionPointListItem extends ConsumerWidget {
  final InspectionPoint point;
  final bool isInspecting;
  final Function(InspectionPoint) startInspect;

  const InpsectionPointListItem(
      {super.key,
      required this.point,
      this.isInspecting = false,
      required this.startInspect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspection = ref.watch(bridgeInspectionProvider(point.bridgeId!));
    InspectionPointReport? createdReport;

    try {
      createdReport = inspection?.reports
          .firstWhere((report) => report.inspectionPointId == point.id);
    } catch (e) {
      createdReport = null;
    }

    return Card(
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 228,
          minHeight: 228,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: _imageGroup(context, createdReport),
                )
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                point.type == InspectionPointType.damage
                    ? Icon(Icons.broken_image_outlined,
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.image_search_outlined,
                        color: Theme.of(context).primaryColor),
                Text(
                  point.name!,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    AppLocalizations.of(context)!.lastInspectionDate(
                        point.lastInspectionDate == null
                            ? ''
                            : DateFormat('yy年MM月dd日 HH:mm')
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

  Widget _imageGroup(BuildContext context, InspectionPointReport? report) {
    final images = point.type == InspectionPointType.damage
        ? [
            point.diagramUrl!,
            point.photoUrl!,
          ]
        : [point.photoUrl!];

    if (isInspecting && report == null) {
      images.add('');
    } else if (isInspecting && report != null) {
      images.addAll(report.photos!.map((photo) => photo.photoLink));
    }

    return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (context, index) {
            if ((point.type == InspectionPointType.damage && index == 1) ||
                (point.type == InspectionPointType.presentCondition &&
                    index == 0)) {
              return const SizedBox(
                width: 25,
                child: Center(
                  child: VerticalDivider(
                    width: 1,
                  ),
                ),
              );
            }
            return const SizedBox(width: 12);
          },
          itemBuilder: (context, index) {
            if (images[index] == '') {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: Center(
                  child: Icon(Icons.do_not_disturb,
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      size: 40.0),
                ),
              );
            }

            return buildImageContainer(context, images[index]);
          },
        ));
  }

  GestureDetector buildImageContainer(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () {
        viewImage(context, imageUrl);
      },
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          constraints: const BoxConstraints.expand(height: 120, width: 120),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.black12,
              width: 1,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
      ),
    );
  }
}
