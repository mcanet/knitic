//
//  ofxBrotherKnittingMachines.cpp
//
//  Created by Mar Canet Sola on 5/22/12.
//  mar.canet@gmail.com
//

#include "ofxBrotherKnittingMachines.h"

ofxBrotherKnittingMachines::ofxBrotherKnittingMachines(){
    
}

void ofxBrotherKnittingMachines::setup(){
    myKHKnittingBrother.format_memory();
    
    // default serial is first port
    ofSerial serial;
    vector <ofSerialDeviceInfo> deviceList = serial.getDeviceList();
    serialDevicePath = deviceList[0].getDevicePath();
}

void ofxBrotherKnittingMachines::threadedFunction(){
    cout << "Try to open serial:"+serialDevicePath << endl;
    char* serialDevicePathChar = const_cast<char*>(serialDevicePath.c_str());
    myKHKnittingBrother.emulate_start(serialDevicePathChar,true);
    stopThread();
}

void ofxBrotherKnittingMachines::uploadFinished(){
    myKHKnittingBrother.emulate_stop();
}

void ofxBrotherKnittingMachines::cleanMemory(){
    myKHKnittingBrother.format_memory();
}

bool ofxBrotherKnittingMachines::isUploadPatterns(){
    return isThreadRunning();
}

string ofxBrotherKnittingMachines::add_pattern(unsigned char *img,int width,int height){
    int result = myKHKnittingBrother.add_pattern((uint8_t*)img,(uint16_t)width,(uint16_t)height);
    string statusMessage="";
    switch(result){
        case 0:
            statusMessage = "The pattern was added succesfully\n";
            break;
        case 1:
            statusMessage = "Not enough memory to store pattern\n";
            break;    
        case 2:
            statusMessage = "Pattern was added but can not be found\n memory may be corrupted, format suggested\n";
            break; 
        case 3:
            statusMessage = "File does not have the correct format\n";
            break; 
    }
    return statusMessage;
}

void ofxBrotherKnittingMachines::uploadPatterns(){
    startThread(true, false);
}

vector <string> ofxBrotherKnittingMachines::getListSerialDevices(){
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

void ofxBrotherKnittingMachines::setSerialPath(string path){
    serialDevicePath = path;
}

void ofxBrotherKnittingMachines::setKnittingMachineModel(string id){
    if(id=="kh940" || id=="KH940" || id=="kH940" || id=="Kh940")myKHKnittingBrother.set_machine_model(0);
    if(id=="kh930" || id=="KH930" || id=="kH930" || id=="Kh930")myKHKnittingBrother.set_machine_model(1);
}

unsigned char * ofxBrotherKnittingMachines::getCurrentMemory(){
    return;
}

int ofxBrotherKnittingMachines::getTotalPatterns(){
    return myKHKnittingBrother.getTotalPatterns();
}

int ofxBrotherKnittingMachines::getTotalMemoryUsed(){
    return myKHKnittingBrother.getTotalMemoryUsed();
}

int ofxBrotherKnittingMachines::getTotalMemory(){
    return 0;
}