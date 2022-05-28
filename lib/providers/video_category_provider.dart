import 'dart:io';
import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  CategoryProvider({required this.firebaseFirestore, required this.prefs, required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit) {
    return firebaseFirestore.collection(pathCollection).orderBy('id').limit(limit).snapshots();
  }

  Future<List<Video>> getVideoList(List<String> userVideos, List<String> categoryVideos, String pathCollection) async {
    List<Video> resultList = [];
    
    categoryVideos.removeWhere((item) => !userVideos.contains(item));

    firebaseFirestore.collection(pathCollection).orderBy('id').snapshots();

    for (var videoId in categoryVideos) {
      final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathVideoCollection)
            .where(FirestoreConstants.videoId, isEqualTo: videoId)
            .get();
      final DocumentSnapshot videoDoc = result.docs[0];
      FirebaseStorage firebaseStorage = FirebaseStorage.instance;
      final imageStorageURL = videoDoc.get(FirestoreConstants.photoURL);
      final videoStorageURL = videoDoc.get(FirestoreConstants.url);
      final imageURL = await firebaseStorage.refFromURL(imageStorageURL).getDownloadURL();
      final videoURL = await firebaseStorage.refFromURL(videoStorageURL).getDownloadURL();
      Video video = Video.fromDocument(videoDoc, videoURL.toString(), imageURL.toString());
      resultList.add(video);
  }
  return resultList;
}
}
