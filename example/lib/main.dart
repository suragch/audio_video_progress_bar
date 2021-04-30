import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeVariation>(
        valueListenable: themeNotifier,
        builder: (context, value, child) {
          return MaterialApp(
            theme: ThemeData(
                primarySwatch: value.color, brightness: value.brightness),
            home: HomeWidget(),
          );
        });
  }
}

var themeNotifier = ValueNotifier<ThemeVariation>(
  ThemeVariation(Colors.blue, Brightness.light),
);

class ThemeVariation {
  const ThemeVariation(this.color, this.brightness);
  final MaterialColor color;
  final Brightness brightness;
}

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late AudioPlayer _player;
  final url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  late Stream<DurationState> _durationState;
  var _labelLocation = TimeLabelLocation.below;
  var _labelType = TimeLabelType.totalTime;

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
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("building app");
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _themeButtons(),
            _labelLocationButtons(),
            _labelTypeButtons(),
            Spacer(),
            _progressBar(),
            _playButton(),
          ],
        ),
      ),
    );
  }

  Wrap _themeButtons() {
    return Wrap(children: [
      OutlinedButton(
        child: Text('light'),
        onPressed: () {
          themeNotifier.value = ThemeVariation(Colors.blue, Brightness.light);
        },
      ),
      OutlinedButton(
        child: Text('dark'),
        onPressed: () {
          themeNotifier.value = ThemeVariation(Colors.blue, Brightness.dark);
        },
      ),
    ]);
  }

  Wrap _labelLocationButtons() {
    return Wrap(children: [
      OutlinedButton(
        child: Text('below'),
        onPressed: () {
          setState(() => _labelLocation = TimeLabelLocation.below);
        },
      ),
      OutlinedButton(
        child: Text('sides'),
        onPressed: () {
          setState(() => _labelLocation = TimeLabelLocation.sides);
        },
      ),
      OutlinedButton(
        child: Text('none'),
        onPressed: () {
          setState(() => _labelLocation = TimeLabelLocation.none);
        },
      ),
    ]);
  }

  Wrap _labelTypeButtons() {
    return Wrap(children: [
      OutlinedButton(
        child: Text('total time'),
        onPressed: () {
          setState(() => _labelType = TimeLabelType.totalTime);
        },
      ),
      OutlinedButton(
        child: Text('remaining time'),
        onPressed: () {
          setState(() => _labelType = TimeLabelType.remainingTime);
        },
      ),
    ]);
  }

  StreamBuilder<DurationState> _progressBar() {
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
          onSeek: (duration) {
            _player.seek(duration);
          },
          timeLabelLocation: _labelLocation,
          timeLabelType: _labelType,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
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
            width: 32.0,
            height: 32.0,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: Icon(Icons.play_arrow),
            iconSize: 32.0,
            onPressed: _player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: Icon(Icons.pause),
            iconSize: 32.0,
            onPressed: _player.pause,
          );
        } else {
          return IconButton(
            icon: Icon(Icons.replay),
            iconSize: 32.0,
            onPressed: () => _player.seek(Duration.zero),
          );
        }
      },
    );
  }
}

class DurationState {
  const DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
  final Duration progress;
  final Duration buffered;
  final Duration? total;
}
