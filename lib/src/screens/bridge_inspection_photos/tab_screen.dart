import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/providers/current_photo_inspection_result.provider.dart';
import 'package:kyoryo/src/routing/router.dart';

@RoutePage()
class BridgeInspectionPhotosTabScreen extends ConsumerWidget {
  final InspectionPoint point;

  const BridgeInspectionPhotosTabScreen({super.key, required this.point});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoInspectionResult =
        ref.watch(currentPhotoInspectionResultProvider);

    onNavigationSelected(TabsRouter router, int index) {
      if (index == 2) {
        context.router
            .popUntil((route) => route.settings.name == TakePictureRoute.name);
        return;
      }
      router.setActiveIndex(index);
    }

    navigationRail(TabsRouter tabsRouter) {
      return NavigationRail(
        selectedIndex: tabsRouter.activeIndex,
        leading: Column(
          children: [
            IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context, photoInspectionResult);
                }),
            FloatingActionButton(
              heroTag: 'rail_button',
              elevation: 0,
              onPressed: () {
                context.router
                    .replace(BridgeInspectionEvaluationRoute(point: point));
              },
              child: const Icon(Icons.check),
            ),
            const SizedBox(height: 16)
          ],
        ),
        labelType: NavigationRailLabelType.all,
        onDestinationSelected: (int index) {
          onNavigationSelected(tabsRouter, index);
        },
        destinations: [
          NavigationRailDestination(
              icon: const Icon(Icons.compare_outlined),
              selectedIcon: const Icon(Icons.compare),
              label: Text(AppLocalizations.of(context)!.comparePhotos)),
          NavigationRailDestination(
              icon: const Icon(Icons.checklist_outlined),
              selectedIcon: const Icon(Icons.checklist),
              label: Text(AppLocalizations.of(context)!.selectPhoto)),
          NavigationRailDestination(
              icon: const Icon(Icons.camera_alt_outlined),
              selectedIcon: const Icon(Icons.camera_alt),
              label: Text(AppLocalizations.of(context)!.takePhoto)),
        ],
      );
    }

    buildBottomNavigationBar(TabsRouter tabsRouter) {
      return BottomNavigationBar(
        currentIndex: tabsRouter.activeIndex,
        onTap: (index) {
          onNavigationSelected(tabsRouter, index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.compare_outlined),
            label: AppLocalizations.of(context)!.comparePhotos,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.format_list_numbered_outlined),
            label: AppLocalizations.of(context)!.selectPhoto,
          ),
        ],
      );
    }

    return AutoTabsRouter(
      routes: [
        BridgeInspectionPhotoComparisonRoute(point: point),
        const BridgeInspectionPhotoSelectionRoute(),
      ],
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (context, child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPope, _) {
            if (!didPope) {
              Navigator.pop(context, photoInspectionResult);
            }
          },
          child: OrientationBuilder(builder: (context, orientation) {
            return Scaffold(
              appBar: orientation == Orientation.portrait
                  ? AppBar(
                      title: tabsRouter.activeIndex == 0
                          ? Text(AppLocalizations.of(context)!.comparePhotos)
                          : Text(AppLocalizations.of(context)!.selectPhoto),
                    )
                  : null,
              floatingActionButton: orientation == Orientation.portrait
                  ? FloatingActionButton(
                      heroTag: 'bottom_button',
                      elevation: 0,
                      onPressed: () {
                        context.router.replace(
                            BridgeInspectionEvaluationRoute(point: point));
                      },
                      child: const Icon(Icons.check),
                    )
                  : null,
              bottomNavigationBar: orientation == Orientation.portrait
                  ? buildBottomNavigationBar(tabsRouter)
                  : null,
              body: OrientationBuilder(builder: ((context, orientation) {
                if (orientation == Orientation.portrait) {
                  return Column(
                    children: [
                      Expanded(
                        child: child,
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      navigationRail(tabsRouter),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(child: child),
                    ],
                  );
                }
              })),
            );
          }),
        );
      },
    );
  }
}
