import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/diagram_inspection.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/ui/inspection_point_label.dart';

class DiagramBottomAppBar extends ConsumerStatefulWidget {
  final Diagram diagram;

  const DiagramBottomAppBar({super.key, required this.diagram});

  @override
  ConsumerState<DiagramBottomAppBar> createState() =>
      DiagramBottomAppBarState();
}

class DiagramBottomAppBarState extends ConsumerState<DiagramBottomAppBar> {
  late final DraggableScrollableController scrollController;
  late TextEditingController nameController;
  late TextEditingController spanNumberController;
  late TextEditingController elementNumberController;
  bool showNewPointForm = false;

  @override
  void initState() {
    super.initState();

    scrollController = DraggableScrollableController();
    nameController = TextEditingController();
    spanNumberController = TextEditingController();
    elementNumberController = TextEditingController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    nameController.dispose();
    spanNumberController.dispose();
    elementNumberController.dispose();
    super.dispose();
  }

  void setShowNewPointForm(bool value) {
    setState(() {
      showNewPointForm = value;
    });
  }

  void minimize() {
    scrollController.animateTo(
      0.25,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void maximize() {
    scrollController.animateTo(
      0.65,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bottomPadding = 0.25;
    final currentBridge = ref.watch(currentBridgeProvider);
    final state = ref.watch(diagramInspectionProvider(widget.diagram));

    Widget inspectionPoint(BuildContext context, InspectionPoint point) {
      final activeReport = ref
          .read(diagramInspectionProvider(widget.diagram).notifier)
          .findActiveReportFromPoint(point.id!);
      final previousReport = ref
          .read(diagramInspectionProvider(widget.diagram).notifier)
          .findPreviousReportFromPoint(point.id!);

      final photoFromActiveReport = activeReport?.photos
          .firstWhereOrNull((photo) => photo.sequenceNumber == 1);
      final photoFromPreviousReport = previousReport?.photos
          .firstWhereOrNull((photo) => photo.sequenceNumber == 1);

      final String statusText;

      switch (activeReport?.status) {
        case InspectionPointReportStatus.finished:
          statusText = AppLocalizations.of(context)!.statusFinished;
          break;
        case InspectionPointReportStatus.pending:
          statusText = AppLocalizations.of(context)!.statusOnHold;
          break;
        case InspectionPointReportStatus.skipped:
          statusText = AppLocalizations.of(context)!.statusSkipped;
          break;
        default:
          statusText = AppLocalizations.of(context)!.statusNotInspected;
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    photoFromPreviousReport?.url != null
                        ? buildReportImage(photoFromPreviousReport!.url!)
                        : buildEmptyReportImage(context),
                    const SizedBox(width: 8),
                    photoFromActiveReport?.url != null
                        ? buildReportImage(photoFromActiveReport!.url!)
                        : buildEmptyReportImage(context),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.broken_image_outlined,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: InspectionPointLabel(point: point))
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: [
                          InspectionPointReportStatus.finished,
                          InspectionPointReportStatus.skipped
                        ].contains(activeReport?.status)
                            ? Theme.of(context).primaryColor
                            : Colors.orange,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  context.pushRoute(TakePictureRoute(
                      inspectionPoint: point, createdReport: activeReport));
                })
          ],
        ),
      );
    }

    return DraggableScrollableSheet(
        controller: scrollController,
        initialChildSize: bottomPadding,
        minChildSize: bottomPadding,
        maxChildSize: 0.65,
        snap: true,
        builder: (
          BuildContext context,
          ScrollController scrollController,
        ) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isLandscape =
                  MediaQuery.of(context).orientation == Orientation.landscape;
              return Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: isLandscape
                      ? constraints.maxWidth / 2
                      : constraints.maxWidth,
                  child: Card(
                    surfaceTintColor: Colors.transparent,
                    elevation: 18.0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    margin: const EdgeInsets.all(0),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 12),
                              Container(
                                height: 4,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).dividerColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentBridge?.nameKanji ?? '',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                              textAlign: TextAlign.left,
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .span(state.maybeWhen(
                                                      orElse: () => '',
                                                      data: (data) =>
                                                          data.spanNumber)),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .finishedTasks(
                                                      state.maybeWhen(
                                                          orElse: () => 0,
                                                          data: (data) => data
                                                              .finishedCount),
                                                      state.maybeWhen(
                                                          orElse: () => 0,
                                                          data: (data) => data
                                                              .points.length)),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                          Icons.manage_search_rounded)),
                                ],
                              ),
                              const Divider(
                                indent: 16,
                                endIndent: 16,
                                thickness: 1,
                              ),
                              if (showNewPointForm)
                                buildNewPointForm()
                              else
                                state.maybeWhen(data: (data) {
                                  return Column(
                                    children: data.selectedPoints.map((point) {
                                      return inspectionPoint(context, point);
                                    }).toList(),
                                  );
                                }, orElse: () {
                                  return const SizedBox.shrink();
                                }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  buildNewPointForm() {
    final state = ref.watch(diagramInspectionProvider(widget.diagram));

    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.pressAndHoldForMarking,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        Container(child: state.whenOrNull(data: (data) {
          if (data.spanName.isNotEmpty && nameController.text.isEmpty) {
            nameController.text = data.spanName;
          }

          spanNumberController.text = data.spanNumber;

          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: spanNumberController,
                    enabled: data.spanNumber.isEmpty,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.spanNumber,
                        border: const OutlineInputBorder()),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.name,
                        border: const OutlineInputBorder()),
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: elementNumberController,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.elementNumber,
                        border: const OutlineInputBorder()),
                  ),
                ),
              ),
            ],
          );
        }))
      ],
    );
  }

  buildEmptyReportImage(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
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
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            size: 24.0),
      ),
    );
  }

  buildReportImage(String url) {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        child: CachedNetworkImage(
            imageUrl: url,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
                height: 80,
                width: 80,
                color: Theme.of(context).secondaryHeaderColor)));
  }
}
