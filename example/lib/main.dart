import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  debugRepaintTextRainbowEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  AudioPlayer _player;
  final url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  Stream<DurationState> _durationState;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _player.positionStream,
        _player.playbackEventStream,
        (position, playbackEvent) => DurationState(
              progress: position,
              buffered: playbackEvent.bufferedPosition,
              total: playbackEvent.duration,
            ));
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      print("An error occured $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("building app");
    return Scaffold(
      body: Column(
        
        children: [
          Spacer(),
          RepaintBoundary(
            child: ProgressBarWidget(
                durationState: _durationState, player: _player),
          ),
          RepaintBoundary(
            child: PlayPauseButton(player: _player),
          ),
        ],
      ),
    );
  }
}

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({
    Key key,
    @required Stream<DurationState> durationState,
    @required AudioPlayer player,
  })  : _durationState = durationState,
        _player = player,
        super(key: key);

  final Stream<DurationState> _durationState;
  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    print('building progress bar');
    return StreamBuilder<DurationState>(
      stream: _durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          //timeLabelLocation: TimeLabelLocation.none,
          onSeek: (duration) {
            _player.seek(duration);
          },
        );
      },
    );

    // ProgressBar(
    //   progress: Duration.zero,
    //   total: Duration(minutes: 5),
    //   onSeek: (duration) {
    //     _player.seek(duration);
    //   },
    // );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    Key key,
    @required AudioPlayer player,
  })  : _player = player,
        super(key: key);

  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    print('building play/pause button');
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 64.0,
            height: 64.0,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: Icon(Icons.play_arrow),
            iconSize: 64.0,
            onPressed: _player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: Icon(Icons.pause),
            iconSize: 64.0,
            onPressed: _player.pause,
          );
        } else {
          return IconButton(
            icon: Icon(Icons.replay),
            iconSize: 64.0,
            onPressed: () => _player.seek(Duration.zero),
          );
        }
      },
    );
  }
}

class DurationState {
  const DurationState({this.progress, this.buffered, this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
