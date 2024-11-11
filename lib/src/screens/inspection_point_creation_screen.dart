import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/marking.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/ui/image_marking_view_overlay.dart';

@RoutePage()
class InspectionPointCreationScreen extends ConsumerStatefulWidget {
  final Diagram? diagram;
  final InspectionPointType pointType;

  const InspectionPointCreationScreen(
      {super.key, this.diagram, required this.pointType});

  @override
  ConsumerState<InspectionPointCreationScreen> createState() =>
      InspectionPointCreationScreenState();
}

class InspectionPointCreationScreenState
    extends ConsumerState<InspectionPointCreationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _spanNumberController;
  late TextEditingController _elementNumberController;
  Marking _marking = const Marking(x: 0, y: 0);
  int _imageWidth = 1;
  int _imageHeight = 1;
  Future<void>? _pendingSubmission;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _spanNumberController = TextEditingController();
    _elementNumberController = TextEditingController();
  }

  void goToTakePictureScreen(InspectionPoint point) {
    context.pushRoute(TakePictureRoute(inspectionPoint: point));
  }

  void createInspecitonPoint() {
    final currentBridge = ref.watch(currentBridgeProvider);
    final inspectionPointsNotiffier =
        ref.read(inspectionPointsProvider(currentBridge!.id).notifier);

    setState(() {
      _pendingSubmission = inspectionPointsNotiffier
          .createInspectionPoint(InspectionPoint(
              type: widget.pointType,
              bridgeId: currentBridge.id,
              spanName: _nameController.text,
              spanNumber: _spanNumberController.text,
              elementNumber: _elementNumberController.text,
              diagramMarkingX: _marking.x,
              diagramMarkingY: _marking.y,
              diagramId: widget.diagram?.id))
          .then(goToTakePictureScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    CachedNetworkImageProvider? imageProvider;

    if (widget.diagram != null) {
      imageProvider =
          CachedNetworkImageProvider(widget.diagram!.photo!.photoLink);

      imageProvider
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((info, synchronousCall) {
        setState(() {
          _imageHeight = info.image.height;
          _imageWidth = info.image.width;
        });
      }));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.createInspectionPoints,
          ),
        ),
        floatingActionButton: FutureBuilder(
            future: _pendingSubmission,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              return FloatingActionButton(
                  onPressed: isLoading ? null : createInspecitonPoint,
                  child: isLoading
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                          ))
                      : const Icon(Icons.arrow_forward));
            }),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.name),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _spanNumberController,
                      decoration: InputDecoration(
                        label: Text(AppLocalizations.of(context)!.spanNumber),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _elementNumberController,
                      decoration: InputDecoration(
                        label:
                            Text(AppLocalizations.of(context)!.elementNumber),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
              if (imageProvider != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.damageMarking,
                    )
                  ],
                ),
                GestureDetector(
                  onTapDown: (details) {
                    Navigator.push(
                            context,
                            ImageMarkingViewOverlay(
                                imageProvider: imageProvider!,
                                originalMarking: _marking))
                        .then((Marking? marking) {
                      if (marking != null) {
                        setState(() {
                          _marking = marking;
                        });
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Image(
                        image: imageProvider,
                      ),
                      Positioned.fill(
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Stack(
                            children: [
                              Positioned(
                                top: _marking.y /
                                    _imageHeight *
                                    constraints.maxHeight,
                                left: _marking.x /
                                    _imageWidth *
                                    constraints.maxWidth,
                                child: const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              )
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ));
  }
}
