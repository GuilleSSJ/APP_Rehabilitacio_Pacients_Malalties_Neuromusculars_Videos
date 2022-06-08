import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';

class NVRUser {
  String id;
  String cognom1;
  String cognom2;
  String nom;
  String nhc;
  int edat;
  bool isAdmin;
  String chattingWith;
  List<String> videos;
  List<String> patientsIdList;

  NVRUser({required this.id, required this.nom, required this.cognom1, required this.cognom2, required this.nhc, required this.edat,required this.videos, required this.isAdmin, required this.chattingWith, required this.patientsIdList});

  Map<String, String> toJson() {
    return {
        FirestoreConstants.nom: nom,
      FirestoreConstants.cognom1: cognom1,
      FirestoreConstants.cognom2: cognom2,
      FirestoreConstants.nhc: cognom2,
      FirestoreConstants.edat: cognom2
    };
  }

  factory NVRUser.fromDocument(DocumentSnapshot doc) {
    String nom = "";
    String cognom1 = "";
    String cognom2 = "";
    String chattingWith = "";
    String nhc = "";
    int edat = 0;
    List<String> videos = [];
    bool isAdmin = false;
    List<String> patientsIdList = [];

    try {
      nom = doc.get(FirestoreConstants.nom);
    } catch (e) {}
    try {
      cognom1 = doc.get(FirestoreConstants.cognom1);
    } catch (e) {}
    try {
      cognom2 = doc.get(FirestoreConstants.cognom2);
    } catch (e) {}
    try {
      nhc = doc.get(FirestoreConstants.nhc);
    } catch (e) {}
    try {
      edat = doc.get(FirestoreConstants.edat);
    } catch (e) {}
    try {
      chattingWith = doc.get(FirestoreConstants.chattingWith);
    } catch (e) {}
    try {
      videos = doc.get(FirestoreConstants.videos).cast<String>();
    } catch (e) {}
    try {
      isAdmin = doc.get(FirestoreConstants.isAdmin);
    } catch (e) {}
    try {
      patientsIdList = doc.get(FirestoreConstants.llistaPacients).cast<String>();
    } catch (e) {}
    return NVRUser(
      id: doc.id,
      nom: nom,
      cognom1: cognom1,
      cognom2: cognom2,
      nhc: nhc,
      edat: edat,
      chattingWith: chattingWith,
      videos: videos,
      isAdmin: isAdmin, 
      patientsIdList: patientsIdList
    );
  }

  List<String> getUserAssignedVideos() {
    return videos;
  }

  List<String> getPatientsIdList() {
    return patientsIdList;
  }

  String getName() {
    return nom;
  }

   String getNHC() {
    return nhc;
  }

   String getAge() {
    return edat.toString();
  }

}
