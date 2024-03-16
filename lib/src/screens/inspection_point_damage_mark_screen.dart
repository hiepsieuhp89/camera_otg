import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';

class InspectionPointDamageMarkScreenArguments {
  final String diagramPath;

  InspectionPointDamageMarkScreenArguments({required this.diagramPath});
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

  final GlobalKey _imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final currentBridge = ref.watch(currentBridgeProvider);
    final imageWidget =
        Image.file(File(widget.arguments.diagramPath), key: _imageKey);

    imageWidget.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, synchronousCall) {
      setState(() {
        _imageHeight = info.image.height;
        _imageWidth = info.image.width;
      });
    }));

    final inspectionPointsNotiffier =
        ref.read(inspectionPointsProvider(currentBridge!.id).notifier);

    void createInspecitonPoint() {
      final markCoordinateX =
          ((_left + 10) / _imageKey.currentContext!.size!.width * _imageWidth)
              .round();
      final markCoordinateY =
          ((_top + 10) / _imageKey.currentContext!.size!.height * _imageHeight)
              .round();

      inspectionPointsNotiffier
          .createInspectionPoint(
              InspectionPoint(
                  name: _inspectionPointName,
                  type: InspectionPointType.damage,
                  bridgeId: currentBridge.id,
                  diagramMarkingX: markCoordinateX,
                  diagramMarkingY: markCoordinateY),
              widget.arguments.diagramPath)
          .then(
        (value) {
          Navigator.pushNamed(context, TakePictureScreen.routeName,
              arguments: value);
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.createInspectionPoints,
          ),
        ),
        floatingActionButton: _inspectionPointName.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: createInspecitonPoint,
                label: Text(AppLocalizations.of(context)!.inspectionPoint),
                icon: const Icon(Icons.add),
              ),
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
