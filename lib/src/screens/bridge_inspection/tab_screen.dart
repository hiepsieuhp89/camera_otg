import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/constants/inspection_point_type_ui.dart';
import 'package:kyoryo/src/models/inspection.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/bridge_inspection.provider.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_point_filters.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/ui/inspection_point_filters_form.dart';
import 'package:kyoryo/src/ui/side_sheet.dart';
import 'package:kyoryo/src/utilities/async_value_extensions.dart';

@RoutePage()
class BridgeInspectionTabScreen extends ConsumerStatefulWidget {
  const BridgeInspectionTabScreen({
    super.key,
  });

  @override
  ConsumerState<BridgeInspectionTabScreen> createState() =>
      BridgeInspectionTabScreenState();
}

class BridgeInspectionTabScreenState
    extends ConsumerState<BridgeInspectionTabScreen> {
  showFailureMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        showCloseIcon: true,
        content: Text(AppLocalizations.of(context)!.errorFinishingInspection),
      ),
    );
  }

  void _confirmFinishInspection() {
    final currentBridge = ref.watch(currentBridgeProvider);
    final numberOfCreatedReports =
        ref.watch(numberOfCreatedReportsProvider(currentBridge!.id));
    final inspectionPoints =
        ref.watch(inspectionPointsProvider(currentBridge.id));

    if (!inspectionPoints.hasValue) return;

    if (ref.watch(numberOfPendingReportsProvider(currentBridge.id)) > 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(AppLocalizations.of(context)!.pendingReportsWarning),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.yesOption),
              ),
            ],
          );
        },
      );

      return;
    }

    if (inspectionPoints.value!.length == numberOfCreatedReports) {
      ref
          .read(bridgeInspectionProvider(ref.read(currentBridgeProvider)!.id)
              .notifier)
          .setActiveInspectionFinished(true)
          .then((_) {
        ref.invalidate(inspectionPointsProvider(currentBridge.id));
        ref.invalidate(bridgeInspectionProvider(currentBridge.id));
      }).catchError((_) {
        showFailureMessage();
      });

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
                    .setActiveInspectionFinished(true)
                    .then((_) {
                  ref.invalidate(inspectionPointsProvider(currentBridge.id));
                  ref.invalidate(bridgeInspectionProvider(currentBridge.id));
                }).catchError((_) {
                  showFailureMessage();
                });
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
                    .setActiveInspectionFinished(false)
                    .catchError((_) {
                  showFailureMessage();
                });
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
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    final currentBridge = ref.watch(currentBridgeProvider);
    final filteredInspectionPoints =
        ref.watch(filteredInspectionPointsProvider(currentBridge!.id));
    final bridgeInspection =
        ref.watch(bridgeInspectionProvider(currentBridge.id));
    final isInspectionInProgress =
        ref.watch(isInspectionInProgressProvider(currentBridge.id));

    AsyncValue<(List<InspectionPoint>, List<Inspection?>)> requiredData =
        (filteredInspectionPoints, bridgeInspection).watch;

    return AutoTabsRouter(
      routes: const [
        BridgeInspectionAllRoute(),
        BridgeInspectionPresentConditionRoute(),
        BridgeInspectionDamageRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        onNavigationSelected(TabsRouter router, int index) {
          if (index == 0 || index == 1) {
            ref
                .read(bridgeInspectionPointFiltersProvider(currentBridge.id)
                    .notifier)
                .setTypeFilter(
                    index == 0 ? null : InspectionPointType.presentCondition);
          }

          router.setActiveIndex(index);
        }

        navigationRail() {
          return NavigationRail(
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
            selectedIndex: tabsRouter.activeIndex,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(allInspectionPointUI.icon),
                selectedIcon: Icon(allInspectionPointUI.selectedIcon),
                label: Text(allInspectionPointUI.label),
              ),
              NavigationRailDestination(
                icon: Icon(presentConditionPointUI.icon),
                selectedIcon: Icon(presentConditionPointUI.selectedIcon),
                label: Text(presentConditionPointUI.label),
              ),
              NavigationRailDestination(
                icon: Icon(damagePointUI.icon),
                selectedIcon: Icon(damagePointUI.selectedIcon),
                label: Text(damagePointUI.label),
              ),
            ],
            onDestinationSelected: (index) {
              onNavigationSelected(tabsRouter, index);
            },
            trailing: Expanded(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ]),
            ),
          );
        }

        topAppBar({required bool automaticallyImplyLeading}) {
          return AppBar(
            automaticallyImplyLeading: automaticallyImplyLeading,
            title: Row(
              children: <Widget>[
                Text(
                  currentBridge.nameKanji,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline_rounded)),
              ],
            ),
            actions: [
              if (tabsRouter.current.name != BridgeInspectionDamageRoute.name)
                IconButton(
                    onPressed: () {
                      showSideSheet(context,
                          headerText: AppLocalizations.of(context)!
                              .inspectionPointFilters,
                          body: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: InspectionPointFiltersForm(),
                          ));
                    },
                    icon: Icon(
                      Icons.filter_list,
                      color: ref
                              .watch(bridgeInspectionPointFiltersProvider(
                                  currentBridge.id))
                              .hasActiveFilters
                          ? Colors.orange
                          : null,
                    )),
            ],
          );
        }

        navigationDrawer() {
          final filteredInspectionPoints = ref.watch(
              filteredInspectionPointsProvider(
                  ref.watch(currentBridgeProvider)!.id));

          return MediaQuery.of(context).orientation == Orientation.landscape
              ? NavigationDrawer(
                  selectedIndex: tabsRouter.activeIndex,
                  onDestinationSelected: (int index) {
                    tabsRouter.setActiveIndex(index);
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                    style: ButtonStyle(
                                        padding: WidgetStateProperty.all(
                                            const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 12))),
                                    onPressed: isInspectionInProgress
                                        ? _confirmFinishInspection
                                        : _confirmForReinspection,
                                    child: Row(
                                      children: [
                                        isInspectionInProgress
                                            ? const Icon(Icons.check)
                                            : const Icon(Icons.replay_outlined),
                                        Expanded(
                                          child: Text(
                                            isInspectionInProgress
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
                            const Divider()
                          ],
                        ),
                      ),
                      NavigationDrawerDestination(
                        label: Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(damagePointUI.label),
                              Visibility(
                                visible: tabsRouter.activeIndex == 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24, left: 12),
                                  child: Text(filteredInspectionPoints
                                          .asData?.value.length
                                          .toString() ??
                                      ''),
                                ),
                              ),
                            ],
                          ),
                        ),
                        icon: Icon(damagePointUI.icon),
                      ),
                      NavigationDrawerDestination(
                        label: Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(presentConditionPointUI.label),
                              Visibility(
                                visible: tabsRouter.activeIndex == 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 24, left: 12),
                                  child: Text(filteredInspectionPoints
                                          .asData?.value.length
                                          .toString() ??
                                      ''),
                                ),
                              ),
                            ],
                          ),
                        ),
                        icon: Icon(presentConditionPointUI.icon),
                      ),
                      const SizedBox(height: 8),
                    ])
              : null;
        }

        bottomNavigationBar(TabsRouter tabsRouter) {
          return NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: (index) =>
                onNavigationSelected(tabsRouter, index),
            destinations: [
              NavigationDestination(
                label: allInspectionPointUI.label,
                icon: Icon(allInspectionPointUI.icon),
                selectedIcon: Icon(
                  allInspectionPointUI.selectedIcon,
                ),
              ),
              NavigationDestination(
                label: presentConditionPointUI.label,
                icon: Icon(presentConditionPointUI.icon),
                selectedIcon: Icon(
                  presentConditionPointUI.selectedIcon,
                ),
              ),
              NavigationDestination(
                label: damagePointUI.label,
                icon: Icon(damagePointUI.icon),
                selectedIcon: Icon(
                  damagePointUI.selectedIcon,
                ),
              )
            ],
          );
        }

        content() {
          return requiredData.when(
            data: (data) {
              return RefreshIndicator(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: child,
                ),
                onRefresh: () => Future.wait([
                  ref.refresh(
                      bridgeInspectionProvider(currentBridge.id).future),
                  ref.refresh(
                      inspectionPointsProvider(currentBridge.id).future),
                ]),
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
                        style: Theme.of(context).textTheme.bodySmall),
                    IconButton(
                      onPressed: () {
                        ref.invalidate(
                            inspectionPointsProvider(currentBridge.id));
                        ref.invalidate(
                            bridgeInspectionProvider(currentBridge.id));
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
              key: scaffoldKey,
              drawer: navigationDrawer(),
              appBar: orientation == Orientation.portrait
                  ? topAppBar(automaticallyImplyLeading: true)
                  : null,
              bottomNavigationBar: orientation == Orientation.portrait
                  ? bottomNavigationBar(tabsRouter)
                  : null,
              floatingActionButton: orientation == Orientation.portrait
                  ? FloatingActionButton(
                      heroTag: 'bottom_button',
                      elevation: 0,
                      onPressed: isInspectionInProgress
                          ? _confirmFinishInspection
                          : _confirmForReinspection,
                      child: isInspectionInProgress
                          ? const Icon(Icons.check)
                          : const Icon(Icons.replay_outlined),
                    )
                  : null,
              body: OrientationBuilder(builder: ((context, orientation) {
                if (orientation == Orientation.portrait) {
                  return Column(
                    children: [
                      Expanded(
                        child: content(),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      navigationRail(),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: Column(
                          children: [
                            Visibility(
                              visible: orientation == Orientation.landscape &&
                                  tabsRouter.activeIndex != 2,
                              child:
                                  topAppBar(automaticallyImplyLeading: false),
                            ),
                            Expanded(
                              child: content(),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              })),
            );
          },
        );
      },
    );
  }
}
