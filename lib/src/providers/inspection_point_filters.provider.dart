import 'package:kyoryo/src/models/inspection_point.dart';
import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inspection_point_filters.provider.g.dart';

@riverpod
class BridgeInspectionPointFilters extends _$BridgeInspectionPointFilters {
  @override
  InspectionPointFilters build(int bridgeId) {
    return InspectionPointFilters(reportStatusFilters: {
      for (var status in InspectionPointReportStatus.values) status: true
    });
  }

  void setNameFilter(String name, bool toAdd) {
    if (toAdd) {
      state =
          state.copyWith(nameFilters: {...state.nameFilters, name}.toList());
    } else {
      state = state.copyWith(
          nameFilters: state.nameFilters.where((n) => n != name).toList());
    }
  }

  void setElementNumberFilter(String elementNumber, bool toAdd) {
    if (toAdd) {
      state = state.copyWith(
          elementNumberFilters:
              {...state.elementNumberFilters, elementNumber}.toList());
    } else {
      state = state.copyWith(
          elementNumberFilters: state.elementNumberFilters
              .where((n) => n != elementNumber)
              .toList());
    }
  }

  void setStatusFilter(InspectionPointReportStatus status, bool value) {
    state = state.copyWith(
        reportStatusFilters: {...state.reportStatusFilters, status: value});
  }

  void setIncludeNoReport(bool value) {
    state = state.copyWith(includeNoReport: value);
  }

  void setTypeFilter(InspectionPointType? type) {
    state = state.copyWith(typeFilter: type);
  }

  void clearNameFilters() {
    state = state.copyWith(nameFilters: []);
  }

  void clearElementNumberFilters() {
    state = state.copyWith(elementNumberFilters: []);
  }
}

class InspectionPointFilters {
  InspectionPointType? typeFilter;
  List<String> nameFilters;
  List<String> elementNumberFilters;
  Map<InspectionPointReportStatus, bool> reportStatusFilters;
  bool includeNoReport;

  bool get hasActiveFilters =>
      nameFilters.isNotEmpty ||
      elementNumberFilters.isNotEmpty ||
      reportStatusFilters.values.any((v) => v == false) ||
      !includeNoReport;

  InspectionPointFilters(
      {this.typeFilter,
      this.nameFilters = const [],
      this.elementNumberFilters = const [],
      this.reportStatusFilters = const {},
      this.includeNoReport = true});

  InspectionPointFilters copyWith(
      {InspectionPointType? typeFilter,
      List<String>? nameFilters,
      List<String>? elementNumberFilters,
      Map<InspectionPointReportStatus, bool>? reportStatusFilters,
      bool? includeNoReport}) {
    return InspectionPointFilters(
        typeFilter: typeFilter,
        nameFilters: nameFilters ?? this.nameFilters,
        elementNumberFilters: elementNumberFilters ?? this.elementNumberFilters,
        reportStatusFilters: reportStatusFilters ?? this.reportStatusFilters,
        includeNoReport: includeNoReport ?? this.includeNoReport);
  }
}
