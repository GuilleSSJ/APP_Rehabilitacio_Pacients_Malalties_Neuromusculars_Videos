import 'package:app_video_rehabilitacio_neuromuscular/pages/video_categories_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/video.dart';
import '../providers/video_category_provider.dart';

class ManageVideos extends StatefulWidget {
  const ManageVideos({Key? key, required this.arguments}) : super(key: key);
  
  final ManageVideosArguments arguments;

  @override
  State<ManageVideos> createState() => _ManageVideosState();
}

class _ManageVideosState extends State<ManageVideos> {
  late CategoryProvider videoProvider;

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
    super.initState();
  }

  Widget _buildCard(int index) {
    final clip = _clips[index];
    return Card(
        child: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Image.network(clip.photoURL,
                          width: 70, height: 50, fit: BoxFit.fill)
                  ),
              Expanded(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(clip.title,
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
                child:IconButton(
                        onPressed: () {
                          setState(
                            () {
                              showAlertDialog(context, index);
                            },
                          );
                        },
                        icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                        ))
            ],
          ),
        ),
        color: Colors.white);
  }

  showAlertDialog(BuildContext context, int index) {
  // set up the buttons
  Widget cancelButton = FlatButton(
    child: Text("Cancel·lar"),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = FlatButton(
    child: Text("OK"),
    onPressed:  () {
      String videoId = _clips[index].videoId;
      _userVideos.remove(videoId);
      videoProvider.updateActivitiesList(_patientId, _userVideos);
      setState(() {
        _clips.removeAt(index);
      });
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

  Widget _listView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _clips.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          splashColor: Colors.blue[100],
          child: _buildCard(index),
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
          style: TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
        ),
      ),
      body: Column(children: <Widget>[
              Expanded(
                child: _clips.isNotEmpty? _listView() : Center(
                            child: Text("No hi ha activitats assignades"),
                          ),
              ),
            ]),
      floatingActionButton: FloatingActionButton.extended(  
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Categories(patientId:_patientId)
                    ),
              );
            },  
            backgroundColor: Colors.orange,
            icon: Icon(Icons.add),  
            label: Text("Afegir activitat"),  
          )
    );
  }
}


class ManageVideosArguments {
  final List<Video> videos;
  final List<String> userVideos;
  final String patientId;
  ManageVideosArguments({required this.videos, required this.userVideos, required this.patientId});
}
