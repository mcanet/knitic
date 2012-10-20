//
//  ofxBrotherKnittingMachines.h
//
//  Created by mar Canet sola on 5/22/12.
//  mar.canet@gmail.com
//

#ifndef _ofxBrotherKnittingMachines_h
#define _ofxBrotherKnittingMachines_h

#include "ofMain.h"
#define TARGET_OF_KNITTING_ADDON
#include "knit.h"

class ofxBrotherKnittingMachines : public ofThread{
public:
    ofxBrotherKnittingMachines();
    // setup arrange all things need to do at begining 
    void setup();
    // Clear temporal memory to send to machine 
    void cleanMemory();
    // Tell to software the uploading has finish
    void uploadFinished();
    // Upload patterns memory to machine
    void uploadPatterns();
    // Return true when app is in process to upload patterns memory to machine
    bool isUploadPatterns();
    // Add image information as pattern in machine memory
    string add_pattern(unsigned char *img,int width,int height);
    // Get array from serial device paths
    vector <string>getListSerialDevices();
    // Serial path from serial 
    void setSerialPath(string path);
    // Set Brother knitting Machine model 
    // The models implemented: kh940, kh930
    void setKnittingMachineModel(string id);
    // get memory
    unsigned char * getCurrentMemory();
    int getTotalPatterns();
    int getTotalMemoryUsed();
    int getTotalMemory();
private:
    // threaded method use to upload to machine
    void threadedFunction();
    knit myKHKnittingBrother;
    string serialDevicePath;
};

#endif
