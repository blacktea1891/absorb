#!/bin/bash
flutter build apk --release --flavor github --dart-define=GITHUB_BUILD=true "$@" && explorer "build\\app\\outputs\\apk\\github\\release"
