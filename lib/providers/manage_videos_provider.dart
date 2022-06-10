import 'dart:io';
import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageVideosProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  ManageVideosProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

   Stream<QuerySnapshot<Map<String, dynamic>>> getUserActivitiesList(String userId) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id, isEqualTo: userId)
        .snapshots();
  }

  Future<List<Video>> getUserVideoList(List<String> userVideos) async {
    List<Video> resultList = [];
    if (userVideos.isNotEmpty) {
    final QuerySnapshot result = await firebaseFirestore
        .collection(FirestoreConstants.pathVideoCollection)
        .where(FirestoreConstants.videoId, whereIn: userVideos)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      for (DocumentSnapshot videoDoc in documents) {
        final imageStorageURL = videoDoc.get(FirestoreConstants.photoURL);
        final videoStorageURL = videoDoc.get(FirestoreConstants.url);
        final imageURL =
            await firebaseStorage.refFromURL(imageStorageURL).getDownloadURL();
        final videoURL =
            await firebaseStorage.refFromURL(videoStorageURL).getDownloadURL();
        Video video = Video.fromDocument(
            videoDoc, videoURL.toString(), imageURL.toString());
        resultList.add(video);
      }
    }
    }
    return Future.value(resultList);
  }
}
