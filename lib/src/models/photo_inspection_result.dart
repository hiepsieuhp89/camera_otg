import 'package:kyoryo/src/models/inspection_point_report_photo.dart';

class PhotoInspectionResult {
  final List<InspectionPointReportPhoto> _photos;
  String? skipReason;
  bool isSkipped;
  List<InspectionPointReportPhoto> get photos => _photos;
  List<String> get photosNotYetUploaded => _photos
      .where((photo) => photo.localPath != null && photo.photoId == null)
      .map((photo) => photo.localPath!)
      .toList();

  PhotoInspectionResult(
      {required List<InspectionPointReportPhoto> photos,
      this.skipReason,
      this.isSkipped = false})
      : _photos = photos.toList();

  PhotoInspectionResult copyWith({
    List<InspectionPointReportPhoto>? photos,
    String? selectedPhotoPath,
  }) {
    return PhotoInspectionResult(
      photos: photos ?? _photos.toList(),
      skipReason: skipReason,
      isSkipped: isSkipped,
    );
  }
}
