import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';

class UserChat {
  String id;
  String cognom1;
  String cognom2;
  String nom;
  bool isAdmin;
  List<String> videos;

  UserChat({required this.id, required this.nom, required this.cognom1, required this.cognom2, required this.videos, required this.isAdmin});

  Map<String, String> toJson() {
    return {
        FirestoreConstants.nom: nom,
      FirestoreConstants.cognom1: cognom1,
      FirestoreConstants.cognom2: cognom2
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String nom = "";
    String cognom1 = "";
    String cognom2 = "";
    List<String> videos = [];
    bool isAdmin = false;
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
      videos = doc.get(FirestoreConstants.videos).cast<String>();
    } catch (e) {}
    try {
      isAdmin = doc.get(FirestoreConstants.isAdmin);
    } catch (e) {}
    return UserChat(
      id: doc.id,
      nom: nom,
      cognom1: cognom1,
      cognom2: cognom2,
      videos: videos,
      isAdmin: isAdmin, 
    );
  }
}
