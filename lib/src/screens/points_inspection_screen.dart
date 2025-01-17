import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';

@RoutePage()
class PointsInspectionScreen extends ConsumerStatefulWidget {
  final List<int> pointIds;
  final String? details;

  const PointsInspectionScreen(
      {super.key, required this.pointIds, this.details});

  @override
  PointsInspectionScreenState createState() => PointsInspectionScreenState();
}

class PointsInspectionScreenState
    extends ConsumerState<PointsInspectionScreen> {
  @override
  Widget build(BuildContext context) {
    final currentBridge = ref.watch(currentBridgeProvider);

    return Scaffold(
        appBar: AppBar(
          title: Row(
            spacing: 8,
            children: <Widget>[
              Text(currentBridge?.nameKanji ?? ''),
              if (widget.details != null)
                Text(widget.details!,
                    style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        body: ref.watch(inspectionPointsProvider(currentBridge!.id)).when(
              data: (allPoints) {
                final points = allPoints
                    .where((point) => widget.pointIds.contains(point.id))
                    .toList();

                return RefreshIndicator(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ListView.builder(
                      key:
                          const PageStorageKey<String>('inspection-point-list'),
                      itemCount: points.length,
                      itemBuilder: (BuildContext context, int index) {
                        final point = points[index];

                        return InpsectionPointListItem(
                          point: point,
                        );
                      },
                    ),
                  ),
                  onRefresh: () => Future.wait([
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
                              .failedToGetInspectionPoints,
                          style: Theme.of(context).textTheme.bodySmall),
                      IconButton(
                        onPressed: () {
                          ref.invalidate(
                              inspectionPointsProvider(currentBridge.id));
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                );
              },
            ));
  }
}
