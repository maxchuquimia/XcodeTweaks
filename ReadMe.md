<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/XcodeTweaks/Assets.xcassets/AppIcon.appiconset/icon256.png" width="128" />

# XcodeTweaks

A macOS app to make Xcode instantly build again when Xcode fails with an error that includes “Build again to continue” - and other similar fixes that we shouldn't have to care about.

<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot1.png" />

## Features

| When XcodeTweaks detects the error... | Xcode Tweaks will instantly... |
| --- | --- |
| Build again to continue | Build, Test or Launch your project again |
| contains multiple references with the same GUID | Resolve Package Versions, then Build, Test or Launch your project again |
| received multiple target ended messages for target ID | Clean, then Build, Test or Launch your project again |
| targetID 423 not found in activeTargets | Clean, then Build, Test or Launch your project again |
| CodeSign failed with a nonzero exit code | Clean, then Build, Test or Launch your project again |

## Installation

This uses AppleScript to run commands in Xcode and therefore requires Accessibility and Automation permissions. XcodeTweaks is not sandboxed.
It would be better for you to inspect the source and build it yourself for safety, however if you are feeling trusting today you can get a notarized version from [the releases page](https://github.com/maxchuquimia/XcodeTweaks/releases)
<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot2.png" height="300"/> <img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot3.png" height="300"/>

