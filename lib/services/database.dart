import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class DataBaseService {


  final CollectionReference patientCollection = FirebaseFirestore.instance.collection('Patient');

  Stream<QuerySnapshot> get patients {
    return patientCollection.snapshots();
  }

  Future<bool> loginWithNHC(String nhc) async {
   bool blnRet = false;
    Stream document;
    document = (FirebaseFirestore.instance
        .collection("Patient")
        .where("Nhc", isEqualTo: nhc)
        .snapshots());
    if (document.first.toString().isNotEmpty) {
      blnRet = true;
    }
    return blnRet;
 }
}