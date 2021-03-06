import 'dart:async';
import 'dart:math';
import 'package:app_video_rehabilitacio_neuromuscular/constants/firestore_constants.dart';
import 'package:app_video_rehabilitacio_neuromuscular/providers/video_category_provider.dart';
import 'package:app_video_rehabilitacio_neuromuscular/models/video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import '../providers/chat_provider.dart';

class PlayPage extends StatefulWidget {
  PlayPage({Key? key, required this.arguments, this.patientId = ""})
      : super(key: key);

  final PlayPageArguments arguments;
  final String patientId;

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  VideoPlayerController? _controller;
  late CategoryProvider videoProvider;
  late ChatProvider chatProvider;
  late bool isAdmin;
  late List<bool> assignedVideos;
  late List<bool> doneActivities;

  List<Video> get _clips {
    return widget.arguments.videos;
  }

  List<String> get _userVideos {
    return widget.arguments.userVideos;
  }

  List<String> get _categoryVideos {
    return widget.arguments.categoryVideos;
  }

  List<bool> get _doneActivities {
    return widget.arguments.doneActivities;
  }

  var _playingIndex = -1;
  var _disposed = false;
  var _isFullScreen = false;
  var _isEndOfClip = false;
  var _progress = 0.0;
  var _showingDialog = false;
  Timer? _timerVisibleControl;
  double _controlAlpha = 1.0;

  var _playing = false;
  bool get _isPlaying {
    return _playing;
  }

  set _isPlaying(bool value) {
    _playing = value;
    _timerVisibleControl?.cancel();
    if (value) {
      _timerVisibleControl = Timer(Duration(seconds: 2), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 0.0;
        });
      });
    } else {
      _timerVisibleControl = Timer(Duration(milliseconds: 200), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 1.0;
        });
      });
    }
  }

  void _onTapVideo() {
    debugPrint("_onTapVideo $_controlAlpha");
    setState(() {
      _controlAlpha = _controlAlpha > 0 ? 0 : 1;
    });
    _timerVisibleControl?.cancel();
    _timerVisibleControl = Timer(Duration(seconds: 2), () {
      if (_isPlaying) {
        setState(() {
          _controlAlpha = 0.0;
        });
      }
    });
  }

  @override
  void initState() {
    videoProvider = context.read<CategoryProvider>();
    chatProvider = context.read<ChatProvider>();
    assignedVideos = List.filled(_categoryVideos.length, false);
    doneActivities = _doneActivities;
    Wakelock.enable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _initializeAndPlay(0);
    isAdmin = videoProvider.getBoolPref("isAdmin")!;
    if (isAdmin) {
      checkAssignedVideos(_userVideos, _categoryVideos);
    }
    super.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    _timerVisibleControl?.cancel();
    Wakelock.disable();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _exitFullScreen();
    _controller?.pause(); // mute instantly
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _toggleFullscreen() async {
    if (_isFullScreen) {
      _exitFullScreen();
    } else {
      _enterFullScreen();
    }
  }

  void _enterFullScreen() async {
    debugPrint("enterFullScreen");
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    if (_disposed) return;
    setState(() {
      _isFullScreen = true;
    });
  }

  void _exitFullScreen() async {
    debugPrint("exitFullScreen");
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (_disposed) return;
    setState(() {
      _isFullScreen = false;
    });
  }

  void _initializeAndPlay(int index) async {
    print("_initializeAndPlay ---------> $index");
    final clip = _clips[index];

    final controller = //clip.parent.startsWith("http")
        VideoPlayerController.network(clip.url);
    //: VideoPlayerController.asset(clip.videoPath());

    final old = _controller;
    _controller = controller;
    if (old != null) {
      old.removeListener(_onControllerUpdated);
      old.pause();
      debugPrint("---- old contoller paused.");
    }

    debugPrint("---- controller changed.");
    setState(() {});

    controller
      ..initialize().then((_) {
        debugPrint("---- controller initialized");
        old?.dispose();
        _playingIndex = index;
        _duration = null;
        _position = null;
        controller.addListener(_onControllerUpdated);
        controller.play();
        setState(() {});
      });
  }

  var _updateProgressInterval = 0.0;
  Duration? _duration;
  Duration? _position;

  void _onControllerUpdated() async {
    if (_disposed) return;
    // blocking too many updation
    // important !!
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) {
      return;
    }
    _updateProgressInterval = now + 500.0;

    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.isInitialized) return;
    if (_duration == null) {
      _duration = _controller!.value.duration;
    }
    var duration = _duration;
    if (duration == null) return;

    var position = await controller.position;
    _position = position;
    final playing = controller.value.isPlaying;
    final isEndOfClip = position!.inMilliseconds > 0 &&
        position.inSeconds + 1 >= duration.inSeconds;
    if (playing) {
      // handle progress indicator
      if (_disposed) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }

    // handle clip end
    if (_isPlaying != playing || _isEndOfClip != isEndOfClip) {
      _isPlaying = playing;
      _isEndOfClip = isEndOfClip;
      debugPrint(
          "updated -----> isPlaying=$playing / isEndOfClip=$isEndOfClip");
      if (isEndOfClip && !playing) {
        debugPrint(
            "========================== End of Clip / Handle NEXT ========================== ");
        final isComplete = _playingIndex == _clips.length - 1;
        if (isComplete) {
          print("reprodu??ts tots!!");
          if (!_showingDialog) {
            _showingDialog = true;
            _showPlayedAllDialog().then((value) {
              _exitFullScreen();
              _showingDialog = false;
            });
          }
        } else {
          _initializeAndPlay(_playingIndex + 1);
        }
      }
    }
  }

  Future<bool?> _showPlayedAllDialog() async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Text("S'han reprodu??t tots els v??deos.")),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Close"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          centerTitle: true,
          title: Text(
            widget.arguments.categoryName,
            style:
                TextStyle(fontSize: 16.0, fontFamily: 'Glacial Indifference'),
          ),
        ),
        body: _isFullScreen
            ? Container(
                child: Center(child: _playView(context)),
                decoration: BoxDecoration(color: Colors.black),
              )
            : Column(children: <Widget>[
                Container(
                  child: Center(child: _playView(context)),
                  decoration: BoxDecoration(color: Colors.black),
                ),
                Expanded(
                  child: _listView(),
                ),
              ]),
        floatingActionButton: isAdmin
            ? FloatingActionButton.extended(
                onPressed: () {},
                backgroundColor: Colors.orange,
                icon: Icon(Icons.add),
                label: Text("Afegir v??deo"),
              )
            : null);
  }

  void _onTapCard(int index) {
    _initializeAndPlay(index);
  }

  Widget _playView(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return AspectRatio(
        //aspectRatio: controller.value.aspectRatio,
        aspectRatio: 16.0 / 9.0,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              child: VideoPlayer(controller),
              onTap: _onTapVideo,
            ),
            _controlAlpha > 0
                ? AnimatedOpacity(
                    opacity: _controlAlpha,
                    duration: Duration(milliseconds: 250),
                    child: _controlView(context),
                  )
                : Container(),
          ],
        ),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Center(
            child: Text(
          "Preparant...",
          style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 18.0),
        )),
      );
    }
  }

  Widget _listView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _clips.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          splashColor: Colors.blue[100],
          onTap: () {
            _onTapCard(index);
          },
          child: _buildCard(index),
        );
      },
    ).build(context);
  }

  Widget _controlView(BuildContext context) {
    return Column(
      children: <Widget>[
        _topUI(),
        Expanded(
          child: _centerUI(),
        ),
        _bottomUI()
      ],
    );
  }

  Widget _centerUI() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          onPressed: () async {
            final index = _playingIndex - 1;
            if (index >= 0 && _clips.length > 0) {
              _initializeAndPlay(index);
            }
          },
          child: Icon(
            Icons.fast_rewind,
            size: 36.0,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_isPlaying) {
              _controller?.pause();
              _isPlaying = false;
            } else {
              final controller = _controller;
              if (controller != null) {
                final pos = _position?.inSeconds ?? 0;
                final dur = _duration?.inSeconds ?? 0;
                final isEnd = pos == dur;
                if (isEnd) {
                  _initializeAndPlay(_playingIndex);
                } else {
                  controller.play();
                }
              }
            }
            setState(() {});
          },
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 56.0,
            color: Colors.white,
          ),
        ),
        TextButton(
          onPressed: () async {
            final index = _playingIndex + 1;
            if (index < _clips.length) {
              _initializeAndPlay(index);
            }
          },
          child: Icon(
            Icons.fast_forward,
            size: 36.0,
            color: Colors.white,
          ),
        ),
      ],
    ));
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _topUI() {
    final noMute = (_controller?.value.volume ?? 0) > 0;
    final duration = _duration?.inSeconds ?? 0;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration - head);
    final min = convertTwo(remained ~/ 60.0);
    final sec = convertTwo(remained % 60);
    return Row(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 4.0,
                      color: Color.fromARGB(50, 0, 0, 0)),
                ]),
                child: Icon(
                  noMute ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                )),
          ),
          onTap: () {
            if (noMute) {
              _controller?.setVolume(0);
            } else {
              _controller?.setVolume(1.0);
            }
            setState(() {});
          },
        ),
        Expanded(
          child: Container(),
        ),
        Text(
          "$min:$sec",
          style: TextStyle(
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        SizedBox(width: 10)
      ],
    );
  }

  Widget _bottomUI() {
    return Row(
      children: <Widget>[
        SizedBox(width: 20),
        Expanded(
          child: Slider(
            value: max(0, min(_progress * 100, 100)),
            min: 0,
            max: 100,
            onChanged: (value) {
              setState(() {
                _progress = value * 0.01;
              });
            },
            onChangeStart: (value) {
              debugPrint("-- onChangeStart $value");
              _controller?.pause();
            },
            onChangeEnd: (value) {
              debugPrint("-- onChangeEnd $value");
              final duration = _controller?.value.duration;
              if (duration != null) {
                var newValue = max(0, min(value, 99)) * 0.01;
                var millis = (duration.inMilliseconds * newValue).toInt();
                _controller?.seekTo(Duration(milliseconds: millis));
                _controller?.play();
              }
            },
          ),
        ),
        IconButton(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.yellow,
          icon: Icon(
            Icons.fullscreen,
            color: Colors.white,
          ),
          onPressed: _toggleFullscreen,
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    final clip = _clips[index];
    final playing = index == _playingIndex;
    bool isAssigned = false;
    if (isAdmin && assignedVideos.length > 0) {
      isAssigned = assignedVideos[index];
    }
    /*String runtime;
    if (clip.runningTime > 60) {
      runtime = "${clip.runningTime ~/ 60}' ${clip.runningTime % 60}''";
    } else {
      runtime = "${clip.runningTime % 60}''";
    }*/
    return Card(
        child: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: //clip.parent.startsWith("http")
                      Image.network(clip.photoURL,
                          width: 70, height: 50, fit: BoxFit.fill)
                  //: Image.asset(clip.thumbPath(), width: 70, height: 50, fit: BoxFit.fill),
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
                child: isAdmin
                    ? ElevatedButton(
                        onPressed: () {
                          setState(
                            () {
                              showAssignAlertDialog(context, index, isAssigned);
                            },
                          );
                        },
                        child: !isAssigned
                            ? Text('Assignar',
                                style: TextStyle(color: Colors.white))
                            : Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                        ))
                    : IconButton(
                        onPressed: () {
                          setState(
                            () {
                              showInfoAlertDialog(context, index);
                            },
                          );
                        },
                        icon: Icon(
                          Icons.info,
                          color: Colors.black,
                        ),
                      ),
              ),
              if (!isAdmin)
                if (doneActivities.isNotEmpty)
                  if (doneActivities[_userVideos.indexOf(_categoryVideos[index])])
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
        color: playing ? Colors.blue : Colors.white);
  }

  void checkAssignedVideos(
      List<String> userVideos, List<String> categoryVideos) {
    for (var i = 0; i < userVideos.length; i++) {
      int index = categoryVideos.indexOf(userVideos[i]);
      if (index >= 0) {
        assignedVideos[index] = true;
      }
    }
  }

  void sendCompletedMessage(int index) {
    Video video = _clips[index];
    String currentUserId = videoProvider.getPref(FirestoreConstants.id)!;
    String peerId = videoProvider.getPref(FirestoreConstants.chattingWith)!;
    String groupChatId = '$currentUserId-$peerId';
    String content = videoProvider.getPref(FirestoreConstants.nom)! +
        " ha completat l'activitat " +
        "'" +
        video.title +
        "'" +
        " de la categoria " +
        "'" +
        widget.arguments.categoryName +
        "'.";
    chatProvider.sendMessage(
        content, TypeMessage.text, groupChatId, currentUserId, peerId);
  }

  void sendHelpMessage(int index) {
    Video video = _clips[index];
    String currentUserId = videoProvider.getPref(FirestoreConstants.id)!;
    String peerId = videoProvider.getPref(FirestoreConstants.chattingWith)!;
    String groupChatId = '$currentUserId-$peerId';
    String content = videoProvider.getPref(FirestoreConstants.nom)! +
        " necessita ajuda per fer l'activitat " +
        "'" +
        video.title +
        "'" +
        " de la categoria " +
        "'" +
        widget.arguments.categoryName +
        "'.";
    chatProvider.sendMessage(
        content, TypeMessage.text, groupChatId, currentUserId, peerId);
  }

  showAssignAlertDialog(BuildContext context, int index, bool isAssigned) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel??lar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        String categoryVideoId = _categoryVideos[index];
        if (!isAssigned && !_userVideos.contains(categoryVideoId)) {
          _userVideos.add(categoryVideoId);
          doneActivities.add(false);
        } else {
           doneActivities.removeAt(_userVideos.indexOf(categoryVideoId));
          _userVideos.remove(categoryVideoId);
        }
        assignedVideos[index] = !isAssigned;
        isAssigned = assignedVideos[index];
        videoProvider.updateActivitiesList(widget.patientId, _userVideos);
        videoProvider.updateDoneActivities(widget.patientId, doneActivities);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alerta de confirmaci??"),
      content: assignedVideos[index]
          ? Text("Segur que vols treure l'activitat al pacient?")
          : Text("Segur que vols assignar l'activitat al pacient?"),
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

  showInfoAlertDialog(BuildContext context, int index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel??lar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget completedButton = FlatButton(
      child: Text("Completar"),
      onPressed: () {
        String categoryVideoId = _categoryVideos[index];
        doneActivities[_userVideos.indexOf(categoryVideoId)] = true;
        var userID = videoProvider.getPref(FirestoreConstants.id);
        videoProvider.updateDoneActivities(userID, doneActivities);
        sendCompletedMessage(index);
        Navigator.of(context).pop();
      },
    );
    Widget helpButton = FlatButton(
      child: Text("Demanar Ajuda"),
      onPressed: () {
        sendHelpMessage(index);
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Qu?? vols fer amb l'activitat?"),
      content: Text(
          "Si has finalitzat l'activitat sense cap prblema, prem el bot?? 'Completar'. Si pel contrari tens problemes per dur-la a terme, prem el bot?? 'Demanar Ajuda'."),
      actions: doneActivities[_userVideos.indexOf(_categoryVideos[index])]
          ? [cancelButton, helpButton]
          : [cancelButton, helpButton, completedButton],
    );
    // show the dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class PlayPageArguments {
  final List<Video> videos;
  final List<String> userVideos;
  final String categoryName;
  final List<String> categoryVideos;
  final List<bool> doneActivities;

  PlayPageArguments(
      {required this.videos,
      required this.userVideos,
      required this.doneActivities,
      required this.categoryName,
      required this.categoryVideos});
}
