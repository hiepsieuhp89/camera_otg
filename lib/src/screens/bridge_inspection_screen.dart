import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/screens/inspection_point_diagram_select_screen.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';
import 'package:kyoryo/src/utilities/async_value_extensions.dart';

class InspectionPointFilter {
  const InspectionPointFilter(
      this.type, this.label, this.icon, this.selectedIcon);

  final InspectionPointType? type;
  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

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
  int selectedFilterIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _startInspectingPoint(InspectionPoint point,
      {InspectionPointReport? createdReport}) {
    Navigator.pushNamed(context, TakePictureScreen.routeName,
        arguments: TakePictureScreenArguments(
            inspectionPoint: point, createdReport: createdReport));
  }

  void _createNewInspectionPoint() {
    Navigator.of(context).pushNamed(
      InpsectionPointDiagramSelectScreen.routeName,
    );
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

    final List<InspectionPointFilter> filters = <InspectionPointFilter>[
      InspectionPointFilter(
          null,
          AppLocalizations.of(context)!.allInspection,
          const Icon(Icons.manage_search_outlined),
          const Icon(Icons.manage_search)),
      InspectionPointFilter(
          InspectionPointType.presentCondition,
          AppLocalizations.of(context)!.presentConditionInspection,
          const Icon(Icons.image_search_outlined),
          const Icon(Icons.image_search)),
      InspectionPointFilter(
          InspectionPointType.damage,
          AppLocalizations.of(context)!.damageInspection,
          const Icon(Icons.broken_image_outlined),
          const Icon(Icons.broken_image)),
    ];

    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: buildNavigationDrawer(filters, isInspectionInProgress),
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
                      selectedIndex: selectedFilterIndex,
                      labelType: isInspectionInProgress
                          ? NavigationRailLabelType.selected
                          : NavigationRailLabelType.all,
                      destinations: [
                        ...filters.map((filter) {
                          return NavigationRailDestination(
                              icon: filter.icon,
                              label: Text(filter.label),
                              selectedIcon: filter.selectedIcon);
                        }),
                        if (isInspectionInProgress)
                          NavigationRailDestination(
                              icon: const Icon(Icons.add_circle),
                              label:
                                  Text(AppLocalizations.of(context)!.newDamage))
                      ],
                      onDestinationSelected: (index) {
                        if (index == filters.length) {
                          _createNewInspectionPoint();
                          return;
                        }

                        setState(() {
                          selectedFilterIndex = index;
                        });

                        ref
                            .watch(currentInspectionPointTypeProvider.notifier)
                            .set(filters[selectedFilterIndex].type);
                      },
                      trailing: Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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

                              selectedFilterIndex = filters.indexWhere(
                                  (filter) => filter.type == value.first);

                              setState(() {});
                            },
                            selected: {
                              filters[selectedFilterIndex].type,
                            },
                            segments: filters.map((filter) {
                              return ButtonSegment<InspectionPointType?>(
                                label: Text(filter.label),
                                value: filter.type,
                                icon: filter.icon,
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

  BottomAppBar? buildBottomAppBar(
      AsyncValue<List<InspectionPoint>> inspectionPoints,
      int numberOfCreatedReports,
      bool isInspecting) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? BottomAppBar(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(isInspecting && inspectionPoints.value!.isNotEmpty
                    ? AppLocalizations.of(context)!.finishedTasks(
                        numberOfCreatedReports, inspectionPoints.value!.length)
                    : ''),
                Row(
                    children: isInspecting
                        ? [
                            IconButton(
                                onPressed: _createNewInspectionPoint,
                                icon: const Icon(Icons.broken_image_outlined)),
                          ]
                        : [])
              ],
            ),
          )
        : null;
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
      List<InspectionPointFilter> filters, bool isInspecting) {
    final filteredInspectionPoints = ref.watch(
        filteredInspectionPointsProvider(ref.watch(currentBridgeProvider)!.id));

    return MediaQuery.of(context).orientation == Orientation.landscape
        ? NavigationDrawer(
            selectedIndex: selectedFilterIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedFilterIndex = index;
              });

              ref
                  .watch(currentInspectionPointTypeProvider.notifier)
                  .set(filters[selectedFilterIndex].type);
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
                                onPressed: _createNewInspectionPoint,
                                child: Row(
                                  children: [
                                    const Icon(Icons.broken_image_outlined),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .createInspectionPoints,
                                        textAlign: TextAlign.center,
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
                ...filters.map((filter) {
                  return NavigationDrawerDestination(
                    label: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(filter.label),
                          Visibility(
                            visible:
                                selectedFilterIndex == filters.indexOf(filter),
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
                    icon: filter.icon,
                  );
                })
              ])
        : null;
  }
}
