import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kyoryo/src/models/bridge.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/screens/inspection_point_diagram_select_screen.dart';
import 'package:kyoryo/src/screens/take_picture_screen.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';

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
  bool isInspecting = false;
  int selectedFilterIndex = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void _startInspectingPoint(InspectionPoint point) {
    Navigator.pushNamed(context, TakePictureScreen.routeName, arguments: point);
  }

  void _startInspecting() {
    setState(() {
      isInspecting = true;
    });
  }

  void _stopInspecting() {
    ref
        .watch(bridgeInspectionProvider(ref.watch(currentBridgeProvider)!.id)
            .notifier)
        .clearInspection();

    setState(() {
      isInspecting = false;
    });
  }

  void _endInspection() {
    final ended = ref
        .watch(bridgeInspectionProvider(ref.watch(currentBridgeProvider)!.id)
            .notifier)
        .endInspection();

    if (ended) {
      setState(() {
        isInspecting = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          showCloseIcon: true,
          content: Text(
              AppLocalizations.of(context)!.pleaseFinishAllInspectionPoints)));
    }
  }

  void _createNewInspectionPoint() {
    Navigator.of(context).pushNamed(
      InpsectionPointDiagramSelectScreen.routeName,
    );
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
    final currentBridge = ref.watch(currentBridgeProvider);
    final numberOfCreatedReports =
        ref.watch(numberOfCreatedReportsProvider(currentBridge!.id));
    final inspectionPoints =
        ref.watch(inspectionPointsProvider(currentBridge.id));
    final filteredInspectionPoints =
        ref.watch(filteredInspectionPointsProvider(currentBridge.id));

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
        drawer: buildNavigationDrawer(filters),
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
                        isInspecting
                            ? FloatingActionButton(
                                elevation: 0,
                                onPressed: _endInspection,
                                child: const Icon(Icons.check))
                            : FloatingActionButton(
                                elevation: 0,
                                onPressed: _startInspecting,
                                child: const Icon(Icons.play_arrow),
                              ),
                      ]),
                      selectedIndex: isInspecting ? null : selectedFilterIndex,
                      labelType: isInspecting
                          ? NavigationRailLabelType.none
                          : NavigationRailLabelType.all,
                      destinations: isInspecting
                          ? [
                              NavigationRailDestination(
                                  icon: const Icon(Icons.close),
                                  label: Text(AppLocalizations.of(context)!
                                      .cancelInspection)),
                              NavigationRailDestination(
                                  icon: const Icon(Icons.broken_image_outlined),
                                  label: Text(AppLocalizations.of(context)!
                                      .createInspectionPoints)),
                            ]
                          : filters.map((filter) {
                              return NavigationRailDestination(
                                  icon: filter.icon,
                                  label: Text(filter.label),
                                  selectedIcon: filter.selectedIcon);
                            }).toList(),
                      onDestinationSelected: (index) {
                        if (isInspecting) {
                          if (index == 0) {
                            _confirmCancelDialog();
                          } else {
                            _createNewInspectionPoint();
                          }
                        } else {
                          setState(() {
                            selectedFilterIndex = index;
                          });

                          ref
                              .watch(
                                  currentInspectionPointTypeProvider.notifier)
                              .set(filters[selectedFilterIndex].type);
                        }
                      },
                      trailing: Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Visibility(
                                  visible: isInspecting,
                                  child: PopupMenuButton<InspectionPointFilter>(
                                    initialValue: filters[selectedFilterIndex],
                                    onSelected: (filter) {
                                      ref
                                          .watch(
                                              currentInspectionPointTypeProvider
                                                  .notifier)
                                          .set(filter.type);

                                      selectedFilterIndex =
                                          filters.indexOf((filter));
                                      setState(() {});
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return filters.map((filter) {
                                        return PopupMenuItem<
                                                InspectionPointFilter>(
                                            value: filter,
                                            child: ListTile(
                                              title: Text(filter.label),
                                              leading: filter.icon,
                                            ));
                                      }).toList();
                                    },
                                    icon: const Icon(Icons.more_horiz),
                                  )),
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
                        child: filteredInspectionPoints.when(
                          data: (data) {
                            return Padding(
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
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final point = data[index];

                                  return InpsectionPointListItem(
                                    point: point,
                                    isInspecting: isInspecting,
                                    startInspect: _startInspectingPoint,
                                  );
                                },
                              ),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  IconButton(
                                    onPressed: () => ref.invalidate(
                                        inspectionPointsProvider(ref
                                            .watch(currentBridgeProvider)!
                                            .id)),
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
        bottomNavigationBar:
            buildBottomAppBar(inspectionPoints, numberOfCreatedReports));
  }

  BottomAppBar? buildBottomAppBar(
      AsyncValue<List<InspectionPoint>> inspectionPoints,
      int numberOfCreatedReports) {
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
                              onPressed: _confirmCancelDialog,
                              icon: const Icon(Icons.close)),
                          IconButton(
                              onPressed: _createNewInspectionPoint,
                              icon: const Icon(Icons.broken_image_outlined)),
                          FilledButton.icon(
                              onPressed: numberOfCreatedReports ==
                                      inspectionPoints.value!.length
                                  ? _stopInspecting
                                  : null,
                              icon: const Icon(Icons.check),
                              label: Text(AppLocalizations.of(context)!
                                  .finishInspection))
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

  Widget? buildNavigationDrawer(List<InspectionPointFilter> filters) {
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12))),
                              onPressed: isInspecting
                                  ? _endInspection
                                  : _startInspecting,
                              child: Row(
                                children: [
                                  isInspecting
                                      ? const Icon(Icons.check)
                                      : const Icon(Icons.play_arrow),
                                  Expanded(
                                    child: Text(
                                      isInspecting
                                          ? AppLocalizations.of(context)!
                                              .finishInspection
                                          : AppLocalizations.of(context)!
                                              .startInspection,
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
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 12))),
                                onPressed: _confirmCancelDialog,
                                child: Row(
                                  children: [
                                    const Icon(Icons.close),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .cancelInspection,
                                        textAlign: TextAlign.center,
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
                                    padding: MaterialStateProperty.all(
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
