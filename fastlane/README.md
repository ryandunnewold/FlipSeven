fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Capture App Store screenshots

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build and upload to TestFlight

### ios upload_screenshots

```sh
[bundle exec] fastlane ios upload_screenshots
```

Upload screenshots to App Store Connect

### ios release

```sh
[bundle exec] fastlane ios release
```

Full App Store release: screenshots, build, and upload

### ios setup_metadata

```sh
[bundle exec] fastlane ios setup_metadata
```

Set up App Store version metadata via API

### ios submit

```sh
[bundle exec] fastlane ios submit
```

Submit the latest build for App Store review

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
