# Native OpenCV Plugin

The Native OpenCV plugin provides a bridge between Flutter and native code (C++) to leverage OpenCV functionalities for eye detection.

# native_opencv

Flutter plugin for OpenCV.

## Setup

1. Download OpenCV Android SDK 4.12.0+ from https://opencv.org/releases/
2. Extract it and set the environment variable:

```bash
   export OPENCV_ANDROID="$HOME/path/to/OpenCV-android-sdk"
```

3. Add to your `~/.bash_profile` or `~/.zshrc`

### Installation

1. Add the following dependency to your `pubspec.yaml` file:

   if on pub.dev

   ```yaml
   dependencies:
     native_opencv: ^1.0.0
   ```

   if plugin downloaded in same directory as Project Folder

   ```yaml
   dependencies:
     native_opencv:
       path: ../native_opencv
   ```

2. Go to (your_project)'s main.dart and run flutter pub get, this will create a Podfile.

3. Edit (your_project)/ios/Podfile and add platform :ios, '11.0' to the first line, it is already there just uncomment it and change the ios version

4. Go to (your_project)/ios and run pod install

5. Open in xcode (your_project)/ios/Runner.xcworkspace

6. Edit Runner/Info.plist and add key Privacy - Camera Usage Description with some description

7. Add the correct c++ files to your iOS app.
   Right-click on Runner group and choose Add files to Runner...
   Add the file native_opencv/ios/Classes/native_opencv.cpp
   Add all the files under native_opencv/ios/Classes/EyeTracker

8. Run the project

### Implementation

1. In your project, initialize the eye detection module with the Haar cascade XML file. This should be done before performing any eye detection.

   ```dart
   final NativeOpenCV nativeOpencv = NativeOpenCV();
   await NativeOpenCV.initDetector();
   ```

2. Perform eye detection on an image. Pass the image data as a Uint8List along with the image dimensions and the desired parameters for eye detection.

   ```dart
   final Uint8List image = ...; // Load your image data here
   final int width = ...; // Width of the image
   final int height = ...; // Height of the image
   final int channels = ...; // Number of color channels in the image
   final double scaleFactor = ...; // Scale factor for eye detection (OpenCV Documentation "detectMultiScale")
   final int minNeighbors = ...; // Minimum number of neighbors for eye detection (OpenCV Documentation "detectMultiScale")

   final List<Detection> detections = await nativeOpencv.detectEyes(
       image, width, height, channels, scaleFactor, minNeighbors);
   ```

3. The detectEyes method returns a list of Detection objects, where each object represents the detected eyes' coordinates. You can access the coordinates using the x, y, width, and height properties of the Detection class.

4. Remember to release the resources when you're done with the eye detection module.
   ```dart
   nativeOpencv.dispose();
   ```
