#include <opencv2/core.hpp>
#include "EyeTracker.h"

using namespace std;
using namespace cv;

static EyeTracker *eyeTracker = nullptr;

// Provides the implementation for the native C++ functions that are called from Dart/Flutter through the Dart FFI
extern "C"
{
    __attribute__((visibility("default"))) __attribute__((used))
    const char *
    version()
    {
        return CV_VERSION;
    }

    __attribute__((visibility("default"))) __attribute__((used)) void initDetector(const char *xmlFilePath)
    {
        if (xmlFilePath == nullptr || xmlFilePath[0] == '\0')
        {
            return;
        }

        eyeTracker = new EyeTracker(xmlFilePath);
    }

    __attribute__((visibility("default"))) __attribute__((used)) void destroyDetector()
    {
        if (eyeTracker != nullptr)
        {
            delete eyeTracker;
            eyeTracker = nullptr;
        }
    }

    __attribute__((visibility("default"))) __attribute__((used))
    const char *
    detectEyes(const char *image, int width, int height, int channels, double scaleFactor, int minNeighbors)
    {
        cv::Mat frame;
        if (channels == 1) {
            // If input is grayscale, use it directly
            frame = cv::Mat(height, width, CV_8UC1, const_cast<char *>(image));
        } else {
            // If input is color, convert it to grayscale
            cv::cvtColor(cv::Mat(height, width, CV_8UC(channels), const_cast<char *>(image)), frame, cv::COLOR_BGR2GRAY);
        }

        std::vector<cv::Rect> eyes;
        if (frame.empty())
        {
            std::cout << "DEBUG: Empty Image" << std::endl;
        }

        std::string result = eyeTracker->DetectEyes(frame, scaleFactor, minNeighbors);
        const char *resultCStr = strdup(result.c_str());
        return resultCStr;
    }
}
