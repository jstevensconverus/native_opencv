#include "EyeTracker.h"
#include "json.hpp"
// #include <android/log.h>
#include <fstream>
#include <sstream>
#include <string>

using json = nlohmann::json;
using namespace cv;
using namespace std;

CascadeClassifier classifierEyes;

EyeTracker::EyeTracker(const char *xmlFilePath)
{
    std::cerr << "XML C++: " << xmlFilePath << std::endl;
    // When initialized, loads the Haar cascade model for detecting eyes
    if (!classifierEyes.load(xmlFilePath))
    {
        std::string errorMessage = "Failed to load the Haar cascade model for eyes!";
        if (classifierEyes.empty())
        {
            errorMessage += " Cascade file not found.";
        }
        else
        {
            errorMessage += " Unknown error occurred.";
        }
        std::cerr << errorMessage << std::endl;
    }
}

std::string EyeTracker::DetectEyes(cv::Mat image, double scaleFactor, int minNeighbors)
{
    // Declares eyes variable
    std::vector<cv::Rect> eyes;
    
    // Takes gray scale image and detects eye objects
    classifierEyes.detectMultiScale(image, eyes, scaleFactor, minNeighbors);

    // Converts Rect objects into JSON to be passes back to flutter project.
    json jsonData;
    for (const Rect &rect : eyes)
    {
        json rectData = {
            {"x", rect.x},
            {"y", rect.y},
            {"width", rect.width},
            {"height", rect.height}};
        jsonData.push_back(rectData);
    }

    return jsonData.dump();
}
