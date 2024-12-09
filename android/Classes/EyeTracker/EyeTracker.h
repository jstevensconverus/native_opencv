#ifndef EYE_TRACKER_H
#define EYE_TRACKER_H

#include <vector>
#include <opencv2/opencv.hpp>

class EyeTracker {

public:
    EyeTracker(const char* xmlFilePath);

    std::string DetectEyes(cv::Mat image, double scaleFactor, int minNeighbors);
};

#endif  // EYE_TRACKER_H
