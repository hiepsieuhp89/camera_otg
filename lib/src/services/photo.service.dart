import 'package:kyoryo/src/models/photo.dart';
import 'package:kyoryo/src/services/base.service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo.service.g.dart';

@riverpod
PhotoService photoService(PhotoServiceRef ref) {
  return PhotoService();
}

class PhotoService extends BaseApiService {
  Future<Photo> uploadPhoto(String filePath) async {
    final jsonResponse = await postSingleFile('photo', filePath);

    return Photo.fromJson(jsonResponse);
  }
}
