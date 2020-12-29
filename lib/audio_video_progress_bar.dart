import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum TimeLabelLocation {
  below,
  sides,
  none,
}

class ProgressBar extends LeafRenderObjectWidget {
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

  @override
  _RenderProgressBar createRenderObject(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textStyle = theme.textTheme.bodyText1;
    return _RenderProgressBar(
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
      timeLabelLocation: timeLabelLocation ?? TimeLabelLocation.below,
      timeLabelTextStyle: textStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderProgressBar renderObject) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textStyle = theme.textTheme.bodyText1;
    renderObject
      ..progress = progress
      ..total = total
      ..buffered = buffered ?? Duration.zero
      ..onSeek = onSeek
      ..barHeight = barHeight
      ..baseBarColor = baseBarColor ?? primaryColor.withOpacity(0.24)
      ..progressBarColor = progressBarColor ?? primaryColor
      ..bufferedBarColor = bufferedBarColor ?? primaryColor.withOpacity(0.24)
      ..thumbRadius = thumbRadius
      ..thumbColor = thumbColor ?? primaryColor
      ..timeLabelLocation = timeLabelLocation ?? TimeLabelLocation.below
      ..timeLabelTextStyle = textStyle;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('progress', progress.toString()));
    properties.add(StringProperty('total', total.toString()));
    properties.add(StringProperty('buffered', buffered.toString()));
    properties.add(ObjectFlagProperty<ValueChanged<Duration>>('onSeek', onSeek,
        ifNull: 'unimplemented'));
    properties.add(DoubleProperty('barHeight', barHeight));
    properties.add(ColorProperty('baseBarColor', baseBarColor));
    properties.add(ColorProperty('progressBarColor', progressBarColor));
    properties.add(ColorProperty('bufferedBarColor', bufferedBarColor));
    properties.add(DoubleProperty('thumbRadius', thumbRadius));
    properties.add(ColorProperty('thumbColor', thumbColor));
    properties
        .add(StringProperty('timeLabelLocation', timeLabelLocation.toString()));
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
    TimeLabelLocation timeLabelLocation,
    TextStyle timeLabelTextStyle,
  })  : _progress = progress,
        _total = total,
        _buffered = buffered,
        _onSeek = onSeek,
        _barHeight = barHeight,
        _baseBarColor = baseBarColor,
        _progressBarColor = progressBarColor,
        _bufferedBarColor = bufferedBarColor,
        _thumbRadius = thumbRadius,
        _thumbColor = thumbColor,
        _timeLabelLocation = timeLabelLocation,
        _timeLabelTextStyle = timeLabelTextStyle {
    _drag = HorizontalDragGestureRecognizer()
      ..onStart = _onDragStart
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd
      ..onCancel = _finishDrag;
    _leftTimeLabel = _setTimeLabel(progress);
    _rightTimeLabel = _setTimeLabel(progress);
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
    final dx = localPosition.dx;
    double barStart;
    double barEnd;
    if (_timeLabelLocation == TimeLabelLocation.sides) {
      barStart = _leftTimeLabel.width + _thumbRadius;
      barEnd = size.width - _rightTimeLabel.width - _thumbRadius;
    } else {
      barStart = _thumbRadius;
      barEnd = size.width - _thumbRadius;
    }
    final barWidth = barEnd - barStart;
    final position = (dx - barStart).clamp(0.0, barWidth);
    _thumbValue = (position / barWidth);
    markNeedsPaint();
  }

  Duration get progress => _progress;
  Duration _progress;
  TextPainter _leftTimeLabel;
  set progress(Duration value) {
    if (_progress == value) {
      return;
    }
    _progress = value;
    if (!_userIsDraggingThumb) {
      _thumbValue = _proportionOfTotal(value);
      _leftTimeLabel = _setTimeLabel(value);
    }
    markNeedsPaint();
  }

  TextPainter _setTimeLabel(Duration duration) {
    final text = _getTimeString(duration);
    return _layoutText(text);
  }

  TextPainter _layoutText(String text) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: _timeLabelTextStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter;
  }

  Duration get total => _total;
  Duration _total;
  TextPainter _rightTimeLabel;
  set total(Duration value) {
    if (_total == value) {
      return;
    }
    _total = value;
    _rightTimeLabel = _setTimeLabel(value);
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

  TimeLabelLocation get timeLabelLocation => _timeLabelLocation;
  TimeLabelLocation _timeLabelLocation;
  set timeLabelLocation(TimeLabelLocation value) {
    if (_timeLabelLocation == value) return;
    _timeLabelLocation = value;
    markNeedsLayout();
  }

  TextStyle get timeLabelTextStyle => _timeLabelTextStyle;
  TextStyle _timeLabelTextStyle;
  set timeLabelTextStyle(TextStyle value) {
    if (_timeLabelTextStyle == value) return;
    _timeLabelTextStyle = value;
    markNeedsLayout();
  }

  static const _minDesiredWidth = 100.0;

  @override
  double computeMinIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMaxIntrinsicWidth(double height) => _minDesiredWidth;

  @override
  double computeMinIntrinsicHeight(double width) => _calculateDesiredHeight();

  @override
  double computeMaxIntrinsicHeight(double width) => _calculateDesiredHeight();

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
    final desiredHeight = _calculateDesiredHeight();
    final desiredSize = Size(desiredWidth, desiredHeight);
    size = constraints.constrain(desiredSize);
  }

  double _calculateDesiredHeight() {
    switch (_timeLabelLocation) {
      case TimeLabelLocation.below:
        return _heightWhenLabelsBelow();
      case TimeLabelLocation.sides:
        return _heightWhenLabelsOnSides();
      default:
        return _heightWhenNoLabels();
    }
  }

  double _heightWhenLabelsBelow() {
    return _heightWhenNoLabels() + _textHeight();
  }

  double _heightWhenLabelsOnSides() {
    return max(_heightWhenNoLabels(), _textHeight());
  }

  double _heightWhenNoLabels() {
    return 2 * thumbRadius;
  }

  double _textHeight() {
    return _leftTimeLabel.height;
  }

  // @override
  // bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    switch (_timeLabelLocation) {
      case TimeLabelLocation.below:
        _drawProgressBarWithLabelsBelow(canvas);
        break;
      case TimeLabelLocation.sides:
        _drawProgressBarWithLabelsOnSides(canvas);
        break;
      default:
        _drawProgressBarWithoutLabels(canvas);
    }

    canvas.restore();
  }

  ///  Draw the progress bar and labels in the following locations:
  ///
  ///  | -------O---------------- |
  ///  | 01:23              05:00 |
  ///
  void _drawProgressBarWithLabelsBelow(Canvas canvas) {
    // calculate sizes
    final padding = _thumbRadius;
    final barWidth = size.width - 2 * padding;
    final barHeight = 2 * _thumbRadius;

    // current time label
    final labelOffset = Offset(padding, barHeight);
    _leftTimeLabel.paint(canvas, labelOffset);

    // total time label
    final rightLabelDx = size.width - padding - _rightTimeLabel.width;
    final rightLabelOffset = Offset(rightLabelDx, barHeight);
    _rightTimeLabel.paint(canvas, rightLabelOffset);

    // progress bar
    _drawProgressBar(canvas, Offset(padding, 0), Size(barWidth, barHeight));
  }

  ///  Draw the progress bar and labels in the following locations:
  ///
  ///  | 01:23 -------O---------------- 05:00 |
  ///
  void _drawProgressBarWithLabelsOnSides(Canvas canvas) {
    // if (_leftTimeLabel == null || _rightTimeLabel == null) {
    //   return;
    // }

    // calculate sizes
    final padding = _thumbRadius;
    final barHeight = 2 * _thumbRadius;

    // current time label
    // if (_leftTimeLabel == null) {
    //   _leftTimeLabel = _setLe
    // }
    final verticalOffset = size.height / 2 - _leftTimeLabel.height / 2;
    final currentLabelOffset = Offset(0, verticalOffset);
    _leftTimeLabel.paint(canvas, currentLabelOffset);

    // total time label
    final totalLabelDx = size.width - _rightTimeLabel.width;
    final totalLabelOffset = Offset(totalLabelDx, verticalOffset);
    _rightTimeLabel.paint(canvas, totalLabelOffset);

    // progress bar
    final leftLabelWidth = _leftTimeLabel.width;
    final barWidth =
        size.width - 2 * padding - leftLabelWidth - _rightTimeLabel.width;
    _drawProgressBar(
        canvas, Offset(padding + leftLabelWidth, 0), Size(barWidth, barHeight));
  }

  /// Draw the progress bar with padding
  ///
  /// | -------O---------------- |
  void _drawProgressBarWithoutLabels(Canvas canvas) {
    final padding = _thumbRadius;
    final barWidth = size.width - 2 * padding;
    final barHeight = 2 * _thumbRadius;
    _drawProgressBar(canvas, Offset(padding, 0), Size(barWidth, barHeight));
  }

  void _drawProgressBar(
    Canvas canvas,
    Offset offset,
    Size localSize,
  ) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    _drawBaseBar(canvas, localSize);
    _drawBufferedBar(canvas, localSize);
    _drawCurrentProgressBar(canvas, localSize);
    _drawThumb(canvas, localSize);
    canvas.restore();
  }

  void _drawBaseBar(Canvas canvas, Size localSize) {
    final baseBarPaint = Paint()
      ..color = baseBarColor
      ..strokeWidth = barHeight;
    final startPoint = Offset(0, localSize.height / 2);
    var endPoint = Offset(localSize.width, localSize.height / 2);
    canvas.drawLine(startPoint, endPoint, baseBarPaint);
  }

  void _drawBufferedBar(Canvas canvas, Size localSize) {
    final bufferedBarPaint = Paint()
      ..color = bufferedBarColor
      ..strokeWidth = barHeight;
    final bufferedWidth = _proportionOfTotal(_buffered) * localSize.width;
    final startPoint = Offset(0, localSize.height / 2);
    final endPoint = Offset(bufferedWidth, localSize.height / 2);
    canvas.drawLine(startPoint, endPoint, bufferedBarPaint);
  }

  void _drawCurrentProgressBar(Canvas canvas, Size localSize) {
    final progressBarPaint = Paint()
      ..color = progressBarColor
      ..strokeWidth = barHeight;
    final progressWidth = _proportionOfTotal(_progress) * localSize.width;
    final startPoint = Offset(0, localSize.height / 2);
    final endPoint = Offset(progressWidth, localSize.height / 2);
    canvas.drawLine(startPoint, endPoint, progressBarPaint);
  }

  void _drawThumb(Canvas canvas, Size localSize) {
    final thumbPaint = Paint()..color = thumbColor;
    final thumbDx = _thumbValue * localSize.width;
    final center = Offset(thumbDx, localSize.height / 2);
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

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);

    // description
    config.textDirection = TextDirection.ltr;
    config.label = 'Progress bar';
    config.value = '${(_thumbValue * 100).round()}%';

    // increase action
    config.onIncrease = increaseAction;
    final increased = _thumbValue + _semanticActionUnit;
    config.increasedValue = '${((increased).clamp(0.0, 1.0) * 100).round()}%';

    // descrease action
    config.onDecrease = decreaseAction;
    final decreased = _thumbValue - _semanticActionUnit;
    config.decreasedValue = '${((decreased).clamp(0.0, 1.0) * 100).round()}%';
  }

  static const double _semanticActionUnit = 0.05;

  void increaseAction() {
    final newValue = _thumbValue + _semanticActionUnit;
    _thumbValue = (newValue).clamp(0.0, 1.0);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  void decreaseAction() {
    final newValue = _thumbValue - _semanticActionUnit;
    _thumbValue = (newValue).clamp(0.0, 1.0);
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }
}
