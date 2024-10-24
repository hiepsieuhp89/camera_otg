import 'package:kyoryo/src/models/inspection_point_report_photo.dart';
import 'package:kyoryo/src/models/photo_inspection_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_photo_inspection_result.provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentPhotoInspectionResult extends _$CurrentPhotoInspectionResult {
  @override
  PhotoInspectionResult build() => PhotoInspectionResult(photos: []);

  void set(PhotoInspectionResult result) {
    state = result;
  }

  void removePhoto(int index) {
    List<InspectionPointReportPhoto> photos = List.from(state.photos);

    if (photos[index].sequenceNumber == null) {
      state = state.copyWith(photos: photos..removeAt(index));
      return;
    }

    final oldSequenceNumber = photos[index].sequenceNumber;

    for (int i = 0; i < photos.length; i++) {
      if (i != index && photos[i].sequenceNumber != null) {
        if (photos[i].sequenceNumber == 1) {
          continue;
        }

        if (photos[i].sequenceNumber! > oldSequenceNumber!) {
          photos[i] =
              photos[i].copyWith(sequenceNumber: photos[i].sequenceNumber! - 1);
        }
      }
    }

    state = state.copyWith(photos: photos..removeAt(index));
  }

  void selectPhoto(int index) {
    List<InspectionPointReportPhoto> photos = List.from(state.photos);

    if (photos[index].sequenceNumber == null) {
      final existingNumbers = photos
          .where((photo) => photo.sequenceNumber != null)
          .map((photo) => photo.sequenceNumber!)
          .toSet();

      int nextNumber = 1;
      while (existingNumbers.contains(nextNumber)) {
        nextNumber++;
      }
      final newPhoto = photos[index].copyWith(sequenceNumber: nextNumber);

      photos[index] = newPhoto;
    } else {
      photos[index] = photos[index].copyWith(sequenceNumber: null);

      final existingNumbers = photos
          .where((photo) => photo.sequenceNumber != null)
          .map((photo) => photo.sequenceNumber!)
          .toList()
        ..sort();

      for (int i = 0; i < existingNumbers.length; i++) {
        final photoIndex = photos
            .indexWhere((photo) => photo.sequenceNumber == existingNumbers[i]);
        photos[photoIndex] = photos[photoIndex].copyWith(sequenceNumber: i + 1);
      }
    }

    state = state.copyWith(photos: photos);
  }
}
