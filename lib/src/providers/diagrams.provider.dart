import 'package:flutter/material.dart';
import 'package:kyoryo/src/models/diagram.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'diagrams.provider.g.dart';

@riverpod
class Diagrams extends _$Diagrams {
  @override
  Future<List<Diagram>> build(int bridgeId) async {
    return ref.watch(apiServiceProvider).fetchDiagrams(bridgeId);
  }

  Future<Diagram> createDiagram(
      int bridgeId, String diagramPath, Orientation? orientation) async {
    final diagramPhoto = await ref
        .watch(apiServiceProvider)
        .uploadPhoto(diagramPath, compress: true);

    return await ref
        .watch(apiServiceProvider)
        .createDiagram(Diagram(bridgeId: bridgeId, photoId: diagramPhoto.id!));
  }
  
  Future<Diagram> updateDiagram(Diagram diagram) async {
    final updatedDiagram = await ref.watch(apiServiceProvider).updateDiagram(diagram);
    
    // Update the state with the new diagram
    final currentState = await future;
    state = AsyncData(currentState.map((d) => 
      d.id == updatedDiagram.id ? updatedDiagram : d
    ).toList());
    
    return updatedDiagram;
  }
}
