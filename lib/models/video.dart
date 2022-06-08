import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';

class Video {
  String videoId;
  String categoryId;
  String title;
  String url;
  String photoURL;

  Video({
    required this.videoId,
    required this.categoryId,
    required this.title,
    required this.url,
    required this.photoURL
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.videoId: this.videoId,
      FirestoreConstants.categoryId: this.categoryId,
      FirestoreConstants.title: this.title,
      FirestoreConstants.url: this.url
    };
  }

  factory Video.fromDocument(DocumentSnapshot doc, videoURL, imageURL) {
    String videoId = doc.get(FirestoreConstants.videoId);
    String categoryId = doc.get(FirestoreConstants.categoryId);
    String title = doc.get(FirestoreConstants.title);
    String url = videoURL;
    String photoURL = imageURL;
    return Video(videoId: videoId, categoryId: categoryId, title: title, url: url, photoURL:photoURL);
  }

  String getVideoID() {
    return videoId;
  }
}
