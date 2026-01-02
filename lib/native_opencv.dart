import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

// Dynamic library that contains the native C++ code
final DynamicLibrary nativeLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_opencv.so")
    : DynamicLibrary.process();

// Mappings between the C++ functions and their Dart counterparts.
typedef _c_version = Pointer<Utf8> Function();
typedef _dart_version = Pointer<Utf8> Function();

typedef _c_initDetector = Void Function(Pointer<Utf8> xmlFilePath);
typedef _dart_initDetector = void Function(Pointer<Utf8> xmlFilePath);

typedef _c_destroyDetector = Void Function();
typedef _dart_destroyDetector = void Function();

typedef _c_detect_eyes =
    Pointer<Utf8> Function(
      Pointer<Utf8> image,
      Int32 width,
      Int32 height,
      Int32 channels,
      Double scaleFactor,
      Int32 minNeighbors,
    );
typedef _dart_detect_eyes =
    Pointer<Utf8> Function(
      Pointer<Utf8> image,
      int width,
      int height,
      int channels,
      double scaleFactor,
      int minNeighbors,
    );

// Look up the corresponding C++ functions in the dynamic library. This allows Dart to call the native functions directly.
final _version = nativeLib.lookupFunction<_c_version, _dart_version>('version');
final _initDetector = nativeLib.lookupFunction<_c_initDetector, _dart_initDetector>('initDetector');
final _destroyDetector = nativeLib.lookupFunction<_c_destroyDetector, _dart_destroyDetector>(
  'destroyDetector',
);
final _detectEyes = nativeLib.lookupFunction<_c_detect_eyes, _dart_detect_eyes>('detectEyes');

// Class NativeOpencv has methods for initializing the OpenCV detector, detecting eyes, and cleaning up memory allocation.
class NativeOpenCV {
  static const MethodChannel _channel = MethodChannel('native_opencv');
  Pointer<Uint8>? _imageBuffer;

  Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // Sets Detector using Haar Cascade model
  Future init() async {
    const String xmlAssetPath = 'packages/native_opencv/assets/haarcascade_eye_tree_eyeglasses.xml';

    // Load XML file from assets
    final ByteData xmlAssetData = await rootBundle.load(xmlAssetPath);
    final String xmlContent = utf8.decode(xmlAssetData.buffer.asUint8List());

    // Get the application's root directory
    final Directory appDirectory = await getApplicationDocumentsDirectory();

    // Create the destination file path
    final String destFilePath = '${appDirectory.path}/haarcascade_eye_tree_eyeglasses.xml';

    // Write the XML content to the destination file
    final File destFile = File(destFilePath);
    await destFile.writeAsString(xmlContent);

    // Pass the destination file path to the C++ code
    final xmlFilePathPtr = destFilePath.toNativeUtf8();
    _initDetector(xmlFilePathPtr);
    calloc.free(xmlFilePathPtr);
  }

  Future<List<Rect>> detectEyes(
    Uint8List image,
    int width,
    int height,
    int channels,
    double scaleFactor,
    int minNeighbors,
  ) async {
    var totalSize = image.lengthInBytes;
    _imageBuffer ??= malloc.allocate<Uint8>(totalSize);
    Uint8List bytes = _imageBuffer!.asTypedList(totalSize);
    bytes.setAll(0, image);

    final String detections = _detectEyes(
      _imageBuffer!.cast<Utf8>(),
      width,
      height,
      channels,
      scaleFactor,
      minNeighbors,
    ).toDartString();

    final List<Rect> detectionList = [];
    if (detections != "null") {
      final jsonData = json.decode(detections);

      for (final eyeData in jsonData) {
        final int x = eyeData['x'];
        final int y = eyeData['y'];
        final int width = eyeData['width'];
        final int height = eyeData['height'];
        detectionList.add(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble()),
        );
      }
    }

    // Free the allocated memory
    malloc.free(_imageBuffer!);
    _imageBuffer = null;

    return detectionList;
  }

  void dispose() {
    _destroyDetector();
    if (_imageBuffer != null) {
      malloc.free(_imageBuffer!);
    }
  }

  String cvVersion() {
    return _version().toDartString();
  }
}
