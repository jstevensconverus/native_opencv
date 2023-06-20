import 'package:flutter_test/flutter_test.dart';
import 'package:native_opencv/native_opencv.dart';
import 'package:native_opencv/native_opencv_platform_interface.dart';
import 'package:native_opencv/native_opencv_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeOpencvPlatform with MockPlatformInterfaceMixin implements NativeOpenCVPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeOpenCVPlatform initialPlatform = NativeOpenCVPlatform.instance;

  test('$MethodChannelNativeOpenCV is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeOpenCV>());
  });

  test('getPlatformVersion', () async {
    NativeOpenCV nativeOpencvPlugin = NativeOpenCV();
    MockNativeOpencvPlatform fakePlatform = MockNativeOpencvPlatform();
    NativeOpenCVPlatform.instance = fakePlatform;

    expect(await nativeOpencvPlugin.platformVersion, '42');
  });
}
