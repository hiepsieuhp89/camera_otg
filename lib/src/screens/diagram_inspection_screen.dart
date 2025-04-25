import 'dart:async';

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
import 'package:kyoryo/src/providers/diagrams.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
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

class DiagramInspectionScreenState extends ConsumerState<DiagramInspectionScreen> {
  late PhotoViewController controller;
  late Marking newMarking;
  int imageWidth = 0;
  int imageHeight = 0;
  double scale = 1.0;
  Offset position = Offset.zero;
  bool newMarkingMode = false;
  bool isLoading = true;
  Future<void>? pendingSubmission;
  String imageUrl = '';
  String uniqueKey = DateTime.now().millisecondsSinceEpoch.toString();
  Diagram currentDiagram;
  
  // Constructor initialization
  DiagramInspectionScreenState() : currentDiagram = Diagram(bridgeId: 0, photoId: 0);

  GlobalKey<DiagramBottomAppBarState> bottomAppBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    currentDiagram = widget.diagram;
    newMarking = const Marking(x: 0, y: 0);
    imageUrl = currentDiagram.photo!.photoLink;
    
    // Force clear all caches at start
    _clearAllCaches();
    
    controller = PhotoViewController()
      ..outputStateStream.listen((value) {
        setState(() {
          scale = value.scale ?? 1.0;
          position = value.position;
        });
      });
      
    // Preload the image dimensions
    _loadImageDimensions();
  }
  
  Future<void> _loadImageDimensions() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Create a fresh network image without caching
      final networkImage = NetworkImage(imageUrl);
      
      final completer = Completer<ImageInfo>();
      final stream = networkImage.resolve(ImageConfiguration.empty);
      final listener = ImageStreamListener((info, _) {
        completer.complete(info);
      }, onError: (exception, stackTrace) {
        completer.completeError(exception);
      });
      
      stream.addListener(listener);
      
      final imageInfo = await completer.future;
      
      setState(() {
        imageWidth = imageInfo.image.width;
        imageHeight = imageInfo.image.height;
        isLoading = false;
      });
      
      stream.removeListener(listener);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading image: $e')),
        );
      }
    }
  }
  
  void _clearAllCaches() {
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Clear specific URL
    CachedNetworkImage.evictFromCache(imageUrl);
  }
  
  Future<void> _refreshDiagram() async {
    final currentBridge = ref.read(currentBridgeProvider);
    if (currentBridge == null) return;
    
    // Clear caches
    _clearAllCaches();
    
    try {
      // Re-fetch the diagram from API to get fresh data
      final refreshedDiagrams = await ref.read(diagramsProvider(currentBridge.id).future);
      final refreshedDiagram = refreshedDiagrams.firstWhere(
        (d) => d.id == currentDiagram.id,
        orElse: () => currentDiagram,
      );
      
      setState(() {
        currentDiagram = refreshedDiagram;
        imageUrl = refreshedDiagram.photo!.photoLink;
        uniqueKey = DateTime.now().millisecondsSinceEpoch.toString();
        isLoading = false;
      });
      
      // Reload dimensions with the new image
      _loadImageDimensions();
      
      // Refresh all related providers
      ref.invalidate(inspectionPointsProvider(currentBridge.id));
      ref.invalidate(diagramInspectionProvider(refreshedDiagram));
      ref.invalidate(damageInspectionProvider(currentBridge.id));
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing diagram: $e')),
        );
      }
    }
  }

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
              diagramId: currentDiagram.id))
          .then((_) {
        newMarkingMode = false;
        bottomAppBarKey.currentState!.elementNumberController.clear();
        bottomAppBarKey.currentState!.setShowNewPointForm(false);
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

    // Watch the diagram inspection state using the current diagram
    final diagramInspectionState = ref.watch(diagramInspectionProvider(currentDiagram));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FloatingActionButton(
              heroTag: 'edit_diagram',
              child: const Icon(Icons.edit),
              onPressed: () async {
                // Clear caches before navigating
                _clearAllCaches();
                
                final result = await context.router.push<Diagram>(
                  DiagramSketchRoute(diagram: currentDiagram),
                );
                
                if (result != null) {
                  setState(() {
                    currentDiagram = result;
                    imageUrl = result.photo!.photoLink;
                    uniqueKey = DateTime.now().millisecondsSinceEpoch.toString();
                  });
                  
                  // Force manual refresh after returning with updated diagram
                  _clearAllCaches();
                  await _refreshDiagram();
                }
              },
            ),
          ),
        ],
      ),
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
                    child: Icon(Icons.cancel),
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

                    // Update the new marking position to be in the center of the screen
                    // Offset +40 is to account for bottom app bar
                    final adjustedX =
                        imageWidth / 2 - position.dx / scale + 40 / scale;
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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
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
                key: ValueKey('diagram_$uniqueKey'),
                controller: controller,
                // Use NetworkImage directly instead of CachedNetworkImageProvider
                imageProvider: NetworkImage(imageUrl),
                enablePanAlways: true,
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 40),
                        SizedBox(height: 16),
                        Text('Error loading image', style: TextStyle(color: Colors.red)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshDiagram,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, event) {
                  return Center(
                    child: CircularProgressIndicator(
                      value: event == null
                          ? 0
                          : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                    ),
                  );
                },
              ),
            ),
          if (newMarkingMode && !isLoading)
            Positioned(
              top: (newMarking.y * scale) +
                  (screenHeight - scale * imageHeight) / 2 +
                  position.dy -
                  32,
              left: (newMarking.x * scale) +
                  (screenWidth - scale * imageWidth) / 2 +
                  position.dx -
                  32,
              child: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 32,
              ),
            ),
          ...renderMarkers(
              diagramInspectionState.maybeWhen(orElse: () => [], data: (data) => data.points)),
          DiagramBottomAppBar(
            key: bottomAppBarKey,
            diagram: currentDiagram,
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
        ref.watch(diagramInspectionProvider(currentDiagram)).value;

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
                .read(diagramInspectionProvider(currentDiagram).notifier)
                .setSelectedPoints(null);
          } else {
            ref
                .read(diagramInspectionProvider(currentDiagram).notifier)
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
