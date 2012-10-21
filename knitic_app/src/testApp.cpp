#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    ofSetWindowTitle("Pattern Uploader for Brother Knitting machines");
    ofSetVerticalSync(true); 
	ofEnableSmoothing(); 
    // format
    
    file=NULL;
    dragPt.x = 100;
    dragPt.y = 100;
    
    font.loadFont("GUI/NewMedia Fett.ttf",14);
    
    //"/dev/tty.usbserial-A7V8PMWN
    myKnittingMachine.setup();
    
    red = 233; blue = 27; green = 52; 
	
	
	float xInit = OFX_UI_GLOBAL_WIDGET_SPACING; 
    float length = 320;
    
    float w = length - 2 * xInit;
	float h = 32;
    
    drawPadding = false; 

    
    // Settings
    gui_settings = new ofxUICanvas(ofGetWidth()-length, 0, length, ofGetHeight());
   
    
    gui_settings->addWidgetDown(new ofxUILabel("KNITTING MACHINE ACTIONS:", OFX_UI_FONT_MEDIUM));
    gui_settings->addWidgetDown(new ofxUISpacer(w, 2));
    gui_settings->addWidgetDown(new ofxUILabelButton("Clear patterns", false, w, h, OFX_UI_FONT_MEDIUM));
    uploadLabelToggle = new ofxUILabelToggle("Start Knitting", false, w, h, OFX_UI_FONT_MEDIUM);
    gui_settings->addWidgetDown(uploadLabelToggle);
    
    gui_settings->addWidgetDown(new ofxUISpacer(w, 2));
    // ofxUILabelButton(string _name, bool _value, float w = 0, float h = 0, float x = 0, float y = 0, int _size = OFX_UI_FONT_MEDIUM)
    
    gui_settings->addWidgetDown(new ofxUILabelButton("Refresh serial port", false, w, h));
    
    //ofxUIRadio(string _name, vector<string> names, int _orientation, float w, float h, float x = 0, float y = 0)
    
    serialPortRadio = new ofxUIRadio( "Select serial port:", myKnittingMachine.getListSerialDevices(), OFX_UI_ORIENTATION_VERTICAL, h/2, h/2);
    gui_settings->addWidgetDown(serialPortRadio); 
    gui_settings->addWidgetDown(new ofxUISpacer(w, 2));
    
    gui_settings->loadSettings("GUI/guiSettings_settings.xml");
    ofAddListener(gui_settings->newGUIEvent,this,&testApp::guiEvent);
    
     draggedImages.push_back(ofImage());
}

//--------------------------------------------------------------
void testApp::update(){
    //totalPatternsLabel->setLabel( "Total patterns:"+ ofToString(myKnittingMachine.getTotalPatterns()) );
    myKnittingMachine.update();
}

//--------------------------------------------------------------
void testApp::draw(){
    
	ofSetColor(255);
	float dx = dragPt.x;
	float dy = dragPt.y;
	for(int k = 0; k < draggedImages.size(); k++){
		draggedImages[k].draw(dx, dy);
		dy += draggedImages[k].getHeight() + 40;
	}
	
	ofSetColor(255);
    font.drawString("Drag image files into this window", 50, 20);
    font.drawString("Section:"+ofToString(myKnittingMachine.section), 450, 300);
    font.drawString("Row:"+ofToString(myKnittingMachine.row), 450, 440);
    font.drawString("16Selenoids:"+myKnittingMachine._16Selenoids, 450, 380);
    
    // drawing memory
    /*
    ofSetColor(30,30,30);
	ofRect(450,50,200,1000);
    */
    myKnittingMachine.draw();
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){

}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
    
    // clean all memory
    if(key=='c' || key=='C'){
        draggedImages.erase(draggedImages.begin(), draggedImages.end());
    }
    // 
    if(key=='u' || key=='U'){
        if(!myKnittingMachine.isKnittingPatterns()){
            myKnittingMachine.startKnittingPattern();
        }
    }
    
}

//----------------------------  ---------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo info){
	if( info.files.size() > 0  && !myKnittingMachine.isKnittingPatterns() ){

        // Only allow one image to add at the time
        for(int k = 0; k < info.files.size(); k++){
            draggedImages[0].loadImage(info.files[k]);
            draggedImages[0].setImageType(OF_IMAGE_GRAYSCALE);
        }
        
        int lastImageId = draggedImages.size()-1; 
        
        // transform image to bitmap
        pix = draggedImages[lastImageId].getPixelsRef();
        int w = draggedImages[lastImageId].width;
        int h = draggedImages[lastImageId].height;
        // Get pixels
        /*
        if(file!=NULL) delete file;
        int totalPixels = (draggedImages[lastImageId].width * draggedImages[lastImageId].height);
        file = new unsigned char[totalPixels];
                                                                    
        int x = 0;
        int y = 0;
       
        cout <<"Width:"  << file[0]<< endl;
        cout <<"Height:" << file[1]<< endl;
        cout <<"Total pixels:" << pix.size()<< endl;
        
        for(int i = 0; i<pix.size(); i++){
            if(pix[i]>0) pix[i] = 255;
            file[i] = pix[i];
            cout << i << ":" << pix[i]<< endl;
        }
        */
    }
}

//--------------------------------------------------------------

void testApp::guiEvent(ofxUIEventArgs &e)
{
    
	string name = e.widget->getName(); 
	int kind = e.widget->getKind(); 
    
    if(name=="Start Knitting"){
        uploadLabelToggle->setLabelText("Stop Knitting");
        myKnittingMachine.startKnittingPattern();
    }
    
    if(name=="Stop Knitting"){
        uploadLabelToggle->setLabelText("Start Knitting");
        myKnittingMachine.stopKnittingPattern();
    }
    
    /*
    cout <<"event:" << name <<endl;
    
    // look if choose a serial
    vector<string> allSerialPaths = myKnittingMachine.getListSerialDevices();
    for(int i=0;i<allSerialPaths.size();i++){
        if(name==allSerialPaths[i]){
            myKnittingMachine.setSerialPath(name);
        }
    }
    if(name == "Refresh serial port"){
    serialPortRadio->addsfdA
        = new ofxUIRadio( dim/2, dim/2, "Select serial port:", myKnittingMachine.getListSerialDevices(), OFX_UI_ORIENTATION_VERTICAL);
    }
    
    if(name == "Select serial port:" ){
    }
    
    if(name == "KH940" || name == "KH930"){ 
        myKnittingMachine.setKnittingMachineModel(name);
    }
        
	if(name == "Clear memory")
	{
        myKnittingMachine.cleanMemory();
        draggedImages.erase(draggedImages.begin(), draggedImages.end());
	}
    if(name == "Upload Patterns")
	{
        uploadLabelToggle->setName("Finish uploading Patterns");
        uploadLabelToggle->getLabel()->setLabel("Finish uploading Patterns");
        cout <<"after event:" << uploadLabelToggle->getName()<<endl;
        myKnittingMachine.uploadPatterns();
    }
    if(name == "Finish uploading Patterns")
	{
        uploadLabelToggle->setName("Upload Patterns");
        uploadLabelToggle->getLabel()->setLabel("Upload Patterns");
        myKnittingMachine.uploadFinished();   
	}
    
    gui_actions->saveSettings("GUI/guiSettings_actions.xml");     
    gui_settings->saveSettings("GUI/guiSettings_settings.xml");  
    */
}

//--------------------------------------------------------------

void testApp::exit(){
    gui_actions->saveSettings("GUI/guiSettings_actions.xml");     
    gui_settings->saveSettings("GUI/guiSettings_settings.xml");  
    delete gui_actions; 
    delete gui_settings;
}