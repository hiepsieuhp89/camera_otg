import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';

class BridgeInspectionScreenArguments {
  final Bridge bridge;

  BridgeInspectionScreenArguments({required this.bridge});
}

class BridgeInspectionScreen extends ConsumerStatefulWidget {
  const BridgeInspectionScreen({
    super.key,
    required this.arguments,
  });

  final BridgeInspectionScreenArguments arguments;
  static const routeName = '/bridge-inspection';

  @override
  ConsumerState<BridgeInspectionScreen> createState() =>
      _BridgeInspectionScreenState();
}

class _BridgeInspectionScreenState
    extends ConsumerState<BridgeInspectionScreen> {
  bool _isInspecting = false;

  void _startInspectingPoint(InspectionPoint point) {
    Navigator.pushNamed(context, TakePictureScreen.routeName, arguments: point);
  }

  void _startInspecting() {
    setState(() {
      _isInspecting = true;
    });
  }

  void _stopInspecting() {
    ref
        .watch(bridgeInspectionProvider(widget.arguments.bridge.id!).notifier)
        .clearInspection();
    setState(() {
      _isInspecting = false;
    });
  }

  Future<void> _confirmCancelDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.cancelInspection),
          content: SingleChildScrollView(
            child: Text(AppLocalizations.of(context)!.cancelInspectionConfirm),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
                _stopInspecting();
              },
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.continueInspecting)),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final numberOfCreatedReports =
        ref.watch(numberOfCreatedReportsProvider(widget.arguments.bridge.id!));
    final inspectionPoints =
        ref.watch(inspectionPointsProvider(widget.arguments.bridge.id!));
    final filteredInspectionPoints = ref
        .watch(filteredInspectionPointsProvider(widget.arguments.bridge.id!));

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Row(
          children: <Widget>[
            Text(widget.arguments.bridge.nameKanji),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.info_outline_rounded)),
          ],
        )),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SegmentedButton<InspectionPointType?>(
                onSelectionChanged: (Set<InspectionPointType?> value) {
                  ref
                      .watch(currentInspectionPointTypeProvider.notifier)
                      .set(value.first);
                },
                selected: {ref.read(currentInspectionPointTypeProvider)},
                segments: [
                  ButtonSegment<InspectionPointType?>(
                      label: Text(AppLocalizations.of(context)!.allInspection),
                      value: null),
                  ButtonSegment<InspectionPointType?>(
                    label: Text(AppLocalizations.of(context)!
                        .presentConditionInspection),
                    value: InspectionPointType.presentCondition,
                  ),
                  ButtonSegment<InspectionPointType?>(
                    label: Text(AppLocalizations.of(context)!.damageInspection),
                    value: InspectionPointType.damage,
                  )
                ],
              ),
            ),
            Expanded(
              child: filteredInspectionPoints.when(
                data: (data) {
                  return ListView.builder(
                    restorationId: 'inspectionPointListView',
                    itemCount: data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final point = data[index];

                      return InpsectionPointListItem(
                        point: point,
                        bridge: widget.arguments.bridge,
                        isInspecting: _isInspecting,
                        startInspect: _startInspectingPoint,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) {
                  debugPrint('Error: $error');

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            AppLocalizations.of(context)!
                                .failedToCreateInspectionReport,
                            style: Theme.of(context).textTheme.bodySmall),
                        IconButton(
                          onPressed: () => ref.invalidate(
                              inspectionPointsProvider(
                                  widget.arguments.bridge.id!)),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          clipBehavior: Clip.none,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_isInspecting && inspectionPoints.value!.isNotEmpty
                  ? AppLocalizations.of(context)!.finishedTasks(
                      numberOfCreatedReports, inspectionPoints.value!.length)
                  : ''),
              Row(
                children: _isInspecting
                    ? [
                        IconButton(
                            onPressed: _confirmCancelDialog,
                            icon: const Icon(Icons.close)),
                        FilledButton.icon(
                            onPressed: numberOfCreatedReports ==
                                    inspectionPoints.value!.length
                                ? _stopInspecting
                                : null,
                            icon: const Icon(Icons.check),
                            label: Text(
                                AppLocalizations.of(context)!.finishInspection))
                      ]
                    : [
                        FilledButton.icon(
                          onPressed: _startInspecting,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                              AppLocalizations.of(context)!.startInspection),
                        )
                      ],
              )
            ],
          ),
        ));
  }
}
