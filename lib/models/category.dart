import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';

class Category {
  String id;
  List<String> llistaVideos;
  String nom;
  String photoURL;

  Category(
      {required this.id,
      required this.llistaVideos,
      required this.nom,
      required this.photoURL});

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.id: this.id,
      FirestoreConstants.llistaVideos: this.llistaVideos,
      FirestoreConstants.nom: this.nom,
      FirestoreConstants.photoURL: this.photoURL
    };
  }

  factory Category.fromDocument(DocumentSnapshot doc) {
    String id = doc.get(FirestoreConstants.id);
    List<String> llistaVideos =
        doc.get(FirestoreConstants.llistaVideos).cast<String>();
    String nom = doc.get(FirestoreConstants.nom);
    String photoURL = doc.get(FirestoreConstants.photoURL);
    return Category(
        id: id, llistaVideos: llistaVideos, nom: nom, photoURL: photoURL);
  }

  String getVideoID() {
    return id;
  }
}
