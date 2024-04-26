import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Extension method to combine two [AsyncValue] objects into a single [AsyncValue] object.
/// The resulting [AsyncValue] object represents the combination of the values from the two input [AsyncValue] objects.
/// Ref: https://github.com/rrousselGit/riverpod/discussions/1722#discussioncomment-9097447
extension AsyncValueRecord2<T1, T2> on (AsyncValue<T1>, AsyncValue<T2>) {
  AsyncValue<(T1, T2)> get watch {
    if ($1.hasError) {
      return AsyncError($1.error!, $1.stackTrace!);
    }
    if ($2.hasError) {
      return AsyncError($2.error!, $2.stackTrace!);
    }

    if ($1.isLoading || $2.isLoading) {
      return const AsyncLoading();
    }

    return AsyncData(($1.requireValue, $2.requireValue));
  }
}
