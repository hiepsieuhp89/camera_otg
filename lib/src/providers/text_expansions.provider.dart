import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kyoryo/src/models/text_expansion.dart';
import 'package:kyoryo/src/providers/api.provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'text_expansions.provider.g.dart';

@riverpod
Future<List<TextExpansion>> textExpansions(Ref ref) async {
  try {
    // Use the apiServiceProvider instead of creating a new ApiService instance
    final apiService = ref.watch(apiServiceProvider);
    final expansionsData = await apiService.fetchTextExpansions();
    
    final expansions = expansionsData
        .map((expansion) => TextExpansion.fromJson(expansion))
        .toList();
    
    debugPrint('Loaded ${expansions.length} text expansions from API');
    
    // If API returned data but parsing failed, provide fallback
    if (expansions.isEmpty) {
      debugPrint('API returned empty data for text expansions, using fallback data');
      return _getFallbackTextExpansions();
    }
    
    return expansions;
  } catch (e) {
    debugPrint('Error loading text expansions: $e');
    // Return fallback data in case of error
    return _getFallbackTextExpansions();
  }
}

// Fallback data to use when the API fails
List<TextExpansion> _getFallbackTextExpansions() {
  return [
  ];
} 