## [0.10.0] - November 14, 2021

- @addie9000: fix thumb position when total changed (#27)
- @giga10: Drop 0 padding on time labels less than 10 minutes (#24, #25)
- Update demo app so that buttons don't overflow
- Updated documentation to clarify how you can getting the thumb duration while the user is in the process of seeking.

## [0.9.0] - August 12, 2021

- Added `barCapShape` to select `BarCapShape.round` or `BarCapShape.square` for the ends. (#20)
- Added `thumbCanPaintOutsideBar` to control whether the thumb paints before the start or after then end of the bar. (#21)
- Fixed sizing bug when bar height is greater that thumb diameter.
- Fixed dragging and thumb painting misalignment bug.
- Fixed jittery bar that readjusts for changing label widths when labels on sides.

## [0.8.0] - August 11, 2021

- Added `onDragStart`, `onDragUpdate`, and `onDragEnd` callback parameters so that developers can add a label and/or video preview above the thumb. The first two provide `ThumbDragDetails` data to the callback.
- `ThumbDragDetails` includes the thumb position duration as a `timeStamp` as well as the global and local positions for the drag event.

## [0.7.0] - August 2, 2021

- Reverted back to centering the thumb at the ends because otherwise it wouldn't move for the first and last few seconds. (#15)
- The thumb radius is not included in the widget width calculations when the labels are above or below. That means it will get drawn outside of the widget dimentions (which was already true for the glow radius). Users can wrap the widget with Padding if more padding is needed on the ends.

## [0.6.2] - July 30, 2021

- Initialize the thumb position based on progress and total time. This allows compatibily with the `Visibility` even when not maintaining state. (#12)

## [0.6.1] - July 23, 2021

- Added `timeLabelPadding` parameter for putting some extra space between the time labels and progress bar.
- Fixed a couple bugs with thumb position
- Added thumb radius and label padding controls to the sample project

## [0.6.0] - July 20, 2021

- Made the thumb and rounded bar caps stay within bar bounds so that padding is maintained from side text (#13)
- This change could possibly affect some user's layout so even though it isn't a breaking change programmatically, still bumping up a version so version upgrades won't be automatic.

## [0.5.0] - July 5, 2021

- Added `TimeLabelLocation.above` (@Groseuros)
- Center the progress bar vertically when bar hight is less than text height for `TimeLabelLocation.sides`
- Added `flutter_lints` linting

## [0.4.0] - May 1, 2021

- Added `timeLabelType` as a `TimeLabelType` enum with values of `totalTime` and `remainingTime`, which shows the time left as a negative number. (@tomassasovsky)
- Used a rounded stroke cap for the bars.

## [0.3.2] - April 26, 2021

- Fixed bug with failure to update label color on theme change.

## [0.3.1] - April 12, 2021

- Added `thumbGlowColor` (@hacker1024)
- Added `thumbGlowRadius` (@hacker1024)
- Added `timeLabelTextStyle` (@hacker1024)

## [0.3.0] - March 7, 2021

- Null safety release version
- Added `computeDryLayout`

## [0.2.0-nullsafety.0] - January 21, 2021

- Updated to null safety

## [0.1.0] - December 30, 2020

- Initial release
- Progress bar supports user time seeking
- Shows current time and total time
- Bar paints current progress and buffered progress
- This widget has a repaint boundary so it doesn't cause parent tree to repaint.
