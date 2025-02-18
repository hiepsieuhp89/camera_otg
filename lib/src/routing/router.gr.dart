// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AppUpdateScreen]
class AppUpdateRoute extends PageRouteInfo<void> {
  const AppUpdateRoute({List<PageRouteInfo>? children})
    : super(AppUpdateRoute.name, initialChildren: children);

  static const String name = 'AppUpdateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AppUpdateScreen();
    },
  );
}

/// generated route for
/// [BridgeFiltersScreen]
class BridgeFiltersRoute extends PageRouteInfo<void> {
  const BridgeFiltersRoute({List<PageRouteInfo>? children})
    : super(BridgeFiltersRoute.name, initialChildren: children);

  static const String name = 'BridgeFiltersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeFiltersScreen();
    },
  );
}

/// generated route for
/// [BridgeInspectionAllScreen]
class BridgeInspectionAllRoute extends PageRouteInfo<void> {
  const BridgeInspectionAllRoute({List<PageRouteInfo>? children})
    : super(BridgeInspectionAllRoute.name, initialChildren: children);

  static const String name = 'BridgeInspectionAllRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeInspectionAllScreen();
    },
  );
}

/// generated route for
/// [BridgeInspectionDamageScreen]
class BridgeInspectionDamageRoute extends PageRouteInfo<void> {
  const BridgeInspectionDamageRoute({List<PageRouteInfo>? children})
    : super(BridgeInspectionDamageRoute.name, initialChildren: children);

  static const String name = 'BridgeInspectionDamageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeInspectionDamageScreen();
    },
  );
}

/// generated route for
/// [BridgeInspectionEvaluationScreen]
class BridgeInspectionEvaluationRoute
    extends PageRouteInfo<BridgeInspectionEvaluationRouteArgs> {
  BridgeInspectionEvaluationRoute({
    Key? key,
    required InspectionPoint point,
    List<PageRouteInfo>? children,
  }) : super(
         BridgeInspectionEvaluationRoute.name,
         args: BridgeInspectionEvaluationRouteArgs(key: key, point: point),
         initialChildren: children,
       );

  static const String name = 'BridgeInspectionEvaluationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BridgeInspectionEvaluationRouteArgs>();
      return BridgeInspectionEvaluationScreen(key: args.key, point: args.point);
    },
  );
}

class BridgeInspectionEvaluationRouteArgs {
  const BridgeInspectionEvaluationRouteArgs({this.key, required this.point});

  final Key? key;

  final InspectionPoint point;

  @override
  String toString() {
    return 'BridgeInspectionEvaluationRouteArgs{key: $key, point: $point}';
  }
}

/// generated route for
/// [BridgeInspectionPhotoComparisonScreen]
class BridgeInspectionPhotoComparisonRoute
    extends PageRouteInfo<BridgeInspectionPhotoComparisonRouteArgs> {
  BridgeInspectionPhotoComparisonRoute({
    Key? key,
    required InspectionPoint point,
    List<PageRouteInfo>? children,
  }) : super(
         BridgeInspectionPhotoComparisonRoute.name,
         args: BridgeInspectionPhotoComparisonRouteArgs(key: key, point: point),
         initialChildren: children,
       );

  static const String name = 'BridgeInspectionPhotoComparisonRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BridgeInspectionPhotoComparisonRouteArgs>();
      return BridgeInspectionPhotoComparisonScreen(
        key: args.key,
        point: args.point,
      );
    },
  );
}

class BridgeInspectionPhotoComparisonRouteArgs {
  const BridgeInspectionPhotoComparisonRouteArgs({
    this.key,
    required this.point,
  });

  final Key? key;

  final InspectionPoint point;

  @override
  String toString() {
    return 'BridgeInspectionPhotoComparisonRouteArgs{key: $key, point: $point}';
  }
}

/// generated route for
/// [BridgeInspectionPhotoSelectionScreen]
class BridgeInspectionPhotoSelectionRoute extends PageRouteInfo<void> {
  const BridgeInspectionPhotoSelectionRoute({List<PageRouteInfo>? children})
    : super(
        BridgeInspectionPhotoSelectionRoute.name,
        initialChildren: children,
      );

  static const String name = 'BridgeInspectionPhotoSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeInspectionPhotoSelectionScreen();
    },
  );
}

/// generated route for
/// [BridgeInspectionPhotosTabScreen]
class BridgeInspectionPhotosTabRoute
    extends PageRouteInfo<BridgeInspectionPhotosTabRouteArgs> {
  BridgeInspectionPhotosTabRoute({
    Key? key,
    required InspectionPoint point,
    List<PageRouteInfo>? children,
  }) : super(
         BridgeInspectionPhotosTabRoute.name,
         args: BridgeInspectionPhotosTabRouteArgs(key: key, point: point),
         initialChildren: children,
       );

  static const String name = 'BridgeInspectionPhotosTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BridgeInspectionPhotosTabRouteArgs>();
      return BridgeInspectionPhotosTabScreen(key: args.key, point: args.point);
    },
  );
}

class BridgeInspectionPhotosTabRouteArgs {
  const BridgeInspectionPhotosTabRouteArgs({this.key, required this.point});

  final Key? key;

  final InspectionPoint point;

  @override
  String toString() {
    return 'BridgeInspectionPhotosTabRouteArgs{key: $key, point: $point}';
  }
}

/// generated route for
/// [BridgeInspectionPresentConditionScreen]
class BridgeInspectionPresentConditionRoute extends PageRouteInfo<void> {
  const BridgeInspectionPresentConditionRoute({List<PageRouteInfo>? children})
    : super(
        BridgeInspectionPresentConditionRoute.name,
        initialChildren: children,
      );

  static const String name = 'BridgeInspectionPresentConditionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeInspectionPresentConditionScreen();
    },
  );
}

/// generated route for
/// [BridgeInspectionTabScreen]
class BridgeInspectionTabRoute extends PageRouteInfo<void> {
  const BridgeInspectionTabRoute({List<PageRouteInfo>? children})
    : super(BridgeInspectionTabRoute.name, initialChildren: children);

  static const String name = 'BridgeInspectionTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeInspectionTabScreen();
    },
  );
}

/// generated route for
/// [BridgeListScreen]
class BridgeListRoute extends PageRouteInfo<void> {
  const BridgeListRoute({List<PageRouteInfo>? children})
    : super(BridgeListRoute.name, initialChildren: children);

  static const String name = 'BridgeListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeListScreen();
    },
  );
}

/// generated route for
/// [DiagramInspectionScreen]
class DiagramInspectionRoute extends PageRouteInfo<DiagramInspectionRouteArgs> {
  DiagramInspectionRoute({
    Key? key,
    required Diagram diagram,
    List<PageRouteInfo>? children,
  }) : super(
         DiagramInspectionRoute.name,
         args: DiagramInspectionRouteArgs(key: key, diagram: diagram),
         initialChildren: children,
       );

  static const String name = 'DiagramInspectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DiagramInspectionRouteArgs>();
      return DiagramInspectionScreen(key: args.key, diagram: args.diagram);
    },
  );
}

class DiagramInspectionRouteArgs {
  const DiagramInspectionRouteArgs({this.key, required this.diagram});

  final Key? key;

  final Diagram diagram;

  @override
  String toString() {
    return 'DiagramInspectionRouteArgs{key: $key, diagram: $diagram}';
  }
}

/// generated route for
/// [InspectionPointDiagramSelectScreen]
class InspectionPointDiagramSelectRoute extends PageRouteInfo<void> {
  const InspectionPointDiagramSelectRoute({List<PageRouteInfo>? children})
    : super(InspectionPointDiagramSelectRoute.name, initialChildren: children);

  static const String name = 'InspectionPointDiagramSelectRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InspectionPointDiagramSelectScreen();
    },
  );
}

/// generated route for
/// [InspectionPointScreen]
class InspectionPointRoute extends PageRouteInfo<InspectionPointRouteArgs> {
  InspectionPointRoute({
    Key? key,
    required InspectionPoint initialPoint,
    List<PageRouteInfo>? children,
  }) : super(
         InspectionPointRoute.name,
         args: InspectionPointRouteArgs(key: key, initialPoint: initialPoint),
         initialChildren: children,
       );

  static const String name = 'InspectionPointRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InspectionPointRouteArgs>();
      return InspectionPointScreen(
        key: args.key,
        initialPoint: args.initialPoint,
      );
    },
  );
}

class InspectionPointRouteArgs {
  const InspectionPointRouteArgs({this.key, required this.initialPoint});

  final Key? key;

  final InspectionPoint initialPoint;

  @override
  String toString() {
    return 'InspectionPointRouteArgs{key: $key, initialPoint: $initialPoint}';
  }
}

/// generated route for
/// [PointsInspectionScreen]
class PointsInspectionRoute extends PageRouteInfo<PointsInspectionRouteArgs> {
  PointsInspectionRoute({
    Key? key,
    required List<int> pointIds,
    String? details,
    List<PageRouteInfo>? children,
  }) : super(
         PointsInspectionRoute.name,
         args: PointsInspectionRouteArgs(
           key: key,
           pointIds: pointIds,
           details: details,
         ),
         initialChildren: children,
       );

  static const String name = 'PointsInspectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PointsInspectionRouteArgs>();
      return PointsInspectionScreen(
        key: args.key,
        pointIds: args.pointIds,
        details: args.details,
      );
    },
  );
}

class PointsInspectionRouteArgs {
  const PointsInspectionRouteArgs({
    this.key,
    required this.pointIds,
    this.details,
  });

  final Key? key;

  final List<int> pointIds;

  final String? details;

  @override
  String toString() {
    return 'PointsInspectionRouteArgs{key: $key, pointIds: $pointIds, details: $details}';
  }
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TakePictureScreen]
class TakePictureRoute extends PageRouteInfo<TakePictureRouteArgs> {
  TakePictureRoute({
    Key? key,
    required InspectionPoint inspectionPoint,
    List<PageRouteInfo>? children,
  }) : super(
         TakePictureRoute.name,
         args: TakePictureRouteArgs(key: key, inspectionPoint: inspectionPoint),
         initialChildren: children,
       );

  static const String name = 'TakePictureRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TakePictureRouteArgs>();
      return TakePictureScreen(
        key: args.key,
        inspectionPoint: args.inspectionPoint,
      );
    },
  );
}

class TakePictureRouteArgs {
  const TakePictureRouteArgs({this.key, required this.inspectionPoint});

  final Key? key;

  final InspectionPoint inspectionPoint;

  @override
  String toString() {
    return 'TakePictureRouteArgs{key: $key, inspectionPoint: $inspectionPoint}';
  }
}
