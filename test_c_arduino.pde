import processing.serial.*;

String arduinoPort = "/dev/ttyACM0";
boolean isConnected = false;
boolean fingerTestUploaded = false; 
boolean buttonTestUploaded = false; 
int connectionTime = 0;

int btnX, btnY, btnW, btnH;

void setup() {
  size(400, 300);
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
    else {
      background(255, 204, 0);
      fill(0);
      
      if (!buttonTestUploaded) {
        text("Esperando...", width/2, height/2 - 40);
      } else {
        text("buttontest...", width/2, height/2 - 40);
      }
      
      drawButton();
    }
  }
}

void drawButton() {
  if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
    fill(220); 
  } else {
    fill(255); 
  }
  
  rect(btnX, btnY, btnW, btnH, 10);
  
  fill(0);
  textSize(20);
  text("buttontest", btnX + btnW/2, btnY + btnH/2);
  textSize(24);
}

void mousePressed() {
  if (isConnected && fingerTestUploaded && !buttonTestUploaded) {
    if (mouseX > btnX && mouseX < btnX + btnW && mouseY > btnY && mouseY < btnY + btnH) {
      uploadSketch("buttontest/buttontest.ino");
      buttonTestUploaded = true;
    }
  }
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
  
  String inoPath = "/home/carlos/sketchbook/test_c_arduino/" + sketchName; 
  
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
