import 'package:kyoryo/src/models/inspection_point_report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_submission_tracker.provider.g.dart';

enum ReportSubmissionStatus {
  submitting,
  success,
  failure,
}

class ReportSubmission {
  final InspectionPointReport report;
  final ReportSubmissionStatus status;
  final bool notified;

  ReportSubmission({
    required this.report,
    required this.status,
    required this.notified,
  });

  ReportSubmission copyWith({
    InspectionPointReport? report,
    ReportSubmissionStatus? status,
    bool? notified,
  }) {
    return ReportSubmission(
      report: report ?? this.report,
      status: status ?? this.status,
      notified: notified ?? this.notified,
    );
  }
}

class ReportSubmissionTrackerState {
  final Map<int, ReportSubmission> submissions;

  bool get hasUnnotifiedSubmissions {
    return submissions.values.any((submission) =>
        !submission.notified &&
        submission.status != ReportSubmissionStatus.submitting);
  }

  ReportSubmission? get firstUnnotifiedSubmission {
    return submissions.values.firstWhere((submission) =>
        !submission.notified &&
        submission.status != ReportSubmissionStatus.submitting);
  }

  ReportSubmission? getSubmissionFor(int inspectionPointId) {
    return submissions[inspectionPointId];
  }

  ReportSubmissionTrackerState({required this.submissions});

  ReportSubmissionTrackerState copyWith({
    Map<int, ReportSubmission>? submissions,
  }) {
    return ReportSubmissionTrackerState(
      submissions: submissions ?? this.submissions,
    );
  }
}

@riverpod
class ReportSubmissionTracker extends _$ReportSubmissionTracker {
  @override
  ReportSubmissionTrackerState build() {
    return ReportSubmissionTrackerState(submissions: {});
  }

  void addReportSubmission(int inspectionPointId, ReportSubmission submission) {
    state = state.copyWith(
      submissions: {
        ...state.submissions,
        inspectionPointId: submission,
      },
    );
  }

  void removeReportSubmission(int inspectionPointId) {
    state = state.copyWith(
      submissions: {
        ...state.submissions,
      }..remove(inspectionPointId),
    );
  }

  void updateReportSubmissionStatus(
      int inspectionPointId, ReportSubmissionStatus status) {
    if (state.submissions.containsKey(inspectionPointId)) {
      state = state.copyWith(
        submissions: {
          ...state.submissions,
          inspectionPointId:
              state.submissions[inspectionPointId]!.copyWith(status: status),
        },
      );
    }
  }

  void updateReportSubmissionNotified(int inspectionPointId, bool notified) {
    if (state.submissions.containsKey(inspectionPointId)) {
      state = state.copyWith(
        submissions: {
          ...state.submissions,
          inspectionPointId: state.submissions[inspectionPointId]!
              .copyWith(notified: notified),
        },
      );
    }
  }
}
