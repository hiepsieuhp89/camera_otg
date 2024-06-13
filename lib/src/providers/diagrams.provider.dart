import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/services/bridge.service.dart';
import 'package:kyoryo/src/services/photo.service.dart';
import 'package:kyoryo/src/utilities/image_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diagrams.provider.g.dart';

@riverpod
class Diagrams extends _$Diagrams {
  @override
  Future<List<Diagram>> build(int bridgeId) async {
    return ref.watch(bridgeServiceProvider).fetchDiagrams(bridgeId);
  }

  Future<Diagram> createDiagram(
      int bridgeId, String diagramPath, Orientation? orientation) async {
    await compressImage(diagramPath, quality: 70);
    final diagramPhoto =
        await ref.watch(photoServiceProvider).uploadPhoto(diagramPath);

    return await ref
        .watch(bridgeServiceProvider)
        .createDiagram(Diagram(bridgeId: bridgeId, photoId: diagramPhoto.id!));
  }
}
