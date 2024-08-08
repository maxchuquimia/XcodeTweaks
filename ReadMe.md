<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/XcodeTweaks/Assets.xcassets/AppIcon.appiconset/icon256.png" width="128" />

# XcodeTweaks

A macOS app that makes Xcode instantly build again when Xcode says “Build again to continue” - and other similar fixes that we shouldn't have to care about.

<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot1.png" />

## Features

XcodeTweaks aims to perform automatic resolutions as per [this resolution reckoner](https://gist.github.com/maxchuquimia/05a230a6c14a2564cb195af05f6cc1fe). So far it can handle the following:

| When XcodeTweaks detects the error... | Xcode Tweaks will instantly... |
| --- | --- |
| Build again to continue | Build, Test or Launch your project again |
| contains multiple references with the same GUID | Resolve Package Versions, then Build, Test or Launch your project again |
| received multiple target ended messages for target ID | Clean, then Build, Test or Launch your project again |
| targetID 423 not found in activeTargets | Clean, then Build, Test or Launch your project again |
| CodeSign failed with a nonzero exit code | Clean, then Build, Test or Launch your project again |

<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot2.png" height="400" />

## Installation

This uses AppleScript to run commands in Xcode and therefore requires Accessibility and Automation permissions. XcodeTweaks is not sandboxed.

<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot3.png" height="250"/> <img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/screenshot4.png" height="250"/>

It would be safest for you to inspect the source and build it yourself, however if you are feeling trusting today you can get a notarized version from [the releases page](https://github.com/maxchuquimia/XcodeTweaks/releases) 🎉

If you are building yourself, note that you'll need to set _Signing & Capabilities > Team_ to your own so that accessibility settings are retained between launches. 

## Motivation

<img src="https://raw.githubusercontent.com/maxchuquimia/XcodeTweaks/master/Marketing/motivation.png" />

All the errors above are not related to our code and are easy to solve - but we still need to go to the build log and remember what steps to take for each one.

Also, Xcode 15.3 started appending some errors with "Build again to continue". Read more about how this project was started [here](https://itnext.io/make-xcode-instantly-build-again-when-it-says-build-again-to-continue-part-1-38300674395e).
