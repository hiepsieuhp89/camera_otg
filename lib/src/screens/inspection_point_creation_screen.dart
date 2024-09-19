import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/routing/router.dart';

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
  double _top = 0;
  double _left = 0;
  int _imageWidth = 0;
  int _imageHeight = 0;
  String _spanName = '';
  String _spanNumber = '';
  String _elementNumber = '';
  Future<void>? _pendingSubmission;

  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _spanNumberController = TextEditingController();
    _elementNumberController = TextEditingController();
  }

  void createInspecitonPoint() {
    final currentBridge = ref.watch(currentBridgeProvider);
    final inspectionPointsNotiffier =
        ref.read(inspectionPointsProvider(currentBridge!.id).notifier);

    int? markCoordinateX;
    int? markCoordinateY;

    if (widget.diagram != null && _imageWidth != 0 && _imageHeight != 0) {
      markCoordinateX =
          ((_left + 10) / _imageKey.currentContext!.size!.width * _imageWidth)
              .round();
      markCoordinateY =
          ((_top + 10) / _imageKey.currentContext!.size!.height * _imageHeight)
              .round();
    }

    setState(() {
      _pendingSubmission = inspectionPointsNotiffier
          .createInspectionPoint(InspectionPoint(
              spanName: _spanName,
              type: widget.pointType,
              bridgeId: currentBridge.id,
              spanNumber: _spanNumber,
              elementNumber: _elementNumber,
              diagramMarkingX: markCoordinateX,
              diagramMarkingY: markCoordinateY,
              diagramId: widget.diagram?.id))
          .then(
        (createdPoint) {
          context.pushRoute(TakePictureRoute(inspectionPoint: createdPoint));
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Image? imageWidget;

    if (widget.diagram != null) {
      imageWidget =
          Image.network(widget.diagram!.photo!.photoLink, key: _imageKey);

      imageWidget.image
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
              TextField(
                  controller: _nameController,
                  onSubmitted: (value) {
                    setState(() {
                      _spanName = value;
                    });
                  },
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.name),
                    border: const OutlineInputBorder(),
                  )),
              const SizedBox(height: 10.0),
              TextField(
                  controller: _spanNumberController,
                  onSubmitted: (value) {
                    setState(() {
                      _spanNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.spanNumber),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ]
              ),
              const SizedBox(height: 10.0),
              TextField(
                  controller: _elementNumberController,
                  onSubmitted: (value) {
                    setState(() {
                      _elementNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.elementNumber),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ]
              ),
              if (imageWidget != null) ...[
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
                    _top = details.localPosition.dy - 10;
                    _left = details.localPosition.dx - 10;

                    setState(() {});
                  },
                  child: Stack(children: [
                    imageWidget,
                    Positioned(
                        top: _top,
                        left: _left,
                        child: const Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 20,
                        ))
                  ]),
                ),
                SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                          AppLocalizations.of(context)!
                              .pleaseTapOnWhereTheDamageLocates,
                          style: Theme.of(context).textTheme.bodySmall),
                    )),
              ]
            ],
          ),
        ));
  }
}
