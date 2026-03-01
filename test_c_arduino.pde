import processing.serial.*;

String arduinoPort = "/dev/ttyACM0";
boolean isConnected = false;
boolean fingerTestUploaded = false; 
boolean readyForButtonTest = false;
boolean buttonTestUploaded = false;
boolean isControlling = false;
boolean isTurbo = false;
int connectionTime = 0;

Serial myPort;

int btnX, btnY, btnW, btnH;
int[] fingerClickTimers = new int[5];

void setup() {
  size(400, 480);
  textAlign(CENTER, CENTER);
  textSize(24);
  
  btnW = 200;
  btnH = 50;
  btnX = width/2 - btnW/2;
  btnY = height/2 + 40;
  
  checkConnection();
}

void draw() {
  if (frameCount % 60 == 0 && !isConnected) {
    checkConnection();
  }

  if (!isConnected) {
    background(178, 34, 34);
    fill(255);
    textLeading(30);
    text("Arduino no encontrado\n(buscando en " + arduinoPort + ")", width/2, height/2 - 20);
    
    buttonTestUploaded = false;
    readyForButtonTest = false;
    isControlling = false;
    if (myPort != null) {
      myPort.stop();
      myPort = null;
    }
  } 
  else {
    if (!fingerTestUploaded) {
      background(34, 139, 34);
      fill(255);
      text("Arduino Conectado\n\nfingertest...", width/2, height/2);
      
      if (millis() - connectionTime > 3000) {
        uploadSketch("fingertest/fingertest.ino");
        fingerTestUploaded = true;
      }
    } 
    else if (!readyForButtonTest) {
      background(0, 150, 200);
      fill(255);
      text("fingertest OK!", width/2, height/2 - 60);
      drawButton("siguiente", btnX, btnY - 20);
    }
    else if (!buttonTestUploaded) {
      background(255, 204, 0);
      fill(0);
      text("Esperando...", width/2, height/2 - 40);
      drawButton("buttontest", btnX, btnY);
    }
    else if (!isControlling) {
      background(0, 150, 200);
      fill(255);
      text("buttontest OK!", width/2, height/2 - 60);
      drawButton("empezar", btnX, btnY - 20);
    }
    else {
      if (!isTurbo) {
        background(50, 50, 50);
        fill(255);
        text("BUTTONTEST", width/2, 40);
        
        for(int i = 0; i < 5; i++) {
          if (fingerClickTimers[i] > 0) {
            fingerClickTimers[i]--;
          }
          int fingerY = 90 + (i * 60);
          drawButton("dedo" + (i + 1), btnX, fingerY, fingerClickTimers[i] > 0);
        }
        
        drawColoredButton("turbo", btnX, 390, color(255, 140, 0), color(220, 110, 0), color(180, 80, 0), false);
      } else {
        background(255, 140, 0);
        fill(0);
        text("TURBO FINGERTEST", width/2, 40);
        
        for(int i = 0; i < 5; i++) {
          if (fingerClickTimers[i] > 0) {
            fingerClickTimers[i]--;
          }
          int fingerY = 90 + (i * 60);
          drawButton("dedo" + (i + 1), btnX, fingerY, fingerClickTimers[i] > 0);
        }
        
        drawColoredButton("normal", btnX, 390, color(200), color(170), color(130), false);
      }
    }
  }
}

void drawButton(String label, int x, int y) {
  drawButton(label, x, y, false);
}

void drawButton(String label, int x, int y, boolean forcePressed) {
  boolean isHovered = mouseX > x && mouseX < x + btnW && mouseY > y && mouseY < y + btnH;
  boolean isPressed = forcePressed || (isHovered && mousePressed);
  
  int drawY = y;
  
  if (isPressed) {
    fill(170);
    drawY += 4;
  } else if (isHovered) {
    fill(220);
  } else {
    fill(255);
  }
  
  rect(x, drawY, btnW, btnH, 10);
  
  fill(0);
  textSize(20);
  text(label, x + btnW/2, drawY + btnH/2);
  textSize(24);
}

void drawColoredButton(String label, int x, int y, color cDef, color cHov, color cPress, boolean forcePressed) {
  boolean isHovered = mouseX > x && mouseX < x + btnW && mouseY > y && mouseY < y + btnH;
  boolean isPressed = forcePressed || (isHovered && mousePressed);
  
  int drawY = y;
  
  if (isPressed) {
    fill(cPress);
    drawY += 4;
  } else if (isHovered) {
    fill(cHov);
  } else {
    fill(cDef);
  }
  
  rect(x, drawY, btnW, btnH, 10);
  
  fill(0);
  textSize(20);
  text(label, x + btnW/2, drawY + btnH/2);
  textSize(24);
}

void mousePressed() {
  if (!isConnected) return;

  if (fingerTestUploaded && !readyForButtonTest) {
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > (btnY - 20) && mouseY < (btnY - 20) + btnH) {
      readyForButtonTest = true;
    }
  }
  else if (readyForButtonTest && !buttonTestUploaded) {
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
      uploadSketch("buttontest/buttontest.ino");
      buttonTestUploaded = true;
    }
  }
  else if (buttonTestUploaded && !isControlling) {
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > (btnY - 20) && mouseY < (btnY - 20) + btnH) {
      try {
        myPort = new Serial(this, arduinoPort, 9600);
        isControlling = true;
      } catch (Exception e) {
        println(e.getMessage());
      }
    }
  }
  else if (isControlling) {
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > 390 && mouseY < 390 + btnH) {
      isTurbo = !isTurbo;
    } else {
      for(int i = 0; i < 5; i++) {
        int fingerY = 90 + (i * 60);
        if (mouseX > btnX && mouseX < btnX + btnW && mouseY > fingerY && mouseY < fingerY + btnH) {
          if (myPort != null) {
            myPort.write(isTurbo ? char('a' + i) : char('1' + i)); 
          }
        }
      }
    }
  }
}

void keyPressed() {
  if (!isControlling || myPort == null) return;
  
  if (key == ' ') { myPort.write(isTurbo ? 'a' : '1'); fingerClickTimers[0] = 10; }
  else if (key == 'u' || key == 'U') { myPort.write(isTurbo ? 'b' : '2'); fingerClickTimers[1] = 10; }
  else if (key == 'i' || key == 'I') { myPort.write(isTurbo ? 'c' : '3'); fingerClickTimers[2] = 10; }
  else if (key == 'o' || key == 'O') { myPort.write(isTurbo ? 'd' : '4'); fingerClickTimers[3] = 10; }
  else if (key == 'p' || key == 'P') { myPort.write(isTurbo ? 'e' : '5'); fingerClickTimers[4] = 10; }
}

void checkConnection() {
  String[] availablePorts = Serial.list();
  boolean wasConnected = isConnected; 
  isConnected = false; 
  
  for (int i = 0; i < availablePorts.length; i++) {
    if (availablePorts[i].equals(arduinoPort)) {
      isConnected = true;
      if (!wasConnected) {
        connectionTime = millis(); 
      }
      break; 
    }
  }
}

void uploadSketch(String sketchName) {
  println("loading " + sketchName + "...");
  
  String inoPath = sketchPath(sketchName); 
  
  String cliCommand = "arduino-cli compile --upload -p " + arduinoPort + " --fqbn arduino:renesas_uno:unor4wifi '" + inoPath + "'";
  
  String bashScript = "";
  
  if (sketchName.equals("fingertest/fingertest.ino")) {
    bashScript += "echo '  _____.__                             __                   __   '; ";
    bashScript += "echo '_/ ____\\__| ____    ____   ___________/  |_   ____  _______/  |_ '; ";
    bashScript += "echo '\\   __\\|  |/    \\  / ___\\_/ __ \\_  __ \\   __\\/ __ \\ /  ___/\\   __\\'; ";
    bashScript += "echo ' |  |  |  |   |  \\/ /_/  >  ___/|  | \\/|  | \\  ___/ \\___ \\  |  |  '; ";
    bashScript += "echo ' |__|  |__|___|  /\\___  / \\___  >__|   |__|  \\___  >____  > |__|  '; ";
    bashScript += "echo '               \\//_____/      \\/                 \\/     \\/        '; ";
    bashScript += "echo 'by Carlos Ramirez'; ";
    bashScript += "echo ''; ";
  } else if (sketchName.equals("buttontest/buttontest.ino")) {
    bashScript += "echo \" _           _   _              _            _   \"; ";
    bashScript += "echo \"| |__  _   _| |_| |_ ___  _ __ | |_ ___  ___| |_ \"; ";
    bashScript += "echo \"| '_ \\\\| | | | __| __/ _ \\\\| '_ \\\\| __/ _ \\\\/ __| __|\"; ";
    bashScript += "echo \"| |_) | |_| | |_| || (_) | | | | ||  __/\\\\__ \\\\ |_ \"; ";
    bashScript += "echo \"|_.__/ \\\\__,_|\\\\__|\\\\__\\\\___/|_| |_|\\\\__\\\\___||___/\\\\__|\"; ";
    bashScript += "echo \"by Carlos Ramirez\"; ";
    bashScript += "echo \"\"; ";
  }
  
  bashScript += cliCommand + "; echo ''; echo 'Exiting...'; sleep 3;";
  
  String[] command = {
    "gnome-terminal", 
    "--", 
    "bash", 
    "-c", 
    bashScript
  };
  
  exec(command);
}
