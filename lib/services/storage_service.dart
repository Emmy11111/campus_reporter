import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _override = storage;

  final FirebaseStorage? _override;

  FirebaseStorage get _storage => _override ?? FirebaseStorage.instance;

  Future<String> uploadIncidentImage({
    required File file,
    required String userId,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final reference = _storage.ref('incidents/$userId/$fileName');
    await reference
        .putFile(file, SettableMetadata(contentType: 'image/jpeg'))
        .timeout(const Duration(seconds: 25));
    return reference.getDownloadURL();
  }
}