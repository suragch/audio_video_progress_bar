# audio_video_progress_bar

A progress bar widget to show or change the position of an audio or video stream.

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/progress_bar_demo.gif)

## Example

Add the `ProgressBar` widget to your UI. A static example would look like this:

```dart
ProgressBar(
  progress: Duration(milliseconds: 1000),
  buffered: Duration(milliseconds: 2000),
  total: Duration(milliseconds: 5000),
  onSeek: (duration) {
    print('User selected a new time: $duration');
  },
),
```

However, you would normally wrap it in a `StreamBuilder` that is updated by an audio or video player. That might look something like this:

```dart
StreamBuilder<DurationState>(
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
    );
  },
),

...

class DurationState {
  const DurationState({this.progress, this.buffered, this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
```

You can check out the GitHub repo for the full [example](https://github.com/suragch/audio_video_progress_bar/tree/master/example) using the [just_audio](https://pub.dev/packages/just_audio) plugin. There is no requirement to use `just_audio` or even a `StreamBuilder`, though. You can use any audio or video player that provides updates about the current play location. Just rebuild the `ProgressBar` widget with the new `Duration` states.

You'll probably want to add other buttons like start and pause, but these are not included with this package. They aren't hard to build, though, and you can find an example in the GitHub repo.

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/progress_bar_demo_with_buttons.gif)

## Customization

The default colors use the theme's primary color, so changing the theme will also update this widget:

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/deep_purple_theme.png)

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/orange_theme.png)

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/dark_theme.png)

However, you can set your own colors and sizes as well:

```dart
ProgressBar(
  progress: progress,
  buffered: buffered,
  total: total,
  progressBarColor: Colors.red,
  baseBarColor: Colors.white.withOpacity(0.24),
  bufferedBarColor: Colors.white.withOpacity(0.24),
  thumbColor: Colors.white,
  barHeight: 3.0,
  thumbRadius: 5.0,
  onSeek: (duration) {
    _player.seek(duration);
  },
);
```

Which would look like this (if the app has a dark theme):

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/custom_theme.png)

You can also set the location of the time labels:

```dart
ProgressBar(
  ...
  timeLabelLocation: TimeLabelLocation.sides,
);
```

![](https://github.com/suragch/audio_video_progress_bar/blob/master/supplemental/side_labels.png)

## Notes

If your interested in how this widget was made, check out the article [Creating a Flutter widget from scratch](https://suragch.medium.com/creating-a-flutter-widget-from-scratch-a9c01c47c630)

If you find any bugs, feel free to open an issue.