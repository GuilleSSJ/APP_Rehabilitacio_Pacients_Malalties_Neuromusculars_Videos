import 'package:app_video_rehabilitacio_neuromuscular/pages/manage_videos_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/pages/sign_up_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/patients_list_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/color_constants.dart';
import '../constants/firestore_constants.dart';
import '../models/nvr_user.dart';
import '../models/video.dart';
import '../providers/auth_provider.dart';
import 'login_page.dart';

class PatientsList extends StatefulWidget {
  const PatientsList({Key? key}) : super(key: key);

  @override
  State<PatientsList> createState() => _PatientsListState();
}

class _PatientsListState extends State<PatientsList> {
  late AuthProvider authProvider;
  late PatientsListProvider patientListProvider;
  late String currentUserId;
  bool isAdmin = false;
  List<String> userVideos = [];
  late NVRUser nvrUser;
  late Future resultsLoaded;
  List<String>? patientsIdList;

  // This list holds the data for the list view
  late Future<List<NVRUser>> _patientsList;
  late Future<List<NVRUser>> _foundPatients;

  get firebaseFirestore => null;

  @override
  initState() {
    patientListProvider = context.read<PatientsListProvider>();
    authProvider = context.read<AuthProvider>();
    if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = authProvider.getUserFirebaseId()!;
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
    patientsIdList = patientListProvider.getPrefStringList("llistaPacients")!;
    _patientsList = intializePatientsList(
        patientsIdList, FirestoreConstants.pathUserCollection);
    _foundPatients = _patientsList;
    super.initState();
  }

  Future<NVRUser> getUser() async {
    DocumentSnapshot userDoc =
        await authProvider.getUserDocument(currentUserId);
    return NVRUser.fromDocument(userDoc);
  }

  Future<List<NVRUser>> intializePatientsList(
      patientsList, pathCollection) async {
    return await patientListProvider.getPatientsList(
        patientsList, pathCollection);
  }

  // This function is called whenever the text field changes
  void _runFilter(String enteredName) {
    // if the search field is empty or only contains white-space, we'll display all users
    setState(() {
      if (enteredName.isEmpty) {
        _foundPatients = _patientsList;
      } else {
        _patientsList.then(
          (value) {
            _foundPatients = Future.value(value
                .where((user) => user
                    .getName()
                    .toLowerCase()
                    .contains(enteredName.toLowerCase()))
                .toList());
          },
        );
      }
    });
  }

  Widget buildItem(BuildContext context, NVRUser nvrUser) {
    return Card(
      key: ValueKey(nvrUser.getNHC()),
      color: Colors.orange,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Text(
          nvrUser.getNHC().toString(),
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        title: Text(nvrUser.getName(),
            style: const TextStyle(fontSize: 16, color: Colors.white)),
        subtitle: Text(
          nvrUser.getAge() + ' anys',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        onTap: () async {
          List<Video> userVideos =
              await patientListProvider.getUserVideoList(nvrUser.videos);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManageVideos(
                arguments: ManageVideosArguments(
                    userVideos: nvrUser.videos,
                    videos: userVideos,
                    patientId: nvrUser.id),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: Text(
            'Manteniment',
            style:
                TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: (value) => _runFilter(value),
                decoration: const InputDecoration(
                    labelText: 'Cercar', suffixIcon: Icon(Icons.search)),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: FutureBuilder<List<NVRUser>>(
                  future: _foundPatients,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if ((snapshot.data?.length ?? 0) > 0) {
                        return ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemBuilder: (context, index) => buildItem(
                              context, snapshot.data!.elementAt(index)),
                          itemCount: snapshot.data?.length,
                        );
                      } else {
                        return Center(
                          child: Text("No hi ha pacients"),
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
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
          backgroundColor: Colors.orange,
          icon: Icon(Icons.add),
          label: Text("Registrar Pacient"),
        ));
  }
}
