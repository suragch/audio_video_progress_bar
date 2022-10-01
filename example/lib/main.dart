import 'package:audio_video_progress_bar_example/audio_player_manager.dart';
import 'package:flutter/material.dart';

import 'full_example.dart';
import 'basic_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeVariation>(
      valueListenable: themeNotifier,
      builder: (context, value, child) {
        return MaterialApp(
          theme: ThemeData(
              primarySwatch: value.color, brightness: value.brightness),
          home: const HomeWidget(),
        );
      },
    );
  }
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late AudioPlayerManager manager;

  @override
  void initState() {
    super.initState();
    manager = AudioPlayerManager();
    manager.init();
  }

  @override
  void dispose() {
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 2,
      itemBuilder: ((context, index) {
        if (index == 0) {
          return FullExample(audioPlayerManager: manager);
        } else {
          return BasicExample(audioPlayerManager: manager);
        }
      }),
    );
  }
}
