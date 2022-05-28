
import 'package:flutter/material.dart';
import 'package:app_video_rehabilitacio_neuromuscular/chatItemWidget.dart';


class ChatListWidget extends StatelessWidget{
  final ScrollController listScrollController = new ScrollController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Flexible(
        child: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemBuilder: (context, index) => ChatItemWidget(index),
          itemCount: 20,
          reverse: true,
          controller: listScrollController,
        ));
  }
}