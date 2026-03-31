import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadVehicleImage(
      String userId, String vehicleId, XFile imageFile) async {
    final ref = _storage.ref('vehicles/$userId/$vehicleId.jpg');
    await ref.putFile(File(imageFile.path));
    return ref.getDownloadURL();
  }

  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    final ref = _storage.ref('profiles/$userId.jpg');
    await ref.putFile(File(imageFile.path));
    return ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (_) {}
  }

  Future<String?> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
