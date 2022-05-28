class VideoClip {
  final String fileName;
  final String thumbName;
  final String title;
  final String parent;
  int runningTime;

  VideoClip(this.title, this.fileName, this.thumbName, this.runningTime, this.parent);

  String videoPath() {
    return "$parent/$fileName";
  }

  String thumbPath() {
    return "$parent/$thumbName";
  }


  static List<VideoClip> localClips = [
    VideoClip("Posar mitjons", "posar_mitjons.mp4", "posar_mitjons.png", 0, "embed"),
    VideoClip("Desplaçar-se lateralment al llit", "desplacarse_lateralment_llit.mp4", "desplacarse_llit.png", 0, "embed"),
    VideoClip("Agafar CDS", "agafar_cds.mp4", "agafar_cds.png", 0, "embed"),
    VideoClip("Fer nusos", "fer_nusos.mp4", "fer_nusos.png", 0, "embed"),
  ];

  static List<VideoClip> remoteClips = [
    VideoClip("For Bigger Fun", "ForBiggerFun.mp4", "images/ForBiggerFun.jpg", 0, "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"),
    VideoClip("Elephant Dream", "ElephantsDream.mp4", "images/ForBiggerBlazes.jpg", 0, "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"),
    VideoClip("BigBuckBunny", "BigBuckBunny.mp4", "images/BigBuckBunny.jpg", 0, "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample"),
  ];
}

