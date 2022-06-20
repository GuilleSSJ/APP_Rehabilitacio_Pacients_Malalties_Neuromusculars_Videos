import 'dart:ffi';

import 'package:app_video_rehabilitacio_neuromuscular/constants/firestore_constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/conversationPage.dart';
import 'package:app_video_rehabilitacio_neuromuscular/models/nvr_user.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/chat_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/home_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/login_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/patients_list.page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/video_categories_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/home_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/profile.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/play_page.dart';
import 'package:provider/provider.dart';
//import 'package:firebase_core/firebase_core.dart';

class PagePrincipal extends StatefulWidget {
  PagePrincipal();
  @override
  _PagePrincipalState createState() => _PagePrincipalState();
}

class _PagePrincipalState extends State<PagePrincipal> {
  int selectedIndex = 0;
  late HomeProvider homeProvider;
  late AuthProvider authProvider;
  String currentUserId = "";
  String teraphistId = "";
  late NVRUser nvrUser;
  List<Widget> pantallas = [];
  bool isAdmin = false;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void initState() {
    authProvider = context.read<AuthProvider>();
    isAdmin = authProvider.getBoolPref("isAdmin")!;
    if (!isAdmin) {
      pantallas = [
        Categories(),
        ChatPage(
          arguments: ChatPageArguments(
              peerId:
                  authProvider.getStringPref(FirestoreConstants.chattingWith)!,
              peerNom:
                  authProvider.getStringPref(FirestoreConstants.nomTerapeuta)!,
              peerCognoms: authProvider
                  .getStringPref(FirestoreConstants.cognomsTerapeuta)!,
        ),
        ),
        Profile(),
      ];
    } else {
      pantallas = [
        PatientsList(),
        HomePage(),
      ];
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pantallas[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: isAdmin
            ? const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection_outlined),
                  label: 'Vídeos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Xat',
                ),
              ]
            : const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_collection_outlined),
                  label: 'Vídeos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_outlined),
                  label: 'Xat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: _onItemTapped,
      ),
    );
  }
}
