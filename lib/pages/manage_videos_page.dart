import 'package:app_video_rehabilitacio_neuromuscular/pages/video_categories_page.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/manage_videos_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/video.dart';
import '../providers/video_category_provider.dart';
import '../widgets/loading_view.dart';

class ManageVideos extends StatefulWidget {
  const ManageVideos({Key? key, required this.arguments}) : super(key: key);

  final ManageVideosArguments arguments;

  @override
  State<ManageVideos> createState() => _ManageVideosState();
}

class _ManageVideosState extends State<ManageVideos> {
  late CategoryProvider videoProvider;
  late ManageVideosProvider manageVideosProvider;
  late List<String> videosStringList;
  late List<bool> doneActivities;
  Future<List<Video>> currentVideos = Future.value([]);

  List<Video> get _clips {
    return widget.arguments.videos;
  }

  List<String> get _userVideos {
    return widget.arguments.userVideos;
  }

  String get _patientId {
    return widget.arguments.patientId;
  }

  @override
  void initState() {
    videoProvider = context.read<CategoryProvider>();
    manageVideosProvider = context.read<ManageVideosProvider>();
    currentVideos = Future.value(_clips);
    videosStringList = _userVideos;
    doneActivities = List.filled(videosStringList.length, false);
    manageVideosProvider
        .getUserActivitiesList(_patientId)
        .listen((event) async {
      if (event.docs.isNotEmpty) {
        videosStringList = event.docs[0].get("llistaVideos").cast<String>();
        doneActivities =
            event.docs[0].get("llistaActivitatsFetes").cast<bool>();
        setState(() {
          currentVideos =
              manageVideosProvider.getUserVideoList(videosStringList);
        });
      }
    });
    super.initState();
  }

  /*getUserActivities()  {
    await manageVideosProvider.getUserActivitiesList(_patientId);
  }*/

  Widget _buildCard(int index, userActivity) {
    return Card(
        child: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Image.network(userActivity.photoURL,
                      width: 70, height: 50, fit: BoxFit.fill)),
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(userActivity.title,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Padding(
                        //child: Text("$runtime", style: TextStyle(color: Colors.grey[500])),
                        padding: EdgeInsets.only(top: 3),
                      )
                    ]),
              ),
              Padding(
                  padding: EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () {
                      showAlertDialog(context, userActivity, index);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  )),
              if (doneActivities.isNotEmpty && doneActivities.asMap().containsKey(index))
                if (doneActivities[videosStringList.indexOf(userActivity.videoId)])
                  Positioned(
                    // will be positioned in the top right of the container
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                  )
            ],
          ),
        ),
        color: Colors.white);
  }

  showAlertDialog(BuildContext context, activity, index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel·lar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        String videoId = activity.videoId;
        videosStringList.remove(videoId);
        doneActivities.removeAt(index);
        videoProvider.updateActivitiesList(_patientId, videosStringList);
        videoProvider.updateDoneActivities(_patientId, doneActivities);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alerta de confirmació"),
      content: Text("Segur que vols treure l'activitat al pacient?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _listView(List<Video> userActivities) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: userActivities.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          splashColor: Colors.blue[100],
          child: _buildCard(index, userActivities[index]),
        );
      },
    ).build(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: Text(
            'Activitats actuals del pacient',
            style:
                TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
          ),
        ),
        body: FutureBuilder<List<Video>>(
            future: currentVideos,
            builder: (context, snapshots) {
              if (snapshots.hasData) {
                if ((snapshots.data?.length ?? 0) > 0) {
                  return Column(children: <Widget>[
                    Expanded(child: _listView(snapshots.data!)),
                  ]);
                } else {
                  return Center(
                    child: Text("Encara no hi ha activitats"),
                  );
                }
              } else {
                return LoadingView();
              }
            }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Categories(patientId: _patientId)),
            );
          },
          backgroundColor: Colors.orange,
          icon: Icon(Icons.add),
          label: Text("Afegir activitat"),
        ));
  }
}

class ManageVideosArguments {
  final List<Video> videos;
  final List<String> userVideos;
  final String patientId;
  ManageVideosArguments(
      {required this.videos,
      required this.userVideos,
      required this.patientId});
}
