import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';
import 'package:kyoryo/src/routing/router.dart';
import 'package:kyoryo/src/ui/inspection_point_list_item.dart';

@RoutePage()
class BridgeInspectionPresentConditionScreen extends ConsumerWidget {
  const BridgeInspectionPresentConditionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredInspectionPoints = ref.watch(
        filteredInspectionPointsProvider(ref.watch(currentBridgeProvider)!.id));

    return Container(child: filteredInspectionPoints.whenOrNull(data: (points) {
      return ListView.builder(
        key: const PageStorageKey<String>(
            'present-condition-inspection-point-list'),
        padding: const EdgeInsets.only(bottom: 78),
        itemCount: points.length,
        itemBuilder: (BuildContext context, int index) {
          final point = points[index];

          return InpsectionPointListItem(
            point: point,
            startInspect: (InspectionPoint point,
                {InspectionPointReport? createdReport}) {
              context.pushRoute(TakePictureRoute(
                  inspectionPoint: point, createdReport: createdReport));
            },
          );
        },
      );
    }));
  }
}
