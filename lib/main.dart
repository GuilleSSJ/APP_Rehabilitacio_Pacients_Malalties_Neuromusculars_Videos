import 'package:app_video_rehabilitacio_neuromuscular/pages/home_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/login_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/pages.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/auth_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/chat_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/home_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/setting_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/video_category_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/loginForm.dart';
import 'package:app_video_rehabilitacio_neuromuscular/FirebaseDemo.dart';
import 'package:app_video_rehabilitacio_neuromuscular/principal.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_video_rehabilitacio_neuromuscular/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
   runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
      return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            firebaseAuth: FirebaseAuth.instance,
            //googleSignIn: GoogleSignIn(),
            prefs: this.prefs,
            firebaseFirestore: this.firebaseFirestore,
          ),
        ),
        Provider<SettingProvider>(
          create: (_) => SettingProvider(
            prefs: this.prefs,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
          ),
        ),
        Provider<HomeProvider>(
          create: (_) => HomeProvider(
            firebaseFirestore: this.firebaseFirestore,
          ),
        ),
        Provider<ChatProvider>(
          create: (_) => ChatProvider(
            prefs: this.prefs,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
          ),
        ),
        Provider<CategoryProvider>(
          create: (_) => CategoryProvider(
            prefs: this.prefs,
            firebaseFirestore: this.firebaseFirestore,
            firebaseStorage: this.firebaseStorage,
          ),
        ),
      ],
      child: MaterialApp(
      title: 'Planificació Cognitiva',
      theme: ThemeData(
        primaryColor: Colors.orange,
      ),
      
      home: AnimatedSplashScreen(
        splash: Image.asset(
          'images/stPau_logo.jpg',
        ),
        nextScreen: /*StreamBuilder(
    stream: DataBaseService().patients,
    builder: (context, AsyncSnapshot snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: CircularProgressIndicator(
			valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      } else {
        return Text(snapshot.data.toString());
      }
    },
  ),*/
        SplashPage(),
        backgroundColor: Colors.white,
        splashIconSize: 300,
      
      ),

      
    ),
  );

  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    return new ListTile(
      title: new Text("Nom:" + document['FullName']),
    );
  }
}
