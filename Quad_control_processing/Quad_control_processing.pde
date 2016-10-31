import processing.video.*;
import processing.serial.*;

// Serial communication
Serial myPort;
final byte SLIP_END = (byte)0xC0;
final byte SLIP_ESC = (byte)0xDB;
final byte SLIP_ESC_END = (byte)0xDC;
final byte SLIP_ESC_ESC = (byte)0xDD;

//Camera 
Capture cam;
float r, g, b;

//Controls
int throttle, yaw, pitch, roll;

void setup() {
  yaw = pitch = roll = 128;
  throttle = 0;
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
   
  //String portName = Serial.list()[1];
  //System.out.println(portName);
  //myPort = new Serial(this, portName, 9600);
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

void keyPressed() {
  if(key == 'a') {
    rotateLeft();
    System.out.println("Rotate Left");
    //delay(50);
    defaultRotate();
  }
  if(key == 'd') {
    rotateRight();
    System.out.println("Rotate Right");
    //delay(50);
    defaultRotate();
  }
}

//Get quad location

//Make decisision and run maneuver


//Raise

//Lower

//Left

//Right


//Rotate left
void rotateLeft() {
  yaw = 64;
  //sendSLIP(Serial myPort, byte[] bytes)
}

//Rotate right
void rotateRight() {
  yaw = 192;
}

//Default rotate state
void defaultRotate() {
  yaw = 128;
}

//Sends commands over serial using SLIP
void sendSLIP(Serial myPort, byte[] bytes) {
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