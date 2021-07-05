## [0.5.0] - July 5, 2021

* Added `TimeLabelLocation.above` (@Groseuros)
* Center the progress bar vertically when bar hight is less than text height for `TimeLabelLocation.sides`
* Added `flutter_lints` linting

## [0.4.0] - May 1, 2021

* Added `timeLabelType` as a `TimeLabelType` enum with values of `totalTime` and `remainingTime`, which shows the time left as a negative number. (@tomassasovsky)
* Used a rounded stroke cap for the bars.

## [0.3.2] - April 26, 2021

* Fixed bug with failure to update label color on theme change.

## [0.3.1] - April 12, 2021

* Added `thumbGlowColor` (@hacker1024)
* Added `thumbGlowRadius` (@hacker1024)
* Added `timeLabelTextStyle` (@hacker1024)

## [0.3.0] - March 7, 2021

* Null safety release version
* Added `computeDryLayout`

## [0.2.0-nullsafety.0] - January 21, 2021

* Updated to null safety

## [0.1.0] - December 30, 2020

* Initial release
* Progress bar supports user time seeking
* Shows current time and total time
* Bar paints current progress and buffered progress
* This widget has a repaint boundary so it doesn't cause parent tree to repaint.
