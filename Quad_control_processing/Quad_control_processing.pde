import processing.video.*;
import processing.serial.*;

// Serial communication
Serial myPort;
final byte SLIP_END = (byte)0xC0;
final byte SLIP_ESC = (byte)0xDB;
final byte SLIP_ESC_END = (byte)0xDC;
final byte SLIP_ESC_ESC = (byte)0xDD;
byte[] bytes = new byte[4];

//Camera 
Capture cam;
float r, g, b;

//Controls
int throttle, yaw, pitch, roll;

//Boolean to determine if the drone should liftoff or stop
boolean flying;

void setup() {
  yaw = pitch = roll = 128;
  throttle = 0;
  flying = false;
  size(1280, 720);
   String[] cameras = Capture.list();
   if (cameras.length == 0){
     println("There is no available camera");
     exit();
   } else {
     println("Available cameras: ");
     for (int i = 0; i<cameras.length; i++){
       println(cameras[i]);
     }
     cam = new Capture(this, cameras[0]);
     cam.start();
   }
   
  /*String portName = Serial.list()[1];
  System.out.println(portName);
  myPort = new Serial(this, portName, 9600);*/
}

void draw() {
  if (cam.available() == true) cam.read();
  cam.loadPixels();
  for (int i = 0; i<cam.pixels.length; i+=13){
    r=red(cam.pixels[i]);
    g=green(cam.pixels[i]);
    b=blue(cam.pixels[i]);
    if(b - g > 40 && b - r > 40){
      cam.pixels[i] = color(0,0,0,0);
    }
  }
  cam.updatePixels();
  set(0,0,cam);
  
}

//Click camera window
void keyPressed() {
  //Should not send liftoff or hover
  if(key != ' ' && key != 'z') {
    sendCommand(key);
  }
}

void keyReleased() {
  //Should only do start, stop and hover commands
  if(key == ' ' || key == 'z') {
    sendCommand(key);
  }
}

//control commands
void sendCommand(char command) {
  
  if(command == ' ') {
    if(flying) {
      stop();
      System.out.println("Stop");
    }
    else {
      start();
      System.out.println("Liftoff");
    }
    delay(500);
    flying = !flying;
  }
  
  if(command == 'a') {
    rotateLeft();
    System.out.println("Rotate Left");
  }
  
  if(command == 'd') {
    rotateRight();
    System.out.println("Rotate Right");
  }
  
  if(command == 'q') {
    rollLeft();
    System.out.println("Roll Left");
  }
  
  if(command == 'e') {
    rollRight();
    System.out.println("Roll Right");
  }
  
  if(command == 'i') {
    raise();
    System.out.println("Raise");
  }
  
  if(command == 'k') {
    lower();
    System.out.println("Lower");
  }
  
  if(command == 'w') {
    forward();
    System.out.println("Forward");
  }
  
  if(command == 's') {
    backward();
    System.out.println("Backward");
  }
  
  if(command == 'z') {
    hover();
    System.out.println("Hover");
  }
  
  delay(50);
  System.out.printf("T: %d Y: %d P: %d R: %d\n\n", throttle, yaw, pitch, roll);
  sendSLIP();
}

//Get quad location

//Make decisision and run maneuver


//Lift - Off
void start() {
  pitch = 255;
  yaw = 0;
  throttle = 130;
  roll = 0;
}

//Kill flight
void stop() {
  pitch = 255;
  yaw = 0;
  throttle = 0;
  roll = 0;
}

//Hover (Default State)
void hover() {
  yaw = 130;
  roll = 130;
  pitch = 130;
}

//Raise
void raise() {
  if(throttle <= 250) {
    throttle += 5;
  }
}

//Lower
void lower() {
  if(throttle >= 5) {
    throttle -= 5;
  }
}

//Forward
void forward() {
  if(pitch >= 5) {
    pitch -= 5;
  }
}

//Backwards
void backward() {
  if(pitch <= 250) {
    pitch += 5;
  }
}


//Left
void rollLeft() {
  if(roll >= 5) {
    roll -= 5;
  }
  
}

//Right
void rollRight() {
  if(roll <= 250) {
    roll += 5;
  }
}


//Rotate left
void rotateLeft() {
  if(yaw >= 5) {
    yaw -= 5;
  }
}

//Rotate right
void rotateRight() {
  if(yaw <= 250) {
    yaw += 5;
  }
}

//Sends commands over serial using SLIP
void sendSLIP() {
  bytes[0] = (byte) throttle;
  bytes[1] = (byte) yaw;
  bytes[2] = (byte) pitch;
  bytes[3] = (byte) yaw;
  myPort.write(SLIP_END);
  for(int i=0; i<bytes.length; i++) {
     if ( bytes[i] == SLIP_END ) {
       myPort.write(SLIP_ESC);
       myPort.write(SLIP_ESC_END);
     } else if ( bytes[i] == SLIP_ESC ) { 
       myPort.write(SLIP_ESC);
       myPort.write(SLIP_ESC_ESC);
     } else {
       myPort.write(bytes[i]);
     }
  }
  myPort.write(SLIP_END);
}