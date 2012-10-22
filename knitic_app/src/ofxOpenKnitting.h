//
//  ofxOpenKnitting.h
//  emptyExample
//
//  Created by mar Canet sola on 10/17/12.
//  Copyright (c) 2012 student. All rights reserved.
//

#ifndef ofxOpenKnitting_h
#define ofxOpenKnitting_h

#include "ofMain.h"
#include "ofxXmlSettings.h"

enum status_id{status_stop=0,status_knitting=1};

class ofxOpenKnitting: public ofThread{
public:
    ofxOpenKnitting();
    ~ofxOpenKnitting();
    void setup();
    void update();
    void draw();
    bool isKnittingPatterns();
    void startKnittingPattern();
    void stopKnittingPattern();
    vector <string> getListSerialDevices();
    int getTotalPatterns();
    //int getTotalMemoryUsed();
    //int getTotalMemory();
    int row;
    int section;
    string _16Selenoids;
    int rowEnd;
    string action;
    
private:
    void threadedFunction();
    void serialSend();
    void serialReceive();
    string serialDevicePath;
    ofSerial serial;
    string lastSerialData;
    void saveXML();
    void loadXML();
    int status;
};

#endif
