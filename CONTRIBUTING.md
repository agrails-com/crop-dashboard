# Contributing

This started as a portfolio/demo project rather than a maintained product, so please set expectations accordingly — there's no test suite yet and no guaranteed response time on issues or PRs.

## Before opening a PR

- Confirm `xcodebuild -project CropDashboard.xcodeproj -scheme CropDashboard -sdk iphonesimulator build` succeeds.
- The AR tab (`ARFarmView`) can't be exercised in the Simulator — if your change touches `Views/AR/`, test it on a real device with a printed copy of the `FarmMap` reference image.
- Run `xcrun swift-format format -i -r Models Services ViewModels Views CropDashboard` before committing to keep formatting consistent.

## Reporting issues

Open a GitHub issue with repro steps. For AR-specific bugs, include the device model and iOS version — ARKit behavior varies noticeably across hardware.
