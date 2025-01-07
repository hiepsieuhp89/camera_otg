import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/inspection_point_filters.provider.dart';
import 'package:kyoryo/src/providers/inspection_points.provider.dart';

class InspectionPointFiltersForm extends ConsumerWidget {
  const InspectionPointFiltersForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBridge = ref.watch(currentBridgeProvider);

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.assessment, color: Theme.of(context).primaryColor),
            const SizedBox(
              width: 4.0,
            ),
            Text(AppLocalizations.of(context)!.inspectionStatus,
                textAlign: TextAlign.start,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        Wrap(
          spacing: 8.0,
          runAlignment: WrapAlignment.start,
          children: [
            FilterChip(
              label: Text(AppLocalizations.of(context)!.statusNotInspected),
              selected: ref
                  .watch(
                      bridgeInspectionPointFiltersProvider(currentBridge!.id))
                  .includeNoReport,
              onSelected: (bool selected) {
                ref
                    .read(bridgeInspectionPointFiltersProvider(currentBridge.id)
                        .notifier)
                    .setIncludeNoReport(selected);
              },
            ),
            FilterChip(
              label: Text(AppLocalizations.of(context)!.statusSkipped),
              selected: ref
                          .watch(bridgeInspectionPointFiltersProvider(
                              currentBridge.id))
                          .reportStatusFilters[
                      InspectionPointReportStatus.skipped] ??
                  false,
              onSelected: (bool selected) {
                ref
                    .read(bridgeInspectionPointFiltersProvider(currentBridge.id)
                        .notifier)
                    .setStatusFilter(
                        InspectionPointReportStatus.skipped, selected);
              },
            ),
            FilterChip(
              label: Text(AppLocalizations.of(context)!.statusOnHold),
              selected: ref
                          .watch(bridgeInspectionPointFiltersProvider(
                              currentBridge.id))
                          .reportStatusFilters[
                      InspectionPointReportStatus.pending] ??
                  false,
              onSelected: (bool selected) {
                ref
                    .read(bridgeInspectionPointFiltersProvider(currentBridge.id)
                        .notifier)
                    .setStatusFilter(
                        InspectionPointReportStatus.pending, selected);
              },
            ),
            FilterChip(
              label: Text(AppLocalizations.of(context)!.statusFinished),
              selected: ref
                          .watch(bridgeInspectionPointFiltersProvider(
                              currentBridge.id))
                          .reportStatusFilters[
                      InspectionPointReportStatus.finished] ??
                  false,
              onSelected: (bool selected) {
                ref
                    .read(bridgeInspectionPointFiltersProvider(currentBridge.id)
                        .notifier)
                    .setStatusFilter(
                        InspectionPointReportStatus.finished, selected);
              },
            ),
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        Row(
          children: [
            Icon(Icons.place, color: Theme.of(context).primaryColor),
            const SizedBox(
              width: 4.0,
            ),
            Text(AppLocalizations.of(context)!.name,
                textAlign: TextAlign.start,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        Expanded(
          child: ref
              .watch(inspectionPointsProvider(currentBridge.id))
              .maybeWhen<Widget>(
                orElse: () => const SizedBox(height: 0),
                data: (inspectionPoints) {
                  final spanNames = inspectionPoints
                      .map((e) => e.spanName ?? '')
                      .toSet()
                      .toList();

                  return ListView.builder(
                    itemCount: spanNames.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CheckboxListTile(
                            title: const Text('ALL'),
                            controlAffinity: ListTileControlAffinity.leading,
                            value: ref
                                .watch(bridgeInspectionPointFiltersProvider(
                                    currentBridge.id))
                                .nameFilters
                                .isEmpty,
                            onChanged: (bool? checked) {
                              if (checked == true) {
                                ref
                                    .read(bridgeInspectionPointFiltersProvider(
                                            currentBridge.id)
                                        .notifier)
                                    .clearNameFilters();
                              }
                            });
                      }
                      return CheckboxListTile(
                          title: Text(spanNames[index - 1]),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: ref
                              .watch(bridgeInspectionPointFiltersProvider(
                                  currentBridge.id))
                              .nameFilters
                              .contains(spanNames[index - 1]),
                          onChanged: (bool? checked) {
                            ref
                                .read(bridgeInspectionPointFiltersProvider(
                                        currentBridge.id)
                                    .notifier)
                                .setNameFilter(
                                    spanNames[index - 1], checked ?? false);
                          });
                    },
                  );
                },
              ),
        )
      ],
    );
  }
}
