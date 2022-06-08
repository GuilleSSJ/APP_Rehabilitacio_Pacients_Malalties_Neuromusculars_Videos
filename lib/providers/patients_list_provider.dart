import 'dart:io';
import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientsListProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  PatientsListProvider(
      {required this.firebaseFirestore,
      required this.prefs,
      required this.firebaseStorage});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  bool? getBoolPref(String key) {
    return prefs.getBool(key);
  }

  List<String>? getPrefStringList(String key) {
    return prefs.getStringList(key);
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

  Stream<QuerySnapshot> getPatientsStreamFireStore(
      List<String> patientsIdList) {
    return firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where('id', whereIn: patientsIdList)
        .orderBy('nom')
        .snapshots();
  }

  Future<List<NVRUser>> getPatientsList(
      List<String> patientsList, String pathCollection) async {
    List<NVRUser> resultList = [];

    if (patientsList.isNotEmpty) {
      for (var patientId in patientsList) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: patientId)
            .get();
        if (result.docs.isNotEmpty) {
          DocumentSnapshot patientDoc = result.docs[0];
          NVRUser nvrUser = NVRUser.fromDocument(patientDoc);
          resultList.add(nvrUser);
        }
      }
    }
    return resultList;
  }
}
