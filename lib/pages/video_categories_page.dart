import 'dart:async';
import 'dart:io';

import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/login_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/play_page.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import '../widgets/widgets.dart';


class Categories extends StatefulWidget {
  const Categories({Key? key, this.patientId = ""}) : super(key: key);
  final String patientId;

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
  bool isAdmin = false;
  List<String> userVideos = [];
  late NVRUser nvrUser;

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
      nvrUser = value;
      isAdmin = videoProvider.getBoolPref("isAdmin")!;
      if (isAdmin) {
      setUserVideos(widget.patientId);
      } // Future is completed with a value.
    });
  });
  super.initState();
  }

  void setUserVideos(String patientId){
     videoProvider.getPatientAssignedVideos(patientId).then((value) {
    setState(() {
      userVideos = value;
    });
    });
  }

  Future<NVRUser> getUser() async{
    DocumentSnapshot userDoc= await authProvider.getUserDocument(currentUserId);
    return NVRUser.fromDocument(userDoc);
  }

Future<List<String>> getCategoryVideosFutureList(DocumentSnapshot? document) async{
    return await document?.get(FirestoreConstants.videos).cast<String>();
  }

  List<String> getCategoryVideosList(DocumentSnapshot document) {
    List<String> videoList = [];
    getCategoryVideosFutureList(document).then((value) {
    setState(() {
      videoList = value; // Future is completed with a value.
    });
  });
  return videoList;
  }
  
  
  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
        if (document != null) {
          return Container(
            child: TextButton(
              child: Row(
                children: <Widget>[
                  Material(
                    child: Icon(
                            Icons.task,
                            size: 50,
                            color:Colors.orange,
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
                              document.get('nom'),
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
                List<String> categoryVideos = await document.get(FirestoreConstants.videos).cast<String>();
                List<Video> videos = await videoProvider.getVideoList(nvrUser.videos, categoryVideos, FirestoreConstants.pathVideoCollection, isAdmin);
                if (videos.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayPage(
                      arguments: PlayPageArguments(
                        videos: videos,
                        userVideos: userVideos,
                        categoryName: document.get('nom'),
                        categoryVideos: categoryVideos
                      ),
                      patientId: widget.patientId,
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
           floatingActionButton: isAdmin ? FloatingActionButton.extended(  
                  onPressed: () {},  
                  backgroundColor: Colors.orange,
                  icon: Icon(Icons.add),  
                  label: Text("Nova categoria"),  
                ) : null
    );
  }
  }