#!/bin/bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
echo "JAVA_HOME is set to: $JAVA_HOME"
java -version
flutter clean
flutter pub get
flutter build apk --debug
