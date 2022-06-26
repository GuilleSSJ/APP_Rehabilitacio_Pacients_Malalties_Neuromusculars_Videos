import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/constants/constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/models/models.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;

  Status _status = Status.uninitialized;

  Status get status => _status;

  AuthProvider({
    required this.firebaseAuth,
    required this.prefs,
    required this.firebaseFirestore,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  String? getUserFirebaseFullname() {
    return prefs.getString(FirestoreConstants.nom);
  }

  bool? getBoolPref(String key) {
    return prefs.getBool(key);
  }

  String? getStringPref(String key) {
    return prefs.getString(key);
  }

  String? getUserFirebaseTherapist() {
    return prefs.getString(FirestoreConstants.chattingWith);
  }

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> handleSignOut() async {
    _status = Status.uninitialized;
    await firebaseAuth.signOut();
  }

  Future<bool> handleSignIn(email, password) async {
    UserCredential? userCredential;
    _status = Status.authenticating;
    notifyListeners();

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    if (userCredential != null) {
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();
        final List<DocumentSnapshot> documents = result.docs;
        if (documents.length == 0) {
          // Writing data to server because here is a new user
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.id: firebaseUser.uid,
            FirestoreConstants.nom: documents[0].get("nom"),
            FirestoreConstants.cognoms: documents[0].get("cognoms"),
            'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.chattingWith: documents[0].get("chattingWith")
          });

          // Write data to local storage
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.nom, documents[0].get("nom") ?? "");
        } else {
          // Already sign up, just get data from firestore
          DocumentSnapshot documentSnapshot = documents[0];
          NVRUser userChat = NVRUser.fromDocument(documentSnapshot);
          // Write data to local
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nom, userChat.nom);
          
          await prefs.setString(FirestoreConstants.email, userChat.email);
         
          await prefs.setString(
              FirestoreConstants.cognoms, documentSnapshot.get("cognoms"));
          await prefs.setString(FirestoreConstants.chattingWith,
              documentSnapshot.get("chattingWith"));
          bool isAdmin = await documentSnapshot.get("isAdmin");
          await prefs.setBool(FirestoreConstants.isAdmin, isAdmin);
          if (!isAdmin) {
            await prefs.setStringList(FirestoreConstants.videos,
                documentSnapshot.get("llistaVideos").cast<String>());
            await prefs.setString(
                FirestoreConstants.nhc, documentSnapshot.get("nhc"));
            await prefs.setString(FirestoreConstants.dataNaixement,
                documentSnapshot.get("dataNaixement"));

            final QuerySnapshot result2 = await firebaseFirestore
                .collection(FirestoreConstants.pathUserCollection)
                .where(FirestoreConstants.id,
                    isEqualTo: documentSnapshot.get("chattingWith"))
                .get();
            final DocumentSnapshot therapistDoc = result2.docs[0];

            if (therapistDoc.exists) {
              await prefs.setString(
                  FirestoreConstants.nomTerapeuta, therapistDoc.get("nom"));
              await prefs.setString(FirestoreConstants.cognomsTerapeuta,
                  therapistDoc.get("cognoms"));
            }
          } else {
            await prefs.setStringList(FirestoreConstants.llistaPacients,
                documentSnapshot.get("llistaPacients").cast<String>());
            await prefs.setString(FirestoreConstants.teraphistId,
                documentSnapshot.get("id"));
          }
        }
        _status = Status.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        return false;
      }
    } else {
      _status = Status.authenticateCanceled;
      notifyListeners();
      return false;
    }
  }

  Future<DocumentSnapshot> getUserDocument(String currentUserId) async {
    final QuerySnapshot result = await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.id, isEqualTo: currentUserId)
        .get();
    return result.docs[0];
  }

  void signUp(
      BuildContext context,
      GlobalKey<FormState> formkey,
      TextEditingController email,
      TextEditingController password,
      TextEditingController name,
      TextEditingController surname,
      TextEditingController nhc,
      TextEditingController date) async {
    String? errorMessage;
    if (formkey.currentState!.validate()) {
      try {
        var therapistId = prefs.getString(FirestoreConstants.teraphistId);
        await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email.text, password: password.text)
            .then(
          (value) {
            postDetailsToFirestore(context, value.user, name.text, surname.text,
                nhc.text, date.text, therapistId!);
          },
        ).catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage);
      }
    }
  }

  postDetailsToFirestore(BuildContext context, User? user, String name,
      String surname, String nhc, String date, String therapistId) async {
    NVRUser nvrUser = NVRUser(
        id: user!.uid,
        email: user.email.toString(),
        nom: name,
        cognoms: surname,
        nhc: nhc,
        dataNaixement: date,
        videos: [],
        isAdmin: false,
        chattingWith: therapistId,
        patientsIdList: [],
        doneActivities: []);
    await firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(user.uid)
        .set(nvrUser.toMap());

    firebaseFirestore
        .collection(FirestoreConstants.pathUserCollection)
        .doc(therapistId)
        .update({
      "llistaPacients": FieldValue.arrayUnion([user.uid])
    });

    List <String> llistaPacients = prefs.getStringList("llistaPacients")!.cast<String>();
    llistaPacients.add(user.uid);

    await prefs.setStringList(FirestoreConstants.llistaPacients,
               llistaPacients);

    Fluttertoast.showToast(msg: "Pacient registrat amb èxit! :) ");
  }

  // googleSignOut() async {
  //   googleSignInAccount = await _googleSignIn.signOut();
  //   notifyListeners();
  // }
}
