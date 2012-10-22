#pragma once

#include "ofMain.h"
#include "ofxOpenKnitting.h"
#include "ofxUI.h"

class testApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed  (int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void gotMessage(ofMessage msg);
		void dragEvent(ofDragInfo dragInfo);
		void exit(); 
	
        ofxOpenKnitting myKnittingMachine;
        // upload images
        vector <ofImage> draggedImages;
        ofPoint dragPt;
        ofPixels pix; 
        uint8_t* file;
        // GUI
       
        void guiEvent(ofxUIEventArgs &e);
        bool drawPadding; 
        float red, green, blue; 
        ofTrueTypeFont font;
        
        ofxUICanvas *gui_actions;
        ofxUICanvas *gui_settings;
        ofxUILabel* totalPatternsLabel;
        ofxUILabel* totalUsedMemoryLabel;
        ofxUILabelToggle* uploadLabelToggle;
        ofxUIRadio* serialPortRadio;
};
