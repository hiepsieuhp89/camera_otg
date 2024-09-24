// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [BridgeFiltersScreen]
class BridgeFiltersRoute extends PageRouteInfo<void> {
  const BridgeFiltersRoute({List<PageRouteInfo>? children})
      : super(
          BridgeFiltersRoute.name,
          initialChildren: children,
        );

  static const String name = 'BridgeFiltersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeFiltersScreen();
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
    required PhotoInspectionResult photoInspectionResult,
    InspectionPointReport? createdReport,
    List<PageRouteInfo>? children,
  }) : super(
          BridgeInspectionEvaluationRoute.name,
          args: BridgeInspectionEvaluationRouteArgs(
            key: key,
            point: point,
            photoInspectionResult: photoInspectionResult,
            createdReport: createdReport,
          ),
          initialChildren: children,
        );

  static const String name = 'BridgeInspectionEvaluationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BridgeInspectionEvaluationRouteArgs>();
      return BridgeInspectionEvaluationScreen(
        key: args.key,
        point: args.point,
        photoInspectionResult: args.photoInspectionResult,
        createdReport: args.createdReport,
      );
    },
  );
}

class BridgeInspectionEvaluationRouteArgs {
  const BridgeInspectionEvaluationRouteArgs({
    this.key,
    required this.point,
    required this.photoInspectionResult,
    this.createdReport,
  });

  final Key? key;

  final InspectionPoint point;

  final PhotoInspectionResult photoInspectionResult;

  final InspectionPointReport? createdReport;

  @override
  String toString() {
    return 'BridgeInspectionEvaluationRouteArgs{key: $key, point: $point, photoInspectionResult: $photoInspectionResult, createdReport: $createdReport}';
  }
}

/// generated route for
/// [BridgeInspectionPhotoSelectionScreen]
class BridgeInspectionPhotoSelectionRoute
    extends PageRouteInfo<BridgeInspectionPhotoSelectionRouteArgs> {
  BridgeInspectionPhotoSelectionRoute({
    Key? key,
    required PhotoInspectionResult photoInspectionResult,
    required InspectionPoint point,
    InspectionPointReport? createdReport,
    List<PageRouteInfo>? children,
  }) : super(
          BridgeInspectionPhotoSelectionRoute.name,
          args: BridgeInspectionPhotoSelectionRouteArgs(
            key: key,
            photoInspectionResult: photoInspectionResult,
            point: point,
            createdReport: createdReport,
          ),
          initialChildren: children,
        );

  static const String name = 'BridgeInspectionPhotoSelectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<BridgeInspectionPhotoSelectionRouteArgs>();
      return BridgeInspectionPhotoSelectionScreen(
        key: args.key,
        photoInspectionResult: args.photoInspectionResult,
        point: args.point,
        createdReport: args.createdReport,
      );
    },
  );
}

class BridgeInspectionPhotoSelectionRouteArgs {
  const BridgeInspectionPhotoSelectionRouteArgs({
    this.key,
    required this.photoInspectionResult,
    required this.point,
    this.createdReport,
  });

  final Key? key;

  final PhotoInspectionResult photoInspectionResult;

  final InspectionPoint point;

  final InspectionPointReport? createdReport;

  @override
  String toString() {
    return 'BridgeInspectionPhotoSelectionRouteArgs{key: $key, photoInspectionResult: $photoInspectionResult, point: $point, createdReport: $createdReport}';
  }
}

/// generated route for
/// [BridgeInspectionScreen]
class BridgeInspectionRoute extends PageRouteInfo<void> {
  const BridgeInspectionRoute({List<PageRouteInfo>? children})
      : super(
          BridgeInspectionRoute.name,
          initialChildren: children,
        );

  static const String name = 'BridgeInspectionRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeInspectionScreen();
    },
  );
}

/// generated route for
/// [BridgeListScreen]
class BridgeListRoute extends PageRouteInfo<void> {
  const BridgeListRoute({List<PageRouteInfo>? children})
      : super(
          BridgeListRoute.name,
          initialChildren: children,
        );

  static const String name = 'BridgeListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const BridgeListScreen();
    },
  );
}

/// generated route for
/// [InspectionPointCreationScreen]
class InspectionPointCreationRoute
    extends PageRouteInfo<InspectionPointCreationRouteArgs> {
  InspectionPointCreationRoute({
    Key? key,
    Diagram? diagram,
    required InspectionPointType pointType,
    List<PageRouteInfo>? children,
  }) : super(
          InspectionPointCreationRoute.name,
          args: InspectionPointCreationRouteArgs(
            key: key,
            diagram: diagram,
            pointType: pointType,
          ),
          initialChildren: children,
        );

  static const String name = 'InspectionPointCreationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InspectionPointCreationRouteArgs>();
      return InspectionPointCreationScreen(
        key: args.key,
        diagram: args.diagram,
        pointType: args.pointType,
      );
    },
  );
}

class InspectionPointCreationRouteArgs {
  const InspectionPointCreationRouteArgs({
    this.key,
    this.diagram,
    required this.pointType,
  });

  final Key? key;

  final Diagram? diagram;

  final InspectionPointType pointType;

  @override
  String toString() {
    return 'InspectionPointCreationRouteArgs{key: $key, diagram: $diagram, pointType: $pointType}';
  }
}

/// generated route for
/// [InspectionPointDiagramSelectScreen]
class InspectionPointDiagramSelectRoute extends PageRouteInfo<void> {
  const InspectionPointDiagramSelectRoute({List<PageRouteInfo>? children})
      : super(
          InspectionPointDiagramSelectRoute.name,
          initialChildren: children,
        );

  static const String name = 'InspectionPointDiagramSelectRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const InspectionPointDiagramSelectScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

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
    InspectionPointReport? createdReport,
    List<PageRouteInfo>? children,
  }) : super(
          TakePictureRoute.name,
          args: TakePictureRouteArgs(
            key: key,
            inspectionPoint: inspectionPoint,
            createdReport: createdReport,
          ),
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
        createdReport: args.createdReport,
      );
    },
  );
}

class TakePictureRouteArgs {
  const TakePictureRouteArgs({
    this.key,
    required this.inspectionPoint,
    this.createdReport,
  });

  final Key? key;

  final InspectionPoint inspectionPoint;

  final InspectionPointReport? createdReport;

  @override
  String toString() {
    return 'TakePictureRouteArgs{key: $key, inspectionPoint: $inspectionPoint, createdReport: $createdReport}';
  }
}
