// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    BridgeFiltersRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BridgeFiltersScreen(),
      );
    },
    BridgeInspectionEvaluationRoute.name: (routeData) {
      final args = routeData.argsAs<BridgeInspectionEvaluationRouteArgs>();
      return AutoRoutePage<PhotoInspectionResult>(
        routeData: routeData,
        child: BridgeInspectionEvaluationScreen(
          key: args.key,
          point: args.point,
          photoInspectionResult: args.photoInspectionResult,
          createdReport: args.createdReport,
        ),
      );
    },
    BridgeInspectionPhotoSelectionRoute.name: (routeData) {
      final args = routeData.argsAs<BridgeInspectionPhotoSelectionRouteArgs>();
      return AutoRoutePage<PhotoInspectionResult>(
        routeData: routeData,
        child: BridgeInspectionPhotoSelectionScreen(
          key: args.key,
          photoInspectionResult: args.photoInspectionResult,
          point: args.point,
        ),
      );
    },
    BridgeInspectionRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BridgeInspectionScreen(),
      );
    },
    BridgeListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BridgeListScreen(),
      );
    },
    InspectionPointCreationRoute.name: (routeData) {
      final args = routeData.argsAs<InspectionPointCreationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InspectionPointCreationScreen(
          key: args.key,
          diagram: args.diagram,
          pointType: args.pointType,
        ),
      );
    },
    InspectionPointDiagramSelectRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InspectionPointDiagramSelectScreen(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    TakePictureRoute.name: (routeData) {
      final args = routeData.argsAs<TakePictureRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TakePictureScreen(
          key: args.key,
          inspectionPoint: args.inspectionPoint,
          createdReport: args.createdReport,
        ),
      );
    },
  };
}

/// generated route for
/// [BridgeFiltersScreen]
class BridgeFiltersRoute extends PageRouteInfo<void> {
  const BridgeFiltersRoute({List<PageRouteInfo>? children})
      : super(
          BridgeFiltersRoute.name,
          initialChildren: children,
        );

  static const String name = 'BridgeFiltersRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<BridgeInspectionEvaluationRouteArgs> page =
      PageInfo<BridgeInspectionEvaluationRouteArgs>(name);
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
    List<PageRouteInfo>? children,
  }) : super(
          BridgeInspectionPhotoSelectionRoute.name,
          args: BridgeInspectionPhotoSelectionRouteArgs(
            key: key,
            photoInspectionResult: photoInspectionResult,
            point: point,
          ),
          initialChildren: children,
        );

  static const String name = 'BridgeInspectionPhotoSelectionRoute';

  static const PageInfo<BridgeInspectionPhotoSelectionRouteArgs> page =
      PageInfo<BridgeInspectionPhotoSelectionRouteArgs>(name);
}

class BridgeInspectionPhotoSelectionRouteArgs {
  const BridgeInspectionPhotoSelectionRouteArgs({
    this.key,
    required this.photoInspectionResult,
    required this.point,
  });

  final Key? key;

  final PhotoInspectionResult photoInspectionResult;

  final InspectionPoint point;

  @override
  String toString() {
    return 'BridgeInspectionPhotoSelectionRouteArgs{key: $key, photoInspectionResult: $photoInspectionResult, point: $point}';
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<InspectionPointCreationRouteArgs> page =
      PageInfo<InspectionPointCreationRouteArgs>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<void> page = PageInfo<void>(name);
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

  static const PageInfo<TakePictureRouteArgs> page =
      PageInfo<TakePictureRouteArgs>(name);
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
