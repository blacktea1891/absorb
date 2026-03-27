#!/bin/bash
flutter build appbundle --release --flavor playstore --dart-define=PLAYSTORE_BUILD=true "$@" && explorer "build\\app\\outputs\\bundle\\playstoreRelease"
