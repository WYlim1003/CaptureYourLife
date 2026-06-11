import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/image_from_path.dart';

class StorageService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  String? get _uid => _auth.currentUser?.uid;

  /// Save a photo locally and upload metadata to Firestore.
  Future<Map<String, dynamic>> savePhoto(String filePath) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final photoId = _uuid.v4();

    // Get file extension
    final parts = filePath.split('.');
    final ext = parts.length > 1 ? '.${parts.last.split('?').first}' : '.jpg';
    final fileName = filePath.split('/').last.split('?').first;

    final String localPath;
    if (kIsWeb) {
      // Web image_picker returns a blob URL — store it directly.
      localPath = filePath;
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      final userDirPath = '${appDir.path}/users/$uid/photos';
      localPath = '$userDirPath/$photoId$ext';
      await copyPhotoToStorage(
        sourcePath: filePath,
        destinationPath: localPath,
      );
    }

    // Save metadata to Firestore
    final now = DateTime.now();
    final photoData = <String, dynamic>{
      'id': photoId,
      'user_id': uid,
      'local_path': localPath,
      'file_name': fileName,
      'created_at': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('photos')
        .doc(photoId)
        .set(photoData);

    return {
      ...photoData,
      'created_at': now,
    };
  }

  /// Real-time stream of user's photos from Firestore, newest first.
  Stream<List<Map<String, dynamic>>> getPhotosStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('photos')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final ts = data['created_at'];
              return <String, dynamic>{
                ...data,
                'created_at':
                    ts is Timestamp ? ts.toDate() : DateTime.now(),
              };
            }).toList());
  }

  /// Delete a photo from local storage and Firestore.
  Future<void> deletePhoto(String photoId, String localPath) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    try {
      await deleteLocalPhoto(localPath);
    } catch (_) {
      // Ignore if file already deleted
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('photos')
        .doc(photoId)
        .delete();
  }
}
