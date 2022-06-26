import 'dart:io';
import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';

class CategoryProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  CategoryProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  List<String>? getPrefStringList(String key) {
    return prefs.getStringList(key);
  }

  bool? getBoolPref(String key) {
    return prefs.getBool(key);
  }

  UploadTask uploadFile(File image, String fileName) {
    Reference reference = firebaseStorage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(image);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(String pathCollection, int limit) {
    return firebaseFirestore
        .collection(pathCollection)
        .orderBy('id')
        .limit(limit)
        .snapshots();
  }

  Future<List<Video>> getVideoList(List<String> userVideos,
      List<String> categoryVideos, String pathCollection, bool isAdmin) async {
    List<Video> resultList = [];

    if (!isAdmin) {
      categoryVideos.removeWhere((item) => !userVideos.contains(item));
    }

    firebaseFirestore.collection(pathCollection).orderBy('id').snapshots();

    for (var videoId in categoryVideos) {
      final QuerySnapshot result = await firebaseFirestore
          .collection(FirestoreConstants.pathVideoCollection)
          .where(FirestoreConstants.videoId, isEqualTo: videoId)
          .get();
      if (result.docs.isNotEmpty) {
        final DocumentSnapshot videoDoc = result.docs[0];
        FirebaseStorage firebaseStorage = FirebaseStorage.instance;
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
    return resultList;
  }

  Future<List<String>> getPatientAssignedVideos(String patientId) async {
    List<String> assignedVideos = [];
    final QuerySnapshot result = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id, isEqualTo: patientId)
        .get();

    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length > 0) {
      assignedVideos = documents[0].get("llistaVideos").cast<String>();
    }
    return assignedVideos;
  }

   Future<List<bool>> getPatientDoneActivities(String patientId) async {
    List<bool> doneActivities = [];
    final QuerySnapshot result = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id, isEqualTo: patientId)
        .get();

    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length > 0) {
      doneActivities = documents[0].get("llistaActivitatsFetes").cast<bool>();
    }
    return doneActivities;
  }

  void updateActivitiesList(patientId, List<String> assignedVideos) {
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(patientId)
        .update({'llistaVideos': assignedVideos});
  }

    void updateDoneActivities(userId, List<bool> doneActivities) {
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(userId)
        .update({'llistaActivitatsFetes': doneActivities});
  }

  Stream<QuerySnapshot> getCategoriesStreamFirestore() {
    return firebaseFirestore
        .collection(FirestoreConstants.pathCategoryCollection)
        .orderBy(FirestoreConstants.id)
        .snapshots();
  }

  Future<List<Category>> getCategories(
      List<QueryDocumentSnapshot<Object?>> docsList) async {
    List<Category> resultList = [];
    if (docsList.isNotEmpty) {
      for (DocumentSnapshot doc in docsList) {
        Category category = Category.fromDocument(doc);
        resultList.add(category);
      }
      return Future.value(resultList);
    }
    return Future.value(resultList);
  }
}
