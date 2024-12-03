import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/damage_inspection.provider.dart';
import 'package:kyoryo/src/providers/diagram_inspection.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/ui/diagram_bottom_app_bar.dart';
import 'package:photo_view/photo_view.dart';

@RoutePage()
class DiagramInspectionScreen extends ConsumerStatefulWidget {
  final Diagram diagram;

  const DiagramInspectionScreen({super.key, required this.diagram});

  @override
  ConsumerState<DiagramInspectionScreen> createState() {
    return DiagramInspectionScreenState();
  }
}

class DiagramInspectionScreenState
    extends ConsumerState<DiagramInspectionScreen> {
  late PhotoViewController controller;
  late CachedNetworkImageProvider imageProvider;
  late Marking newMarking;
  int imageWidth = 0;
  int imageHeight = 0;
  double scale = 1.0;
  Offset position = Offset.zero;
  bool newMarkingMode = false;
  Future<void>? pendingSubmission;

  GlobalKey<DiagramBottomAppBarState> bottomAppBarKey = GlobalKey();

  void createInspecitonPoint() {
    final currentBridge = ref.watch(currentBridgeProvider);
    final inspectionPointsNotiffier =
        ref.read(inspectionPointsProvider(currentBridge!.id).notifier);

    setState(() {
      pendingSubmission = inspectionPointsNotiffier
          .createInspectionPoint(InspectionPoint(
              type: InspectionPointType.damage,
              bridgeId: currentBridge.id,
              spanName: bottomAppBarKey.currentState!.nameController.text,
              spanNumber:
                  bottomAppBarKey.currentState!.spanNumberController.text,
              elementNumber:
                  bottomAppBarKey.currentState!.elementNumberController.text,
              diagramMarkingX: newMarking.x,
              diagramMarkingY: newMarking.y,
              diagramId: widget.diagram.id))
          .then((_) {
        newMarkingMode = false;
        bottomAppBarKey.currentState!.elementNumberController.clear();
        bottomAppBarKey.currentState!.setShowNewPointForm(false);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    newMarking = const Marking(x: 0, y: 0);
    imageProvider = CachedNetworkImageProvider(widget.diagram.photo!.photoLink);
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        setState(() {
          imageWidth = info.image.width;
          imageHeight = info.image.height;
        });
      }),
    );

    controller = PhotoViewController()
      ..outputStateStream.listen((value) {
        setState(() {
          scale = value.scale ?? 1.0;
          position = value.position;
        });
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final state = ref.watch(diagramInspectionProvider(widget.diagram));

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (newMarkingMode)
            FutureBuilder(
                future: pendingSubmission,
                builder: (context, snapshot) {
                  final isSubmitting =
                      snapshot.connectionState == ConnectionState.waiting;

                  return FloatingActionButton.small(
                    heroTag: 'cancel_new_marking',
                    onPressed: isSubmitting
                        ? null
                        : () {
                            setState(() {
                              newMarkingMode = false;

                              if (bottomAppBarKey.currentState != null) {
                                bottomAppBarKey.currentState!
                                    .setShowNewPointForm(false);
                                bottomAppBarKey.currentState!.minimize();
                              }
                            });
                          },
                  );
                }),
          const SizedBox(
            height: 10,
          ),
          if (newMarkingMode)
            FutureBuilder(
                future: pendingSubmission,
                builder: (context, snapshot) {
                  final isSubmitting =
                      snapshot.connectionState == ConnectionState.waiting;

                  return FloatingActionButton(
                      heroTag: 'submit_new_marking',
                      onPressed: isSubmitting ? null : createInspecitonPoint,
                      child: isSubmitting
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                              ))
                          : const Icon(Icons.check));
                })
          else
            FloatingActionButton(
                heroTag: 'add_new_marking',
                child: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    newMarkingMode = true;

                    final adjustedX =
                        imageWidth / 2 - position.dx / scale + 20 / scale;
                    final adjustedY = imageHeight / 2 - position.dy / scale;

                    newMarking =
                        Marking(x: adjustedX.toInt(), y: adjustedY.toInt());

                    if (bottomAppBarKey.currentState != null) {
                      bottomAppBarKey.currentState!.setShowNewPointForm(true);
                      bottomAppBarKey.currentState!.maximize();
                    }
                  });
                })
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onLongPressEnd: (details) {
              if (!newMarkingMode) return;

              setState(() {
                final adjustedX = details.localPosition.dx / scale -
                    position.dx / scale -
                    screenWidth / 2 / scale +
                    imageWidth / 2;
                final adjustedY = details.localPosition.dy / scale -
                    position.dy / scale -
                    screenHeight / 2 / scale +
                    imageHeight / 2;

                newMarking =
                    Marking(x: adjustedX.toInt(), y: adjustedY.toInt());

                bottomAppBarKey.currentState!.maximize();
              });
            },
            child: PhotoView(
              controller: controller,
              imageProvider:
                  CachedNetworkImageProvider(widget.diagram.photo!.photoLink),
              enablePanAlways: true,
            ),
          ),
          if (newMarkingMode)
            Positioned(
              top: (newMarking.y * scale) +
                  (screenHeight - scale * imageHeight) / 2 +
                  position.dy -
                  32,
              left: (newMarking.x * scale) +
                  (screenWidth - scale * imageWidth) / 2 +
                  position.dx,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 32,
              ),
            ),
          ...renderMarkers(
              state.maybeWhen(orElse: () => [], data: (data) => data.points)),
          DiagramBottomAppBar(
            key: bottomAppBarKey,
            diagram: widget.diagram,
          )
        ],
      ),
    );
  }

  List<Positioned> renderMarkers(List<InspectionPoint> points) {
    List<InspectionPoint> ungrouped = List.from(points);
    List<List<InspectionPoint>> grouped = [];
    List<Positioned> markers = [];
    double radii = 40.0 / scale;

    for (var point in points) {
      if (ungrouped.contains(point)) {
        List<InspectionPoint> group = [point];

        ungrouped.remove(point);

        for (final InspectionPoint other in List.from(ungrouped)) {
          if (((point.diagramMarkingX ?? 0) - (other.diagramMarkingX ?? 0))
                      .abs() <
                  radii &&
              ((point.diagramMarkingY ?? 0) - (other.diagramMarkingY ?? 0))
                      .abs() <
                  radii) {
            ungrouped.remove(other);
            group.add(other);
          }
        }

        grouped.add(group);
      }
    }

    for (var group in grouped) {
      markers.add(buildMarker(group));
    }

    return markers;
  }

  Positioned buildMarker(List<InspectionPoint> group) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final damageInspection = ref
        .watch(damageInspectionProvider(ref.read(currentBridgeProvider)!.id))
        .value;

    final finishCount = group
        .where((point) => [
              InspectionPointReportStatus.finished,
              InspectionPointReportStatus.skipped
            ].contains(damageInspection?.statusByPointIds[point.id]))
        .length;

    final diagramInspection =
        ref.watch(diagramInspectionProvider(widget.diagram)).value;

    return Positioned(
      left: ((group.first.diagramMarkingX ?? 0) * scale) +
          (screenWidth - scale * imageWidth) / 2 +
          position.dx -
          20,
      top: ((group.first.diagramMarkingY ?? 0) * scale) +
          (screenHeight - scale * imageHeight) / 2 +
          position.dy -
          20,
      child: GestureDetector(
        onTap: () {
          if (diagramInspection == null || newMarkingMode) return;

          if (diagramInspection.isPointSelected(group.first)) {
            ref
                .read(diagramInspectionProvider(widget.diagram).notifier)
                .setSelectedPoints(null);
          } else {
            ref
                .read(diagramInspectionProvider(widget.diagram).notifier)
                .setSelectedPoints(group);
          }
        },
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: diagramInspection?.isPointSelected(group.first) ?? false
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
            color: Color.lerp(
              Colors.grey,
              Colors.green,
              finishCount / group.length,
            )!
                .withValues(alpha: 0.7),
          ),
          child: Text(
            '$finishCount/${group.length}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
