//
//  ofxOpenKnitting.cpp
//  emptyExample
//
//  Created by mar Canet sola on 10/17/12.
//  Copyright (c) 2012 student. All rights reserved.
//

#include "ofxOpenKnitting.h"

ofxOpenKnitting::ofxOpenKnitting(){

}

ofxOpenKnitting::~ofxOpenKnitting(){

}

void ofxOpenKnitting::setup(){
    // default serial is first port
    vector <ofSerialDeviceInfo> deviceList = serial.getDeviceList();
    serialDevicePath = deviceList[0].getDevicePath();
    serial.setup(0, 9600);
    lastSerialData ="";
}

void ofxOpenKnitting::update(){
    // serial read from arduino
    serialSend();
    serialReceive();
}

void ofxOpenKnitting::serialSend(){
    string variables = "s-1-1-1-1010101010101010-knitting-e";
    serial.writeBytes((unsigned char*)&variables,variables.size());
}

void ofxOpenKnitting::serialReceive(){
    if(serial.available()>=40){ 
        string received = "";
        unsigned char bytesReadString[40];
        memset(bytesReadString, 0, 40);
        serial.readBytes( bytesReadString, 40);
        string all = (char*)bytesReadString;
        serial.flush(); 
        // get data from serial
        vector <string> values = ofSplitString(lastSerialData+all,"-");
        
        
        int start =-1;
        int end =-1;
        
        // look for start inside string received
        for(int i=0;i<values.size();i++){
            if(values[i]=="s"){
                start =i;
                break;
            }
        }
        
        // look for end inside string received
        for(int i=0;i<values.size();i++){
            if(values[i]=="e"){
                end =i;
                break;
            }
        }
        // when we find start and end then take out variables
        if(start!=-1 && end!=-1  && end > start+5){
            section = ofToInt(values[start+1]);
            row = ofToInt(values[start+2]);
            rowEnd = ofToInt(values[start+3]);
            _16Selenoids = values[start+4];
            action = values[start+5];
            cout << " section:" << section << " row:" << row << " rowEnd:" << rowEnd  << " _16Selenoids:" << _16Selenoids << endl;
            lastSerialData = "";
        }else{
            lastSerialData +=all;
        }
    }
}

void ofxOpenKnitting::draw(){

}

bool ofxOpenKnitting::isKnittingPatterns(){
    return isThreadRunning();
}

void ofxOpenKnitting::startKnittingPattern(){
    startThread(true, false);
    row = 0;
    section = 0;
    _16Selenoids = "0000000000000000";
}

void ofxOpenKnitting::stopKnittingPattern(){
    
}

vector <string> ofxOpenKnitting::getListSerialDevices(){
    vector <string> temp;
    if(!isThreadRunning()){
        ofSerial serial;
        vector <ofSerialDeviceInfo> deviceList = serial.getDeviceList();
        for(int i=0;i<deviceList.size();i++){
            temp.push_back(deviceList[i].getDevicePath());
        }
    }
    return temp;
}

void ofxOpenKnitting::threadedFunction(){
    cout << "Try to open serial:"+serialDevicePath << endl;
    char* serialDevicePathChar = const_cast<char*>(serialDevicePath.c_str());
    serial.setup(serialDevicePathChar, 9600);
    stopThread();
}

int ofxOpenKnitting::getTotalPatterns(){
    return 1;
}

void ofxOpenKnitting::saveXML(){
    
}

void ofxOpenKnitting::loadXML(){
    
}


