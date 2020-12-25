import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum TimeLabelLocation {
  below,
  sides,
  none,
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key key,
    @required this.progress,
    @required this.total,
    this.buffered,
    this.onSeek,
    this.barHeight = 5.0,
    this.baseBarColor,
    this.progressBarColor,
    this.bufferedBarColor,
    this.thumbRadius = 10.0,
    this.thumbColor,
    this.timeLabelLocation,
    this.timeLabelStyle,
  }) : super(key: key);

  final Duration progress;
  final Duration total;
  final Duration buffered;
  final ValueChanged<Duration> onSeek;
  final Color baseBarColor;
  final Color progressBarColor;
  final Color bufferedBarColor;
  final double barHeight;
  final double thumbRadius;
  final Color thumbColor;
  final TimeLabelLocation timeLabelLocation;
  final TextStyle timeLabelStyle;

  @override
  Widget build(BuildContext context) {
    if (timeLabelLocation == TimeLabelLocation.none) {
      return _timeLabelNone(context);
    }
    final progressTime = _getTimeString(progress);
    final totalTime = _getTimeString(total);

    if (timeLabelLocation == TimeLabelLocation.sides) {
      return _timeLabelOnSides(context, progressTime, totalTime);
    }

    return _timeLabelBelow(context, progressTime, totalTime);
  }

  Widget _timeLabelNone(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: thumbRadius),
        Expanded(child: _basicProgressBar(context)),
        SizedBox(width: thumbRadius),
      ],
    );
  }

  Widget _timeLabelBelow(BuildContext context, String progressTime, String totalTime) {
    
    return Row(
      children: [
        SizedBox(width: thumbRadius),
        Expanded(
          child: Column(
            children: [
              _basicProgressBar(context),
              Row(
                children: [
                  Text(progressTime, style: timeLabelStyle),
                  Spacer(),
                  Text(totalTime, style: timeLabelStyle),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: thumbRadius),
      ],
    );
  }

  Widget _timeLabelOnSides(BuildContext context, String progressTime, String totalTime) {
    final progressTime = _getTimeString(progress);
    final totalTime = _getTimeString(total);
    return Row(
      children: [
        Text(progressTime, style: timeLabelStyle),
        SizedBox(width: thumbRadius + 5),
        Expanded(child: _basicProgressBar(context)),
        SizedBox(width: thumbRadius + 5),
        Text(totalTime, style: timeLabelStyle),
      ],
    );
  }

  BasicProgressBar _basicProgressBar(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return BasicProgressBar(
      progress: progress,
      total: total,
      buffered: buffered ?? Duration.zero,
      onSeek: onSeek,
      barHeight: barHeight,
      baseBarColor: baseBarColor ?? primaryColor.withOpacity(0.24),
      progressBarColor: progressBarColor ?? primaryColor,
      bufferedBarColor: bufferedBarColor ?? primaryColor.withOpacity(0.24),
      thumbRadius: thumbRadius,
      thumbColor: thumbColor ?? primaryColor,
    );
  }

  String _getTimeString(Duration time) {
    final minutes = time.inMinutes
        .remainder(Duration.minutesPerHour)
        .toString()
        .padLeft(2, '0');
    final seconds = time.inSeconds
        .remainder(Duration.secondsPerMinute)
        .toString()
        .padLeft(2, '0');
    final hours = total.inHours > 0 ? '${time.inHours}:' : '';
    return "$hours$minutes:$seconds";
  }
}

class BasicProgressBar extends LeafRenderObjectWidget {
  const BasicProgressBar({
    Key key,
    @required this.progress,
    @required this.total,
    @required this.buffered,
    this.onSeek,
    this.barHeight = 5.0,
    @required this.baseBarColor,
    @required this.progressBarColor,
    @required this.bufferedBarColor,
    this.thumbRadius = 10.0,
    @required this.thumbColor,
  }) : super(key: key);

  final Duration progress;
  final Duration total;
  final Duration buffered;
  final ValueChanged<Duration> onSeek;
  final Color baseBarColor;
  final Color progressBarColor;
  final Color bufferedBarColor;
  final double barHeight;
  final double thumbRadius;
  final Color thumbColor;

  @override
  _RenderProgressBar createRenderObject(BuildContext context) {
    return _RenderProgressBar(
      progress: progress,
      total: total,
      buffered: buffered,
      onSeek: onSeek,
      barHeight: barHeight,
      baseBarColor: baseBarColor,
      progressBarColor: progressBarColor,
      bufferedBarColor: bufferedBarColor,
      thumbRadius: thumbRadius,
      thumbColor: thumbColor,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderProgressBar renderObject) {
    renderObject
      ..progress = progress
      ..total = total
      ..buffered = buffered
      ..onSeek = onSeek
      ..barHeight = barHeight
      ..baseBarColor = baseBarColor
      ..progressBarColor = progressBarColor
      ..bufferedBarColor = bufferedBarColor
      ..thumbRadius = thumbRadius
      ..thumbColor = thumbColor;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('progress', progress.toString()));
    properties.add(StringProperty('total', total.toString()));
    properties.add(StringProperty('buffered', buffered.toString()));
    properties
        .add(ObjectFlagProperty<ValueChanged<Duration>>('onSeek', onSeek));
    properties.add(DoubleProperty('barHeight', barHeight));
    properties.add(ColorProperty('baseBarColor', baseBarColor));
    properties.add(ColorProperty('progressBarColor', progressBarColor));
    properties.add(ColorProperty('bufferedBarColor', bufferedBarColor));
    properties.add(DoubleProperty('thumbRadius', thumbRadius));
    properties.add(ColorProperty('thumbColor', thumbColor));
  }
}

class _RenderProgressBar extends RenderBox {
  _RenderProgressBar({
    Duration progress,
    Duration total,
    Duration buffered,
    ValueChanged<Duration> onSeek,
    double barHeight,
    Color baseBarColor,
    Color progressBarColor,
    Color bufferedBarColor,
    double thumbRadius = 20.0,
    Color thumbColor,
  })  : _progress = progress,
        _total = total,
        _buffered = buffered,
        _onSeek = onSeek,
        _barHeight = barHeight,
        _baseBarColor = baseBarColor,
        _progressBarColor = progressBarColor,
        _bufferedBarColor = bufferedBarColor,
        _thumbRadius = thumbRadius,
        _thumbColor = thumbColor {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _onDragStart
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd
      ..onCancel = _finishDrag;
  }

  HorizontalDragGestureRecognizer _drag;
  double _thumbValue = 0.0;
  bool _userIsDraggingThumb = false;

  void _onDragStart(DragStartDetails details) {
    _userIsDraggingThumb = true;
    _updateThumbPosition(details.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _updateThumbPosition(details.localPosition);
  }

  void _onDragEnd(DragEndDetails details) {
    final thumbMiliseconds = _thumbValue * total.inMilliseconds;
    onSeek(Duration(milliseconds: thumbMiliseconds.round()));
    _finishDrag();
  }

  void _finishDrag() {
    _userIsDraggingThumb = false;
    markNeedsPaint();
  }

  void _updateThumbPosition(Offset localPosition) {
    var dx = localPosition.dx.clamp(0, size.width);
    _thumbValue = dx / size.width;
    markNeedsPaint();
  }

  Duration get progress => _progress;
  Duration _progress;
  set progress(Duration value) {
    if (_progress == value) {
      return;
    }
    _progress = value;
    if (!_userIsDraggingThumb) {
      _thumbValue = _proportionOfTotal(value);
    }
    markNeedsPaint();
  }

  Duration get total => _total;
  Duration _total;
  set total(Duration value) {
    if (_total == value) {
      return;
    }
    _total = value;
    markNeedsPaint();
  }

  Duration get buffered => _buffered;
  Duration _buffered;
  set buffered(Duration value) {
    if (_buffered == value) {
      return;
    }
    _buffered = value;
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

  Color get progressBarColor => _progressBarColor;
  Color _progressBarColor;
  set progressBarColor(Color value) {
    if (_progressBarColor == value) return;
    _progressBarColor = value;
    markNeedsPaint();
  }

  Color get bufferedBarColor => _bufferedBarColor;
  Color _bufferedBarColor;
  set bufferedBarColor(Color value) {
    if (_bufferedBarColor == value) return;
    _bufferedBarColor = value;
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
  double get _desiredHeight => 2 * thumbRadius;

  @override
  double computeMinIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMinIntrinsicHeight(double width) => _desiredHeight;

  @override
  double computeMaxIntrinsicHeight(double width) => _desiredHeight;

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

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _drawBaseBar(canvas);
    _drawBufferedBar(canvas);
    _drawProgressBar(canvas);
    _drawThumb(canvas);
    canvas.restore();
  }

  void _drawBaseBar(Canvas canvas) {
    final baseBarPaint = Paint()
      ..color = baseBarColor
      ..strokeWidth = barHeight;
    final startPoint = Offset(0, size.height / 2);
    var endPoint = Offset(size.width, size.height / 2);
    canvas.drawLine(startPoint, endPoint, baseBarPaint);
  }

  void _drawBufferedBar(Canvas canvas) {
    final bufferedBarPaint = Paint()
      ..color = bufferedBarColor
      ..strokeWidth = barHeight;
    final bufferedWidth = _proportionOfTotal(_buffered) * size.width;
    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(bufferedWidth, size.height / 2);
    canvas.drawLine(startPoint, endPoint, bufferedBarPaint);
  }

  void _drawProgressBar(Canvas canvas) {
    final progressBarPaint = Paint()
      ..color = progressBarColor
      ..strokeWidth = barHeight;
    final progressWidth = _proportionOfTotal(_progress) * size.width;
    final startPoint = Offset(0, size.height / 2);
    final endPoint = Offset(progressWidth, size.height / 2);
    canvas.drawLine(startPoint, endPoint, progressBarPaint);
  }

  void _drawThumb(Canvas canvas) {
    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _thumbValue * size.width;
    final center = Offset(thumbDx, size.height / 2);
    if (_userIsDraggingThumb) {
      final thumbGlowPaint = Paint()..color = thumbColor.withAlpha(80);
      canvas.drawCircle(center, 30, thumbGlowPaint);
    }
    canvas.drawCircle(center, thumbRadius, thumbPaint);
  }

  double _proportionOfTotal(Duration duration) {
    if (total.inMilliseconds == 0) {
      return 0.0;
    }
    final proportion = duration.inMilliseconds / total.inMilliseconds;
    return proportion;
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    // TODO: implement describeSemanticsConfiguration
    super.describeSemanticsConfiguration(config);
  }
}
