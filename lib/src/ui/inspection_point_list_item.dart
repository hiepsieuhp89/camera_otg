import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/services/inspection_point_report.service.dart';
import 'package:kyoryo/src/utilities/datetime.dart';
import 'package:kyoryo/src/ui/inspection_point_label.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';

class InpsectionPointListItem extends ConsumerWidget {
  final InspectionPoint point;

  const InpsectionPointListItem({super.key, required this.point});

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

    final adjustedSmallTextStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize:
                  (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12.0) - 2,
            );

    void startInspection() {
      context.pushRoute(TakePictureRoute(
          inspectionPoint: point, createdReport: activeReport));
    }

    Future<dynamic> confirmForReinspection(BuildContext context) {
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
                  startInspection();
                },
              ),
            ],
          );
        },
      );
    }

    Column buildDetailsColumn(report) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              '${AppLocalizations.of(context)!.targetMaterial}: '
              '${report?.metadata?["damage_category"] ?? ''}',
              style: adjustedSmallTextStyle),
          Text(
              '${report?.metadata?['damage_type']?.toString() ?? ''}'
              '${report?.metadata?['damage_level']?.toString() ?? ''}',
              style: adjustedSmallTextStyle),
          const SizedBox(height: 3.0),
          Text(report?.metadata?['remark']?.toString() ?? '',
              style: adjustedSmallTextStyle),
        ],
      );
    }

    Future showDetailsListPopUp() {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              content: SingleChildScrollView(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.thisTime}:',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        buildDetailsColumn(activeReport),
                        const SizedBox(height: 10.0),
                        Text(
                          '${AppLocalizations.of(context)!.lastTime}:',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        buildDetailsColumn(previousReport)
                      ],
                    ),
                  ])),
            );
          });
        },
      );
    }

    Widget showDetailsButton() {
      return IconButton.filled(
          onPressed: () {
            showDetailsListPopUp();
          },
          icon: const Icon(Icons.info));
    }

    Widget buildActionButton() {
      if (activeReport == null) {
        return IconButton.filled(
          onPressed: isInspectionInProgress
              ? () {
                  startInspection();
                }
              : null,
          icon: const Icon(Icons.manage_search_outlined),
          style: FilledButton.styleFrom(backgroundColor: Colors.orange),
        );
      }

      switch (activeReport.status) {
        case InspectionPointReportStatus.skipped:
          return FilledButton.icon(
              label: Text(AppLocalizations.of(context)!.skip),
              onPressed: isInspectionInProgress
                  ? () => confirmForReinspection(context)
                  : null,
              icon: const Icon(Icons.do_not_disturb));

        case InspectionPointReportStatus.finished:
          return FilledButton.icon(
              onPressed: isInspectionInProgress
                  ? () {
                      startInspection();
                    }
                  : null,
              icon: const Icon(Icons.edit),
              label: Text(AppLocalizations.of(context)!.finished));

        case InspectionPointReportStatus.pending:
          return FilledButton.icon(
            onPressed: isInspectionInProgress
                ? () {
                    startInspection();
                  }
                : null,
            icon: const Icon(Icons.timer),
            label: Text(AppLocalizations.of(context)!.holdButton),
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
          );
      }
    }

    return Card(
      color: previousReport == null && point.type == InspectionPointType.damage
          ? Theme.of(context).secondaryHeaderColor
          : activeReport?.status == InspectionPointReportStatus.finished
              ? Theme.of(context).primaryColorLight
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                point.type == InspectionPointType.damage
                    ? Icon(Icons.broken_image_outlined,
                        color: Theme.of(context).primaryColor)
                    : Icon(Icons.image_search_outlined,
                        color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Expanded(
                  child: InspectionPointLabel(
                    point: point,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildImageGroup(context, previousPhoto, activeReport,
                          isInspectionInProgress),
                      const SizedBox(height: 10.0),
                      Text(
                        AppLocalizations.of(context)!.inspectionDate(
                            (activeReport?.date ?? previousReport?.date) == null
                                ? ''
                                : (activeReport?.date != null
                                    ? DateFormat('yy年MM月dd日 HH:mm').format(
                                        getLocalDateTimeFromUTC(
                                            activeReport!.date!))
                                    : DateFormat('yy年MM月dd日').format(
                                        getLocalDateTimeFromUTC(
                                            previousReport!.date!)))),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        mainAxisAlignment: MediaQuery.of(context).orientation !=
                                Orientation.portrait
                            ? MainAxisAlignment.spaceEvenly
                            : MainAxisAlignment.end,
                        children: [
                          if (MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${AppLocalizations.of(context)!.damageType}: '
                                    '${activeReport?.metadata?['damage_type']?.toString() ?? previousReport?.metadata?['damage_type']?.toString() ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '${AppLocalizations.of(context)!.damageLevel}: '
                                    '${activeReport?.metadata?['damage_level']?.toString() ?? previousReport?.metadata?['damage_level']?.toString() ?? ''}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ]),
                          const Spacer(),
                          if (MediaQuery.of(context).orientation ==
                              Orientation.portrait)
                            showDetailsButton(),
                          const SizedBox(width: 8),
                          buildActionButton()
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20.0),
                if (MediaQuery.of(context).orientation == Orientation.landscape)
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context)!.lastTime}:',
                                        style: adjustedSmallTextStyle?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      buildDetailsColumn(previousReport)
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context)!.thisTime}:',
                                        style: adjustedSmallTextStyle?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3.0),
                                      activeReport != null
                                          ? buildDetailsColumn(activeReport)
                                          : Text(
                                              AppLocalizations.of(context)!
                                                  .noDataYet,
                                              style: adjustedSmallTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageGroup(
      BuildContext context,
      InspectionPointReportPhoto? previousPhoto,
      InspectionPointReport? activeReport,
      bool hasActiveInspection) {
    final List<String> imagePaths = point.type == InspectionPointType.damage
        ? [
            point.diagramMarkedPhotoLink ??
                point.diagram?.photo?.photoLink ??
                '',
            previousPhoto?.url ?? '',
          ]
        : [previousPhoto?.url ?? ''];

    if (activeReport != null) {
      imagePaths.addAll(activeReport.photos.sorted((a, b) {
        if (a.sequenceNumber == 1) {
          return -1;
        } else if (b.sequenceNumber == 1) {
          return 1;
        } else if (a.sequenceNumber != null && b.sequenceNumber == null) {
          return -1;
        } else if (a.sequenceNumber == null && b.sequenceNumber != null) {
          return 1;
        } else if (a.sequenceNumber != null && b.sequenceNumber != null) {
          return a.sequenceNumber!.compareTo(b.sequenceNumber!);
        } else {
          return 0;
        }
      }).map((photo) => photo.url!));
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.black12,
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                ),
                child: Center(
                  child: Icon(Icons.do_not_disturb,
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.2),
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
