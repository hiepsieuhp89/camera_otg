import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/localization/app_localizations.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/providers/current_bridge.provider.dart';
import 'package:kyoryo/src/providers/damage_inspection.provider.dart';
import 'package:kyoryo/src/routing/router.dart';

@RoutePage()
class BridgeInspectionDamageScreen extends ConsumerStatefulWidget {
  const BridgeInspectionDamageScreen({super.key});

  @override
  ConsumerState<BridgeInspectionDamageScreen> createState() {
    return BridgeInspectionDamageScreenState();
  }
}

class BridgeInspectionDamageScreenState
    extends ConsumerState<BridgeInspectionDamageScreen> {
  @override
  Widget build(BuildContext context) {
    final data = ref
        .watch(damageInspectionProvider(ref.watch(currentBridgeProvider)!.id));

    return Container(
      child: data.whenOrNull(data: (data) {
        return DefaultTabController(
          length: data.sortedSpanNumbers.length,
          initialIndex: 0,
          child: Column(
            children: [
              TabBar(
                  tabs: data.sortedSpanNumbers.map((spanNumber) {
                return Tab(
                  text: spanNumber != ''
                      ? AppLocalizations.of(context)!.span(spanNumber)
                      : AppLocalizations.of(context)!.noSpan,
                );
              }).toList()),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TabBarView(
                      children: data.sortedSpanNumbers.map((spanNumber) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: .7,
                      ),
                      itemBuilder: (context, index) {
                        return LayoutBuilder(builder: (context, constraints) {
                          var cardSize = constraints.maxWidth;

                          return _DiagramItem(
                            size: cardSize,
                            diagram: data.diagramsBySpanNumbers[spanNumber]!
                                .elementAt(index),
                          );
                        });
                      },
                      itemCount:
                          data.diagramsBySpanNumbers[spanNumber]?.length ?? 0,
                    );
                  }).toList()),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DiagramItem extends ConsumerWidget {
  final double size;
  final Diagram diagram;

  const _DiagramItem({required this.size, required this.diagram});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref
        .watch(damageInspectionProvider(ref.watch(currentBridgeProvider)!.id))
        .maybeWhen(data: (data) => data, orElse: () => null);
        
    // Create a unique timestamp for this render to prevent caching issues
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueCacheKey = 'diagram_${diagram.id}_${diagram.photoId}_$timestamp';

    return GestureDetector(
      onTap: () async {
        // Before navigating, evict the current image from cache to ensure fresh load
        await CachedNetworkImage.evictFromCache(diagram.photo!.photoLink);
        
        await context.router.push(DiagramInspectionRoute(diagram: diagram));
        
        // After returning, refresh the damage inspection provider
        final currentBridge = ref.read(currentBridgeProvider);
        if (currentBridge != null) {
          // Clear image cache before invalidating providers
          await CachedNetworkImage.evictFromCache(diagram.photo!.photoLink);
          
          ref.invalidate(damageInspectionProvider(currentBridge.id));
        }
      },
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      key: ValueKey(uniqueCacheKey),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                          height: size,
                          width: size,
                          color: Theme.of(context).secondaryHeaderColor),
                      width: size,
                      height: size,
                      imageUrl: diagram.photo!.photoLink,
                      cacheKey: uniqueCacheKey,
                      // If image fails to load, show an error indicator
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error_outline, color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RichText(
                    overflow: TextOverflow.fade,
                    text: TextSpan(
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.finishedTasks(
                              state?.finishCountByDiagramIds[diagram.id] ?? 0,
                              state?.pointsByDiagramIds[diagram.id]?.length ??
                                  0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
