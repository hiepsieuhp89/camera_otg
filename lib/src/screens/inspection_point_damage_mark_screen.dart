import 'package:flutter/material.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';

class InspectionPointDamageMarkScreenArguments {
  final Diagram diagram;

  InspectionPointDamageMarkScreenArguments({required this.diagram});
}

class InspectionPointDamageMarkScreen extends ConsumerStatefulWidget {
  static const String routeName = '/inspection-point-damage-mark';
  final InspectionPointDamageMarkScreenArguments arguments;

  const InspectionPointDamageMarkScreen({super.key, required this.arguments});

  @override
  ConsumerState<InspectionPointDamageMarkScreen> createState() =>
      InspectionPointDamageMarkScreenState();
}

class InspectionPointDamageMarkScreenState
    extends ConsumerState<InspectionPointDamageMarkScreen> {
  late TextEditingController _nameController;
  double _top = 0;
  double _left = 0;
  int _imageWidth = 0;
  int _imageHeight = 0;
  String _inspectionPointName = '';
  Future<void>? _pendingSubmission;

  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  void createInspecitonPoint() {
    final currentBridge = ref.watch(currentBridgeProvider);
    final inspectionPointsNotiffier =
        ref.read(inspectionPointsProvider(currentBridge!.id).notifier);

    final markCoordinateX =
        ((_left + 10) / _imageKey.currentContext!.size!.width * _imageWidth)
            .round();
    final markCoordinateY =
        ((_top + 10) / _imageKey.currentContext!.size!.height * _imageHeight)
            .round();

    setState(() {
      _pendingSubmission = inspectionPointsNotiffier
          .createInspectionPoint(InspectionPoint(
              name: _inspectionPointName,
              type: InspectionPointType.damage,
              bridgeId: currentBridge.id,
              diagramMarkingX: markCoordinateX,
              diagramMarkingY: markCoordinateY,
              diagramId: widget.arguments.diagram.id))
          .then(
        (createdPoint) {
          Navigator.pushNamed(context, TakePictureScreen.routeName,
              arguments:
                  TakePictureScreenArguments(inspectionPoint: createdPoint));
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.network(widget.arguments.diagram.photo!.photoLink,
        key: _imageKey);

    imageWidget.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, synchronousCall) {
      setState(() {
        _imageHeight = info.image.height;
        _imageWidth = info.image.width;
      });
    }));

    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.createInspectionPoints,
          ),
        ),
        floatingActionButton: _inspectionPointName.isEmpty
            ? null
            : FutureBuilder(
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
                      _inspectionPointName = value;
                    });
                  },
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.name),
                    border: const OutlineInputBorder(),
                  )),
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
            ],
          ),
        ));
  }
}
