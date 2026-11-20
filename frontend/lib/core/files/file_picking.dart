import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../network/interceptors.dart';

/// A file chosen by the user, ready to upload.
class PickedUpload {
  const PickedUpload({required this.bytes, required this.name});

  final List<int> bytes;
  final String name;
}

enum PickSource { camera, gallery, pdf }

/// A-202: camera/gallery images are resized to ≤ 1600 px, JPEG 80 % (architecture.md "Files and images").
class FilePicking {
  const FilePicking();

  Future<PickedUpload?> pick(PickSource source) async {
    if (source == PickSource.pdf) {
      final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      final f = files.firstOrNull;
      if (f == null) return null;
      return PickedUpload(bytes: await f.xFile.readAsBytes(), name: f.name);
    }
    final image = await ImagePicker().pickImage(
      source: source == PickSource.camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (image == null) return null;
    return PickedUpload(bytes: await image.readAsBytes(), name: image.name);
  }
}

/// `POST /files` (multipart) with progress; returns the fileId.
Future<String> uploadFile(Dio dio, PickedUpload file, {void Function(double progress)? onProgress}) async {
  final form = FormData.fromMap({'file': MultipartFile.fromBytes(file.bytes, filename: file.name)});
  final res = await guardApi(() => dio.post<Map<String, dynamic>>(
        '/files',
        data: form,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      ));
  return res.data!['fileId'] as String;
}
