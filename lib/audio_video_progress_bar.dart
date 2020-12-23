import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ProgressBar extends LeafRenderObjectWidget {
  const ProgressBar({
    Key key,
    @required this.playingProgress,
    @required this.totalDuration,
    this.bufferingProgress,
    this.onSeek,
    this.barHeight,
    this.baseBarColor,
    this.playingBarColor,
    this.bufferingBarColor,
    this.thumbRadius = 20.0,
    this.thumbColor,
  }) : super(key: key);

  final Duration playingProgress;
  final Duration totalDuration;
  final Duration bufferingProgress;
  final ValueChanged<Duration> onSeek;
  final Color baseBarColor;
  final Color playingBarColor;
  final Color bufferingBarColor;
  final double barHeight;
  final double thumbRadius;
  final Color thumbColor;

  @override
  RenderProgressBar createRenderObject(BuildContext context) {
    return RenderProgressBar(
      playingProgress: playingProgress,
      totalDuration: totalDuration,
      bufferingProgress: bufferingProgress,
      onSeek: onSeek,
      barHeight: barHeight,
      baseBarColor: baseBarColor,
      playingBarColor: playingBarColor,
      bufferingBarColor: bufferingBarColor,
      thumbRadius: thumbRadius,
      thumbColor: thumbColor,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderProgressBar renderObject) {
    renderObject
      ..playingProgress = playingProgress
      ..totalDuration = totalDuration
      ..bufferingProgress = bufferingProgress
      ..onSeek = onSeek
      ..barHeight = barHeight
      ..baseBarColor = baseBarColor
      ..playingBarColor = playingBarColor
      ..bufferingBarColor = bufferingBarColor
      ..thumbRadius = thumbRadius
      ..thumbColor = thumbColor;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(StringProperty('playingProgress', playingProgress.toString()));
    properties.add(StringProperty('totalDuration', totalDuration.toString()));
    properties
        .add(StringProperty('bufferingProgress', bufferingProgress.toString()));
    properties
        .add(ObjectFlagProperty<ValueChanged<Duration>>('onSeek', onSeek));
    properties.add(DoubleProperty('barHeight', barHeight));
    properties.add(ColorProperty('baseBarColor', baseBarColor));
    properties.add(ColorProperty('playingBarColor', playingBarColor));
    properties.add(ColorProperty('bufferingBarColor', bufferingBarColor));
    properties.add(DoubleProperty('thumbRadius', thumbRadius));
    properties.add(ColorProperty('thumbColor', thumbColor));
  }
}

class RenderProgressBar extends RenderBox {
  RenderProgressBar({
    Duration playingProgress,
    Duration totalDuration,
    Duration bufferingProgress,
    ValueChanged<Duration> onSeek,
    double barHeight,
    Color baseBarColor,
    Color playingBarColor,
    Color bufferingBarColor,
    double thumbRadius = 20.0,
    Color thumbColor,
  })  : _playingProgress = playingProgress,
        _totalDuration = totalDuration,
        _bufferingProgress = bufferingProgress,
        _onSeek = onSeek,
        _barHeight = barHeight,
        _baseBarColor = baseBarColor,
        _playingBarColor = playingBarColor,
        _bufferingBarColor = bufferingBarColor,
        _thumbRadius = thumbRadius,
        _thumbColor = thumbColor {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = (DragStartDetails details) {
        _userIsDraggingThumb = true;
        _updateThumbPosition(details.localPosition);
      }
      ..onUpdate = (DragUpdateDetails details) {
        _updateThumbPosition(details.localPosition);
      }
      ..onEnd = (DragEndDetails details) {
        final thumbMiliseconds = _thumbValue * totalDuration.inMilliseconds;
        onSeek(Duration(milliseconds: thumbMiliseconds.round()));
        _userIsDraggingThumb = false;
        markNeedsPaint();
      }..onCancel = () {
        _userIsDraggingThumb = false;
        markNeedsPaint();
      };
  }

  bool _userIsDraggingThumb = false;

  void _updateThumbPosition(Offset localPosition) {
    var dx = localPosition.dx.clamp(0, size.width);
    _thumbValue = dx / size.width;
    markNeedsPaint();
  }

  Duration get playingProgress => _playingProgress;
  Duration _playingProgress;
  set playingProgress(Duration value) {
    if (_playingProgress == value) {
      return;
    }
    _playingProgress = value;
    markNeedsPaint();
  }

  Duration get totalDuration => _totalDuration;
  Duration _totalDuration;
  set totalDuration(Duration value) {
    if (_totalDuration == value) {
      return;
    }
    _totalDuration = value;
    markNeedsPaint();
  }

  Duration get bufferingProgress => _bufferingProgress;
  Duration _bufferingProgress;
  set bufferingProgress(Duration value) {
    if (_bufferingProgress == value) {
      return;
    }
    _bufferingProgress = value;
    markNeedsPaint();
  }

  ValueChanged<Duration> get onSeek => _onSeek;
  ValueChanged<Duration> _onSeek;
  set onSeek(ValueChanged<Duration> value) {
    if (value == _onSeek) {
      return;
    }
    _onSeek = value;
  }

  double get barHeight => _barHeight;
  double _barHeight;
  set barHeight(double value) {
    if (_barHeight == value) return;
    _barHeight = value;
    markNeedsPaint();
  }

  Color get baseBarColor => _baseBarColor;
  Color _baseBarColor;
  set baseBarColor(Color value) {
    if (_baseBarColor == value) return;
    _baseBarColor = value;
    markNeedsPaint();
  }

  Color get playingBarColor => _playingBarColor;
  Color _playingBarColor;
  set playingBarColor(Color value) {
    if (_playingBarColor == value) return;
    _playingBarColor = value;
    markNeedsPaint();
  }

  Color get bufferingBarColor => _bufferingBarColor;
  Color _bufferingBarColor;
  set bufferingBarColor(Color value) {
    if (_bufferingBarColor == value) return;
    _bufferingBarColor = value;
    markNeedsPaint();
  }

  Color get thumbColor => _thumbColor;
  Color _thumbColor;
  set thumbColor(Color value) {
    if (_thumbColor == value) return;
    _thumbColor = value;
    markNeedsPaint();
  }

  double get thumbRadius => _thumbRadius;
  double _thumbRadius;
  set thumbRadius(double value) {
    if (_thumbRadius == value) return;
    _thumbRadius = value;
    markNeedsLayout();
  }

  static const _minDesiredWidth = 100.0;

  @override
  double computeMinIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMinIntrinsicHeight(double width) => _desiredHeight;

  @override
  double computeMaxIntrinsicHeight(double width) => _desiredHeight;

  double get _desiredHeight => 2 * thumbRadius;

  HorizontalDragGestureRecognizer _drag;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  @override
  void performLayout() {
    final desiredWidth = constraints.maxWidth;
    final desiredHeight = _desiredHeight;
    final desiredSize = Size(desiredWidth, desiredHeight);
    size = constraints.constrain(desiredSize);
  }

  double _thumbValue = 0.5;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // base bar
    final baseBarPaint = Paint()
      ..color = baseBarColor
      ..strokeWidth = barHeight;
    final startPoint = Offset(0, size.height / 2);
    var endPoint = Offset(size.width, size.height / 2);
    canvas.drawLine(startPoint, endPoint, baseBarPaint);

    // playing progress bar
    final bufferingBarPaint = Paint()
      ..color = bufferingBarColor
      ..strokeWidth = barHeight;
    final bufferingWidth = _widthComplete(bufferingProgress);
    endPoint = Offset(bufferingWidth, size.height / 2);
    canvas.drawLine(startPoint, endPoint, bufferingBarPaint);

    // playing progress bar
    final playingBarPaint = Paint()
      ..color = playingBarColor
      ..strokeWidth = barHeight;
    final playingWidth = _widthComplete(playingProgress);
    endPoint = Offset(playingWidth, size.height / 2);
    canvas.drawLine(startPoint, endPoint, playingBarPaint);

    // paint thumb
    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _thumbValue * size.width;
    final center = Offset(thumbDx, size.height / 2);
    if (_userIsDraggingThumb) {
      final thumbGlowPaint = Paint()..color = thumbColor.withAlpha(80);
      canvas.drawCircle(center, 30, thumbGlowPaint);
    }
    canvas.drawCircle(center, thumbRadius, thumbPaint);

    canvas.restore();
  }

  double _widthComplete(Duration duration) {
    final proportion = duration.inMilliseconds / totalDuration.inMilliseconds;
    return proportion * size.width;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    // TODO: implement describeSemanticsConfiguration
    super.describeSemanticsConfiguration(config);
  }
}
