import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class InpsectionPointListItem extends ConsumerWidget {
  final InspectionPoint point;
  final Function(InspectionPoint, {InspectionPointReport? createdReport})
      startInspect;

  const InpsectionPointListItem(
      {super.key, required this.point, required this.startInspect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeReport = ref
        .read(bridgeInspectionProvider(point.bridgeId!).notifier)
        .findActiveReportFromPoint(point.id!);

    final previousReport = ref
        .read(bridgeInspectionProvider(point.bridgeId!).notifier)
        .findPreviousReportFromPoint(point.id!);

    final previousPhoto = ref
        .read(inspectionPointReportServiceProvider)
        .getPreferredPhotoFromReport(previousReport);

    final isInspectionInProgress =
        ref.watch(isInspectionInProgressProvider(point.bridgeId!));

    String labelText;

    if (point.type == InspectionPointType.damage) {
      labelText =
          '${point.spanNumber ?? ''} - ${point.photoRefNumber ?? ''} : ${point.spanName ?? ''} / ${point.elementNumber ?? ''}';
    } else {
      String photoRefNumberWithLabel = point.photoRefNumber != null
          ? '${AppLocalizations.of(context)!.photoRefNumber(point.photoRefNumber.toString())}：'
          : '';
      labelText = '$photoRefNumberWithLabel${point.spanName ?? ''}';
    }

    Widget buildActionButton() {
      if (activeReport == null) {
        return IconButton.filled(
            onPressed: isInspectionInProgress
                ? () {
                    startInspect(point);
                  }
                : null,
            icon: const Icon(Icons.manage_search_rounded));
      }

      switch (activeReport.status) {
        case InspectionPointReportStatus.skipped:
          return FilledButton.icon(
              label: Text(AppLocalizations.of(context)!.skip),
              onPressed: isInspectionInProgress
                  ? () => confirmForReinspection(context, activeReport)
                  : null,
              icon: const Icon(Icons.do_not_disturb));

        case InspectionPointReportStatus.finished:
          return FilledButton.icon(
              onPressed: isInspectionInProgress
                  ? () {
                      startInspect(point, createdReport: activeReport);
                    }
                  : null,
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context)!.finished));

        case InspectionPointReportStatus.pending:
          return FilledButton.icon(
            onPressed: isInspectionInProgress
                ? () {
                    startInspect(point, createdReport: activeReport);
                  }
                : null,
            icon: const Icon(Icons.timer),
            label: Text(AppLocalizations.of(context)!.holdButton),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          );
      }
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
                  child: _imageGroup(context, previousPhoto, activeReport,
                      isInspectionInProgress),
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
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    labelText,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    AppLocalizations.of(context)!.inspectionDate(
                        activeReport?.date == null
                            ? ''
                            : DateFormat('yy年MM月dd日 HH:mm')
                                .format(activeReport!.date!)),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [buildActionButton()],
            )
          ],
        ),
      ),
    );
  }

  Future<dynamic> confirmForReinspection(
      BuildContext context, InspectionPointReport? activeReport) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!
              .confirmationForReinspection(point.photoRefNumber.toString())),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.noOption),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.yesOption),
              onPressed: () {
                Navigator.of(context).pop();
                startInspect(point, createdReport: activeReport);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _imageGroup(BuildContext context, Photo? previousPhoto,
      InspectionPointReport? activeReport, bool hasActiveInspection) {
    final List<String> imagePaths = point.type == InspectionPointType.damage
        ? [
            point.diagramMarkedPhotoLink ??
                point.diagram?.photo?.photoLink ??
                '',
            previousPhoto?.photoLink ?? '',
          ]
        : [previousPhoto?.photoLink ?? ''];

    if (activeReport != null) {
      imagePaths.addAll(activeReport.photos.sorted((a, b) {
        if (a.id == activeReport.preferredPhotoId) {
          return -1;
        } else if (b.id == activeReport.preferredPhotoId) {
          return 1;
        } else {
          return 0;
        }
      }).map((photo) => photo.photoLink));
    }

    return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: imagePaths.length,
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
            if (imagePaths[index] == '') {
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

            return buildImageContainer(context, imagePaths, imagePaths[index]);
          },
        ));
  }

  GestureDetector buildImageContainer(
      BuildContext context, List<String> imageUrls, String imageUrl) {
    return GestureDetector(
      onTap: () {
        final viewableImages = imageUrls.where((url) => url != '').toList();

        final markings = point.diagramMarkingX != null &&
                point.diagramMarkingY != null &&
                point.type == InspectionPointType.damage &&
                imageUrl != point.diagramMarkedPhotoLink
            ? {
                0: Marking(
                  x: point.diagramMarkingX!,
                  y: point.diagramMarkingY!,
                )
              }
            : null;

        viewImages(context, viewableImages, viewableImages.indexOf(imageUrl),
            markings);
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
