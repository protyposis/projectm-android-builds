# projectM Android Publisher

A shim repository for building and publishing Android AAR packages of the [projectM visualizer library](https://github.com/projectM-visualizer/projectm) native components.

## Overview

This repository acts as a packaging/publishing wrapper that:
- Uses upstream build logic
- Packages the libraries and headers into Android AAR format (debug and release builds for multiple ABIs)
- Publishes versioned artifacts to a GitHub Pages Maven repository

## Usage

See [documentation](https://protyposis.github.io/projectm-android-builds/) for instructions on how to include the published AAR in your Android projects via Gradle/Maven.

## Versioning

This publisher tracks projectM releases and publishes daily snapshots. Version mapping:

**Stable Releases:**
- projectM tag `v4.1.0` → Maven version `4.1.0`
- projectM tag `v4.1.0-rc1` → Maven version `4.1.0-rc1`
- Releases are built once per day if a new release is detected

**Daily Snapshots:**
- `master` branch → `master-SNAPSHOT` (always the latest master build)
- `v4.1.x` branch → `4.1.x-SNAPSHOT` (always the latest 4.1.x build)
- Snapshots are built daily if the branch has new commits
- Snapshots overwrite previous versions (Maven SNAPSHOT behavior)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](.github/CONTRIBUTING.md) for guidelines.

## License

The projectM library is licensed under GNU LGPL v2.1. This publisher repository is provided as-is for packaging convenience.
