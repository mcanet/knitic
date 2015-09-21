#ifndef DEFINED_KNITIC_H_
#define DEFINED_KNITIC_H_

#ifdef arduinoTypeUNO
    #define encoder0PinA 2
    #define encoder0PinB 3
    #define encoder0PinC 4
#endif
#ifdef arduinoTypeDUE
    #define encoder0PinA 2
    #define encoder0PinB 3
    #define encoder0PinC 4
    #define piezoPin     9
    #define endLineLeftAPin A1
    #define endLineRightAPin A0
#endif

#endif

