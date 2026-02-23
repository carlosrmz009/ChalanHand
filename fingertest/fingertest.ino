#include <Servo.h>

Servo fingers[5]; 
int fingerPins[] = {2, 3, 4, 5, 6}; 

void setup() {
  for (int i = 0; i < 5; i++) {
    fingers[i].attach(fingerPins[i]);

    fingers[i].write(180);
    delay(500);
    fingers[i].write(90);
    delay(500); 
    fingers[i].write(0);
    delay(500);
  }
}

void loop() {
  
}
