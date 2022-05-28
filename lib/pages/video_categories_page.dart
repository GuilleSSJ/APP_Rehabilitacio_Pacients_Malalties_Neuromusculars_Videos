import 'dart:async';
import 'dart:io';

import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/login_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/play_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/video_category_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/app_constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/color_constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/providers.dart';
import 'package:app_video_rehabilitacio_neuromuscular/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';


class Categories extends StatefulWidget {
  const Categories({ Key? key }) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

  int _limit = 20;
  int _limitIncrement = 20;
  String _textSearch = "";
  bool isLoading = false;

  late CategoryProvider videoProvider;
  late AuthProvider authProvider;
  late String currentUserId;
  late UserChat userChat;

  @override
  void initState() {
    videoProvider = context.read<CategoryProvider>();
    authProvider = context.read<AuthProvider>();
     if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    getUser().then((value) {
    setState(() {
      userChat = value; // Future is completed with a value.
    });
  });
    super.initState();
  }
  

  Future<UserChat> getUser() async{
    DocumentSnapshot userDoc= await authProvider.getUserDocument(currentUserId);
    return UserChat.fromDocument(userDoc);
  }
  
  /*Widget _buildCard(int index) {
    final clip = _clips[index];
    final playing = index == _playingIndex;
    String runtime;
    if (clip.runningTime > 60) {
      runtime = "${clip.runningTime ~/ 60}' ${clip.runningTime % 60}''";
    } else {
      runtime = "${clip.runningTime % 60}''";
    }
    return Card(
      child: Container(
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: clip.parent.startsWith("http")
                  ? Image.network(clip.thumbPath(), width: 70, height: 50, fit: BoxFit.fill)
                  : Image.asset(clip.thumbPath(), width: 70, height: 50, fit: BoxFit.fill),
            ),
            Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(clip.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Padding(
                      child: Text("$runtime", style: TextStyle(color: Colors.grey[500])),
                      padding: EdgeInsets.only(top: 3),
                    )
                  ]),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: playing
                  ? Icon(Icons.play_arrow)
                  : Icon(
                      Icons.play_arrow,
                      color: Colors.grey.shade300,
                    ),
            ),
          ],
        ),
      ),
    );
  }*/
  
  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
        if (document != null) {
          return Container(
            child: TextButton(
              child: Row(
                children: <Widget>[
                  Material(
                    child: /*userChat.photoUrl.isNotEmpty
                        ? Image.network(
                            userChat.photoUrl,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 50,
                                height: 50,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ColorConstants.themeColor,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                size: 50,
                                color: ColorConstants.greyColor,
                              );
                            },
                          )
                        : */Icon(
                            Icons.task,
                            size: 50,
                            color: Colors.orange,
                          ),
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                    clipBehavior: Clip.hardEdge,
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Text(
                              document?.get('nom'),
                              maxLines: 1,
                              style: TextStyle(color: ColorConstants.primaryColor),
                            ),
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 5),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.only(left: 20),
                    ),
                  ),
                ],
              ),
              onPressed: () async {
                List<String> categoryVideos = document.get(FirestoreConstants.videos).cast<String>();
                List<Video> videos = await videoProvider.getVideoList(userChat.videos, categoryVideos, FirestoreConstants.pathVideoCollection);
                if (videos.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayPage(
                      arguments: PlayPageArguments(
                        videos: videos
                      ),
                    ),
                  ),
                );
              }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(ColorConstants.greyColor2),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
            ),
            margin: EdgeInsets.only(bottom: 10, left: 5, right: 5),
          );
      } else {
      return SizedBox.shrink();
    }

      }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text(
          'Categories',
          style: TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
        ),
      ),

      body: Stack(
          children: <Widget>[
            // List
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: videoProvider.getStreamFireStore(FirestoreConstants.pathCategoryCollection, _limit),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                            itemCount: snapshot.data?.docs.length,
                          );
                        } else {
                          return Center(
                            child: Text("No hi ha categories"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: ColorConstants.themeColor,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            // Loading
            Positioned(
              child: isLoading ? LoadingView() : SizedBox.shrink(),
            )
          ],
        ),
    );
  }
  }