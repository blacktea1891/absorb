#!/bin/bash
flutter build appbundle --release "$@" && explorer "build\\app\\outputs\\bundle\\release"
