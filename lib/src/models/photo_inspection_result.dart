import 'package:kyoryo/src/models/photo.dart';

class PhotoInspectionResult {
  final List<String> _newPhotoLocalPaths;
  final List<Photo> _uploadedPhotos;
  String selectedPhotoPath;
  String skipReason;
  bool isSkipped;
  List<dynamic> get allPhotos => [..._uploadedPhotos, ..._newPhotoLocalPaths];

  List<String> get newPhotoLocalPaths => _newPhotoLocalPaths;
  List<Photo> get uploadedPhotos => _uploadedPhotos;

  PhotoInspectionResult(
      {required List<String> newPhotoLocalPaths,
      required List<Photo> uploadedPhotos,
      required this.selectedPhotoPath,
       required this.skipReason,
        required this.isSkipped})
      : _newPhotoLocalPaths = newPhotoLocalPaths.toList(),
        _uploadedPhotos = uploadedPhotos.toList();

  PhotoInspectionResult copyWith({
    List<String>? newPhotoLocalPaths,
    List<Photo>? uploadedPhotos,
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
      selectedPhotoPath = _uploadedPhotos.firstOrNull?.photoLink ??
          _newPhotoLocalPaths.firstOrNull ??
          '';
    }
  }

  void removeUploadedPhoto(Photo photo) {
    _uploadedPhotos.removeWhere((p) => p.id == photo.id);

    if (_uploadedPhotos.isEmpty && _newPhotoLocalPaths.isEmpty) {
      selectedPhotoPath = '';
    }

    selectedPhotoPath = selectedPhotoPath == photo.photoLink
        ? _uploadedPhotos.firstOrNull?.photoLink ??
            _newPhotoLocalPaths.firstOrNull ??
            ''
        : selectedPhotoPath;
  }
}
