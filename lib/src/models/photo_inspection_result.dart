import 'package:kyoryo/src/models/inspection_point_report_photo.dart';

class PhotoInspectionResult {
  final List<String> _newPhotoLocalPaths;
  final List<InspectionPointReportPhoto> _uploadedPhotos;
  String selectedPhotoPath;
  String? skipReason;
  bool isSkipped;
  List<dynamic> get allPhotos => [..._uploadedPhotos, ..._newPhotoLocalPaths];

  List<String> get newPhotoLocalPaths => _newPhotoLocalPaths;
  List<InspectionPointReportPhoto> get uploadedPhotos => _uploadedPhotos;

  PhotoInspectionResult(
      {required List<String> newPhotoLocalPaths,
      required List<InspectionPointReportPhoto> uploadedPhotos,
      required this.selectedPhotoPath,
      this.skipReason,
      this.isSkipped = false})
      : _newPhotoLocalPaths = newPhotoLocalPaths.toList(),
        _uploadedPhotos = uploadedPhotos.toList();

  PhotoInspectionResult copyWith({
    List<String>? newPhotoLocalPaths,
    List<InspectionPointReportPhoto>? uploadedPhotos,
    String? selectedPhotoPath,
  }) {
    return PhotoInspectionResult(
      newPhotoLocalPaths: newPhotoLocalPaths ?? _newPhotoLocalPaths.toList(),
      uploadedPhotos: uploadedPhotos ?? _uploadedPhotos.toList(),
      selectedPhotoPath: selectedPhotoPath ?? this.selectedPhotoPath,
      skipReason: skipReason,
      isSkipped: isSkipped,
    );
  }

  bool isPhotoSelected(String path) {
    return selectedPhotoPath == path;
  }

  void removePhoto(int index) {
    if (index < _uploadedPhotos.length) {
      removeUploadedPhoto(_uploadedPhotos[index]);
    } else {
      removeNewPhoto(_newPhotoLocalPaths[index - _uploadedPhotos.length]);
    }
  }

  void removeNewPhoto(String path) {
    _newPhotoLocalPaths.remove(path);

    if (_uploadedPhotos.isEmpty && _newPhotoLocalPaths.isEmpty) {
      selectedPhotoPath = '';
    }

    if (selectedPhotoPath == path) {
      selectedPhotoPath = _uploadedPhotos.firstOrNull?.url ??
          _newPhotoLocalPaths.firstOrNull ??
          '';
    }
  }

  void removeUploadedPhoto(InspectionPointReportPhoto reportPhoto) {
    _uploadedPhotos.removeWhere((p) => p.photoId == reportPhoto.photoId);

    if (_uploadedPhotos.isEmpty && _newPhotoLocalPaths.isEmpty) {
      selectedPhotoPath = '';
    }

    selectedPhotoPath = selectedPhotoPath == reportPhoto.url
        ? _uploadedPhotos.firstOrNull?.url ??
            _newPhotoLocalPaths.firstOrNull ??
            ''
        : selectedPhotoPath;
  }
}
