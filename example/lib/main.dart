import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            child: ProgressBar(
              playingProgress: Duration(minutes: 2),
              bufferingProgress: Duration(minutes: 3),
              totalDuration: Duration(minutes: 5),
              baseBarColor: Colors.grey,
              playingBarColor: Colors.blue,
              bufferingBarColor: Colors.limeAccent,
              barHeight: 5.0,
              thumbColor: Colors.red,
              thumbRadius: 10.0,
              onSeek: (duration) {
                print('New duration: $duration');
              },
            ),
          ),
        ),
      ),
    );
  }
}