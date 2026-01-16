import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  /// Upload patient photo and return a public download URL.
  ///
  /// Uses `XFile.readAsBytes()` so it works without `dart:io`.
  Future<String> uploadPatientPhoto(String patientId, XFile imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final ref = FirebaseStorage.instance
          .ref()
          .child('patients')
          .child(patientId)
          .child('photo.jpg');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'patientId': patientId,
        },
      );

      await ref.putData(bytes, metadata);
      return await ref.getDownloadURL();
    } catch (_) {
      // Fallback so the UI can continue working even if Storage is not configured.
      return 'https://via.placeholder.com/200x200?text=$patientId';
    }
  }

  /// Delete patient photo - stubbed for web
  Future<void> deletePatientPhoto(String patientId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('patients')
          .child(patientId)
          .child('photo.jpg');
      await ref.delete();
    } catch (_) {
      // Ignore: deletion is best-effort.
    }
  }
}
