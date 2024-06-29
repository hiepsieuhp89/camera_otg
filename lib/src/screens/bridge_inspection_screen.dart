import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/constants/inspection_point_type_ui.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/screens/inspection_point_creation_screen.dart';
import 'package:kyoryo/src/screens/inspection_point_diagram_select_screen.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';
import 'package:kyoryo/src/utilities/async_value_extensions.dart';

class BridgeInspectionScreen extends ConsumerStatefulWidget {
  const BridgeInspectionScreen({
    super.key,
  });

  static const routeName = '/bridge-inspection';

  @override
  ConsumerState<BridgeInspectionScreen> createState() =>
      _BridgeInspectionScreenState();
}

class _BridgeInspectionScreenState
    extends ConsumerState<BridgeInspectionScreen> {
  int selectedTypeIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _startInspectingPoint(InspectionPoint point,
      {InspectionPointReport? createdReport}) {
    Navigator.pushNamed(context, TakePictureScreen.routeName,
        arguments: TakePictureScreenArguments(
            inspectionPoint: point, createdReport: createdReport));
  }

  void _createNewInspectionPoint(InspectionPointType type) {
    if (type == InspectionPointType.presentCondition) {
      Navigator.of(context).pushNamed(InspectionPointCreationScreen.routeName,
          arguments: InspectionPointCreationScreenArguments(pointType: type));
    } else {
      Navigator.of(context).pushNamed(
        InpsectionPointDiagramSelectScreen.routeName,
      );
    }
  }

  void _confirmFinishInspection() {
    final currentBridge = ref.watch(currentBridgeProvider);
    final numberOfCreatedReports =
        ref.watch(numberOfCreatedReportsProvider(currentBridge!.id));
    final inspectionPoints =
        ref.watch(inspectionPointsProvider(currentBridge.id));

    if (!inspectionPoints.hasValue) return;

    if (inspectionPoints.value!.length == numberOfCreatedReports) {
      ref
          .read(bridgeInspectionProvider(ref.read(currentBridgeProvider)!.id)
              .notifier)
          .setActiveInspectionFinished(true);

      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.finishInspectionConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.noOption),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref
                    .read(bridgeInspectionProvider(
                            ref.read(currentBridgeProvider)!.id)
                        .notifier)
                    .setActiveInspectionFinished(true);
              },
              child: Text(AppLocalizations.of(context)!.yesOption),
            ),
          ],
        );
      },
    );
  }

  void _confirmForReinspection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(AppLocalizations.of(context)!.backToInspectingConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.noOption),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref
                    .read(bridgeInspectionProvider(
                            ref.read(currentBridgeProvider)!.id)
                        .notifier)
                    .setActiveInspectionFinished(false);
              },
              child: Text(AppLocalizations.of(context)!.yesOption),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBridge = ref.watch(currentBridgeProvider);
    final numberOfCreatedReports =
        ref.watch(numberOfCreatedReportsProvider(currentBridge!.id));
    final inspectionPoints =
        ref.watch(inspectionPointsProvider(currentBridge.id));
    final filteredInspectionPoints =
        ref.watch(filteredInspectionPointsProvider(currentBridge.id));
    final bridgeInspection =
        ref.watch(bridgeInspectionProvider(currentBridge.id));
    final isInspectionInProgress =
        ref.watch(isInspectionInProgressProvider(currentBridge.id));

    AsyncValue<(List<InspectionPoint>, List<Inspection?>)> requiredData =
        (filteredInspectionPoints, bridgeInspection).watch;

    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: buildNavigationDrawer(
            inspectionPointTypeUIs, isInspectionInProgress),
        appBar: buildAppBar(currentBridge),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Row(
              children: [
                Visibility(
                  visible: orientation == Orientation.landscape,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: NavigationRail(
                      minWidth: 50,
                      leading: Column(children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            scaffoldKey.currentState!.openDrawer();
                          },
                        ),
                        isInspectionInProgress
                            ? FloatingActionButton(
                                elevation: 0,
                                onPressed: _confirmFinishInspection,
                                child: const Icon(Icons.check))
                            : FloatingActionButton(
                                elevation: 0,
                                onPressed: _confirmForReinspection,
                                child: const Icon(Icons.replay_outlined),
                              ),
                      ]),
                      selectedIndex: selectedTypeIndex,
                      labelType: isInspectionInProgress
                          ? NavigationRailLabelType.selected
                          : NavigationRailLabelType.all,
                      destinations: [
                        ...inspectionPointTypeUIs.map((filter) {
                          return NavigationRailDestination(
                              icon: Icon(filter.icon),
                              label: Text(filter.label),
                              selectedIcon: Icon(filter.selectedIcon));
                        }),
                      ],
                      onDestinationSelected: (index) {
                        setState(() {
                          selectedTypeIndex = index;
                        });

                        ref
                            .watch(currentInspectionPointTypeProvider.notifier)
                            .set(
                                inspectionPointTypeUIs[selectedTypeIndex].type);
                      },
                      trailing: Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (isInspectionInProgress)
                                buildNewPointMenuButton(),
                              IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ]),
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Column(
                    children: [
                      Visibility(
                        visible: orientation == Orientation.portrait,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SegmentedButton<InspectionPointType?>(
                            onSelectionChanged:
                                (Set<InspectionPointType?> value) {
                              ref
                                  .watch(currentInspectionPointTypeProvider
                                      .notifier)
                                  .set(value.first);

                              selectedTypeIndex =
                                  inspectionPointTypeUIs.indexWhere(
                                      (filter) => filter.type == value.first);

                              setState(() {});
                            },
                            selected: {
                              inspectionPointTypeUIs[selectedTypeIndex].type,
                            },
                            segments: inspectionPointTypeUIs.map((filter) {
                              return ButtonSegment<InspectionPointType?>(
                                label: Text(filter.label),
                                value: filter.type,
                                icon: Icon(filter.icon),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: requiredData.when(
                          data: (data) {
                            return RefreshIndicator(
                              onRefresh: () => Future.wait([
                                ref.refresh(
                                    bridgeInspectionProvider(currentBridge.id)
                                        .future),
                                ref.refresh(
                                    inspectionPointsProvider(currentBridge.id)
                                        .future),
                              ]),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        orientation == Orientation.portrait
                                            ? 1
                                            : 2,
                                    mainAxisExtent: 232,
                                    mainAxisSpacing: 8.0,
                                    crossAxisSpacing: 8.0,
                                  ),
                                  itemCount: data.$1.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final point = data.$1[index];

                                    return InpsectionPointListItem(
                                      point: point,
                                      startInspect: _startInspectingPoint,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stackTrace) {
                            debugPrint('Error: $error, $stackTrace');

                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      AppLocalizations.of(context)!
                                          .failedToCreateInspectionReport,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  IconButton(
                                    onPressed: () {
                                      ref.invalidate(inspectionPointsProvider(
                                          currentBridge.id));
                                      ref.invalidate(bridgeInspectionProvider(
                                          currentBridge.id));
                                    },
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
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: buildBottomAppBar(
            inspectionPoints, numberOfCreatedReports, isInspectionInProgress));
  }

  Widget buildNewPointMenuButton() {
    return MenuAnchor(
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.add_circle),
          );
        },
        menuChildren: [
          MenuItemButton(
              onPressed: () =>
                  _createNewInspectionPoint(presentConditionPointUI.type!),
              child: Row(
                children: [
                  Icon(presentConditionPointUI.icon),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(presentConditionPointUI.label)
                ],
              )),
          MenuItemButton(
              onPressed: () => _createNewInspectionPoint(damagePointUI.type!),
              child: Row(
                children: [
                  Icon(damagePointUI.icon),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(damagePointUI.label)
                ],
              ))
        ]);
  }

  BottomAppBar? buildBottomAppBar(
      AsyncValue<List<InspectionPoint>> inspectionPoints,
      int numberOfCreatedReports,
      bool isInspecting) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return null;
    }

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(isInspecting && inspectionPoints.value!.isNotEmpty
              ? AppLocalizations.of(context)!.finishedTasks(
                  numberOfCreatedReports, inspectionPoints.value!.length)
              : ''),
          Row(children: [
            if (isInspecting) buildNewPointMenuButton(),
            if (isInspecting)
              FilledButton.icon(
                onPressed: _confirmFinishInspection,
                icon: const Icon(Icons.check),
                label: Text(AppLocalizations.of(context)!.finishInspection),
              )
            else
              FilledButton.icon(
                onPressed: _confirmForReinspection,
                icon: const Icon(Icons.replay_outlined),
                label: Text(AppLocalizations.of(context)!.backToInspecting),
              )
          ])
        ],
      ),
    );
  }

  AppBar? buildAppBar(Bridge currentBridge) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? AppBar(
            title: Row(
            children: <Widget>[
              Text(currentBridge.nameKanji),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline_rounded)),
            ],
          ))
        : null;
  }

  Widget? buildNavigationDrawer(
      List<InspectionPointTypeUI> pointTypeUIs, bool isInspecting) {
    final filteredInspectionPoints = ref.watch(
        filteredInspectionPointsProvider(ref.watch(currentBridgeProvider)!.id));

    return MediaQuery.of(context).orientation == Orientation.landscape
        ? NavigationDrawer(
            selectedIndex: selectedTypeIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedTypeIndex = index;
              });

              ref
                  .watch(currentInspectionPointTypeProvider.notifier)
                  .set(pointTypeUIs[selectedTypeIndex].type);
            },
            children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Row(
                    children: <Widget>[
                      Text(ref.watch(currentBridgeProvider)!.nameKanji),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.info_outline_rounded)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                              style: ButtonStyle(
                                  padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12))),
                              onPressed: isInspecting
                                  ? _confirmFinishInspection
                                  : _confirmForReinspection,
                              child: Row(
                                children: [
                                  isInspecting
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.replay_outlined),
                                  Expanded(
                                    child: Text(
                                      isInspecting
                                          ? AppLocalizations.of(context)!
                                              .finishInspection
                                          : AppLocalizations.of(context)!
                                              .backToInspecting,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                ],
                              )),
                        ),
                      ),
                      Visibility(
                        visible: isInspecting,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                                style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 12))),
                                onPressed: () => _createNewInspectionPoint(
                                    presentConditionPointUI.type!),
                                child: Row(
                                  children: [
                                    Icon(presentConditionPointUI.icon),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .createPresentConditionInspectionPoint,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isInspecting,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                                style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 12))),
                                onPressed: () => _createNewInspectionPoint(
                                    damagePointUI.type!),
                                child: Row(
                                  children: [
                                    Icon(damagePointUI.icon),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .createDamageInspectionPoint,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      const Divider()
                    ],
                  ),
                ),
                ...inspectionPointTypeUIs.map((pointTypeUI) {
                  return NavigationDrawerDestination(
                    label: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(pointTypeUI.label),
                          Visibility(
                            visible: selectedTypeIndex ==
                                inspectionPointTypeUIs.indexOf(pointTypeUI),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(right: 24, left: 12),
                              child: Text(filteredInspectionPoints
                                      .asData?.value.length
                                      .toString() ??
                                  ''),
                            ),
                          ),
                        ],
                      ),
                    ),
                    icon: Icon(pointTypeUI.icon),
                  );
                })
              ])
        : null;
  }
}
