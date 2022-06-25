import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:intl/intl.dart';

class NVRUser {
  String id;
  String cognoms;
  String nom;
  String nhc;
  String dataNaixement;
  bool isAdmin;
  String chattingWith;
  List<String> videos;
  List<String> patientsIdList;

  NVRUser(
      {required this.id,
      required this.nom,
      required this.cognoms,
      required this.nhc,
      required this.dataNaixement,
      required this.videos,
      required this.isAdmin,
      required this.chattingWith,
      required this.patientsIdList});

  Map<String, dynamic> toMap() {
    return {
      FirestoreConstants.id: id,
      FirestoreConstants.nom: nom,
      FirestoreConstants.cognoms: cognoms,
      FirestoreConstants.nhc: nhc,
      FirestoreConstants.isAdmin: isAdmin,
      FirestoreConstants.dataNaixement: dataNaixement,
      FirestoreConstants.chattingWith: chattingWith,
      FirestoreConstants.llistaVideos: videos,
    };
  }

  factory NVRUser.fromDocument(DocumentSnapshot doc) {
    String nom = "";
    String cognoms = "";
    String chattingWith = "";
    String nhc = "";
    String dataNaixement = "";
    List<String> videos = [];
    bool isAdmin = false;
    List<String> patientsIdList = [];

    try {
      nom = doc.get(FirestoreConstants.nom);
    } catch (e) {}
    try {
      cognoms = doc.get(FirestoreConstants.cognoms);
    } catch (e) {}
    try {
      nhc = doc.get(FirestoreConstants.nhc);
    } catch (e) {}
    try {
      dataNaixement = doc.get(FirestoreConstants.dataNaixement);
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
      patientsIdList =
          doc.get(FirestoreConstants.llistaPacients).cast<String>();
    } catch (e) {}
    return NVRUser(
        id: doc.id,
        nom: nom,
        cognoms: cognoms,
        nhc: nhc,
        dataNaixement: dataNaixement,
        chattingWith: chattingWith,
        videos: videos,
        isAdmin: isAdmin,
        patientsIdList: patientsIdList);
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
    var inputFormat = DateFormat('dd/M/yyyy');
    var date1 = inputFormat.parse(dataNaixement);

    var outputFormat = DateFormat('yyyy-MM-dd');
    var date2 = outputFormat.format(date1);

    DateTime birthDate = DateTime.parse(date2);
    DateTime today = DateTime.now();

    int age = today.year - birthDate.year;
    int month1 = today.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = today.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age.toString();
  }
}
