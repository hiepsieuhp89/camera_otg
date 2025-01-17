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
class InspectionPointScreen extends ConsumerStatefulWidget {
  final InspectionPoint initialPoint;

  const InspectionPointScreen({super.key, required this.initialPoint});

  @override
  ConsumerState<InspectionPointScreen> createState() =>
      InspectionPointScreenState();
}

class InspectionPointScreenState extends ConsumerState<InspectionPointScreen> {
  late TextEditingController _nameController;
  late TextEditingController _spanNumberController;
  late TextEditingController _elementNumberController;
  Diagram? _diagram;
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

    _nameController.text = widget.initialPoint.spanName ?? '';
    _spanNumberController.text = widget.initialPoint.spanNumber ?? '';
    _elementNumberController.text = widget.initialPoint.elementNumber ?? '';
    _diagram = widget.initialPoint.diagram;
    _marking = Marking(
        x: widget.initialPoint.diagramMarkingX ?? 0,
        y: widget.initialPoint.diagramMarkingY ?? 0);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _spanNumberController.dispose();
    _elementNumberController.dispose();
    super.dispose();
  }

  void goToTakePictureScreen(InspectionPoint point) {
    context.pushRoute(TakePictureRoute(inspectionPoint: point));
  }

  void goBack() {
    context.maybePop();
  }

  void goToDiagramSelectionScreen() {
    context
        .pushRoute<Diagram?>(InspectionPointDiagramSelectRoute())
        .then((diagram) {
      setState(() {
        _diagram = diagram;
      });
    });
  }

  void submit() {
    if (widget.initialPoint.type == InspectionPointType.damage &&
        _diagram == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.selectDiagramWarning)));
      return;
    }

    final currentBridge = ref.watch(currentBridgeProvider);
    final inspectionPointsNotifier =
        ref.read(inspectionPointsProvider(currentBridge!.id).notifier);

    final inspectionPoint = widget.initialPoint.copyWith(
      spanName: _nameController.text,
      spanNumber: _spanNumberController.text,
      elementNumber: _elementNumberController.text,
      diagramId: _diagram?.id,
      diagramMarkingX: _marking.x,
      diagramMarkingY: _marking.y,
    );

    setState(() {
      if (widget.initialPoint.id != null) {
        _pendingSubmission = inspectionPointsNotifier
            .updateInspectionPoint(inspectionPoint)
            .then((updatedPoint) => goBack());
      } else {
        _pendingSubmission = inspectionPointsNotifier
            .createInspectionPoint(inspectionPoint)
            .then((newPoint) => goToTakePictureScreen(newPoint));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CachedNetworkImageProvider? imageProvider;

    if (_diagram != null) {
      imageProvider = CachedNetworkImageProvider(_diagram!.photo!.photoLink);

      imageProvider
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((info, synchronousCall) {
        setState(() {
          _imageHeight = info.image.height;
          _imageWidth = info.image.width;
        });
      }));
    }

    return OrientationBuilder(builder: (context, orientation) {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.initialPoint.id != null
                  ? AppLocalizations.of(context)!.updateInspectionPoints
                  : AppLocalizations.of(context)!.createInspectionPoints,
            ),
            actions: [
              if (imageProvider != null && orientation == Orientation.landscape)
                ActionChip(
                    onPressed: goToDiagramSelectionScreen,
                    avatar: Icon(Icons.image_search),
                    label: Text(
                      AppLocalizations.of(context)!.changeDiagramButton,
                    ))
            ],
          ),
          floatingActionButton: FutureBuilder(
              future: _pendingSubmission,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return FloatingActionButton(
                    onPressed: isLoading ? null : submit,
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
            child: orientation == Orientation.portrait
                ? Column(
                    spacing: 8.0,
                    children: [
                      Row(
                        spacing: 8,
                        children: buildInputFields(context),
                      ),
                      if (widget.initialPoint.type ==
                          InspectionPointType.damage)
                        Expanded(
                            child: Column(spacing: 16.0, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.damageMarking,
                              ),
                              if (imageProvider != null)
                                ActionChip(
                                    onPressed: goToDiagramSelectionScreen,
                                    avatar: Icon(Icons.image_search),
                                    label: Text(
                                      AppLocalizations.of(context)!
                                          .changeDiagramButton,
                                    ))
                            ],
                          ),
                          if (imageProvider == null)
                            Expanded(child: buildEmptyDamageMarking(context))
                          else
                            buildDamageDiagramViewer(context, imageProvider),
                        ])),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 8.0,
                    children: [
                      if (widget.initialPoint.type ==
                          InspectionPointType.presentCondition)
                        ...buildInputFields(context, isExpanded: true),
                      if (widget.initialPoint.type ==
                          InspectionPointType.damage)
                        Flexible(
                          flex: 1,
                          child: Column(
                            spacing: 8.0,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                buildInputFields(context, isExpanded: false),
                          ),
                        ),
                      if (widget.initialPoint.type ==
                          InspectionPointType.damage)
                        Flexible(
                          flex: 2,
                          child: Column(
                            spacing: 8.0,
                            children: [
                              Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .damageMarking)),
                              Expanded(
                                  child: imageProvider == null
                                      ? buildEmptyDamageMarking(context)
                                      : buildDamageDiagramViewer(
                                          context, imageProvider)),
                              // if (imageProvider == null)
                              //   buildEmptyDamageMarking(context)
                              // else
                              //   buildDamageDiagramViewer(context, imageProvider)
                            ],
                          ),
                        )
                    ],
                  ),
          ));
    });
  }

  List<Widget> buildInputFields(BuildContext context,
      {bool isExpanded = true}) {
    return [
      isExpanded
          ? Expanded(
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.name),
                  border: const OutlineInputBorder(),
                ),
              ),
            )
          : TextField(
              controller: _nameController,
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.name),
                border: const OutlineInputBorder(),
              ),
            ),
      isExpanded
          ? Expanded(
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
            )
          : TextField(
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
      isExpanded
          ? Expanded(
              child: TextField(
                controller: _elementNumberController,
                decoration: InputDecoration(
                  label: Text(AppLocalizations.of(context)!.elementNumber),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            )
          : TextField(
              controller: _elementNumberController,
              decoration: InputDecoration(
                label: Text(AppLocalizations.of(context)!.elementNumber),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
    ];
  }

  Widget buildEmptyDamageMarking(context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.emptyDamageDiagramWarning),
        const SizedBox(
          height: 16.0,
        ),
        FilledButton(
            onPressed: goToDiagramSelectionScreen,
            child: Text(AppLocalizations.of(context)!.selectDiagramButton))
      ],
    ));
  }

  GestureDetector buildDamageDiagramViewer(
      BuildContext context, CachedNetworkImageProvider imageProvider) {
    return GestureDetector(
      onTapDown: (details) {
        Navigator.push(
                context,
                ImageMarkingViewOverlay(
                    imageProvider: imageProvider, originalMarking: _marking))
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
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          Positioned.fill(
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned(
                    top: _marking.y / _imageHeight * constraints.maxHeight,
                    left: _marking.x / _imageWidth * constraints.maxWidth,
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
    );
  }
}
