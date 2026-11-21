import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(File file, String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Firebase Upload Error: $e");
    }
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }
}
