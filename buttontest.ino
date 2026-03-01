#include <Servo.h>
#include "Arduino_LED_Matrix.h"

Servo fingers[5]; 
int fingerPins[] = {2, 3, 4, 5, 6};

bool fingerState[5] = {false, false, false, false, false}; 

ArduinoLEDMatrix matrix;

uint8_t numFrames[5][8][12] = {
  {
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,1,1,1,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0}
  },
  {
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,1,0,0,1,0,0,0,0},
    {0,0,0,0,0,0,0,1,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,1,0,0,0,0,0,0},
    {0,0,0,0,1,0,0,0,0,0,0,0},
    {0,0,0,0,1,1,1,1,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0}
  },
  {
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,1,0,0,1,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,1,0,0,0,0},
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0}
  },
  {
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,1,0,1,0,0,0,0,0},
    {0,0,0,1,0,0,1,0,0,0,0,0},
    {0,0,0,1,1,1,1,1,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0}
  },
  {
    {0,0,0,0,1,1,1,1,0,0,0,0},
    {0,0,0,0,1,0,0,0,0,0,0,0},
    {0,0,0,0,1,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,1,0,0,0,0},
    {0,0,0,0,0,0,0,1,0,0,0,0},
    {0,0,0,0,1,0,0,1,0,0,0,0},
    {0,0,0,0,0,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0}
  }
};

uint8_t okFrame[8][12] = {
  {0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,1,1,0,0,1,0,0,1,0},
  {0,0,1,0,0,1,0,1,0,1,0,0},
  {0,0,1,0,0,1,0,1,1,0,0,0},
  {0,0,1,0,0,1,0,1,0,1,0,0},
  {0,0,0,1,1,0,0,1,0,0,1,0},
  {0,0,0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0,0,0}
};

void setup() {
  Serial.begin(9600);
  matrix.begin();
  matrix.renderBitmap(okFrame, 8, 12); 

  for (int i = 0; i < 5; i++) {
    fingers[i].attach(fingerPins[i]);
    fingers[i].write(180); 
  }
}

void loop() {
  if (Serial.available() > 0) {
    char incomingByte = Serial.read();

    // 1-5: Normal Toggle Mode
    if (incomingByte >= '1' && incomingByte <= '5') {
      int fingerIndex = incomingByte - '1';

      if (fingerIndex >= 0 && fingerIndex <= 4) {
        if (fingerState[fingerIndex] == false) {
          fingers[fingerIndex].write(0);
          fingerState[fingerIndex] = true;
        } else {
          fingers[fingerIndex].write(180);
          fingerState[fingerIndex] = false;
        }
        matrix.renderBitmap(numFrames[fingerIndex], 8, 12);
      }
    }
    // turbo
    else if (incomingByte >= 'a' && incomingByte <= 'e') {
      int fingerIndex = incomingByte - 'a';

      if (fingerIndex >= 0 && fingerIndex <= 4) {
        matrix.renderBitmap(numFrames[fingerIndex], 8, 12);
        
        fingers[fingerIndex].write(0);
        delay(250); 
        fingers[fingerIndex].write(180);
        delay(250);
        fingers[fingerIndex].write(0);
        
        fingerState[fingerIndex] = true;
      }
    }
  }
}