cmake_minimum_required(VERSION 3.22.1)

project(native_opencv)

# opencv
set(OpenCV_STATIC ON)
set(OpenCV_DIR $ENV{OPENCV_ANDROID}/sdk/native/jni)
find_package(OpenCV REQUIRED)

add_library(
        native_opencv
        SHARED
        ../android/Classes/EyeTracker/EyeTracker.cpp
        ../android/Classes/native_opencv.cpp
)

target_include_directories(
        native_opencv PRIVATE
        ../android/Classes/EyeTracker
)

find_library(log-lib log)

target_link_libraries(
        native_opencv
        ${OpenCV_LIBS}
        ${log-lib}
)

# 16KB page size alignment for Android 15+
target_link_options(native_opencv PRIVATE "-Wl,-z,max-page-size=16384")