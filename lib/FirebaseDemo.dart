import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/loginForm.dart';
import 'package:app_video_rehabilitacio_neuromuscular/principal.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/services/database.dart';


class FirebaseDemo extends StatefulWidget {
  const FirebaseDemo({ Key? key }) : super(key: key);

  @override
  State<FirebaseDemo> createState() => _FirebaseDemoState();
}

class _FirebaseDemoState extends State<FirebaseDemo> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Firestore Demo"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Patient').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
            if(!snapshot.hasData) return const Text('Loading data...');
            return Column(
              children: <Widget> [
                Text(snapshot.data.docs[0]['FullName']),
                Text(snapshot.data.docs[0]['Nhc']),

              ],
              );
        },
    ));
  }
}