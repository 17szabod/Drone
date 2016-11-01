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

//Click camera window
void keyPressed() {
  
  if(key == 'a') {
    rotateLeft();
    System.out.println("Rotate Left");
    delay(50);
    hover();
  }
  
  if(key == 'd') {
    rotateRight();
    System.out.println("Rotate Right");
    delay(50);
    hover();
  }
  
  if(key == 'q') {
    rollLeft();
    System.out.println("Roll Left");
    delay(50);
    hover();
  }
  
  if(key == 'e') {
    rollRight();
    System.out.println("Roll Right");
    delay(50);
    hover();
  }
  
  if(key == 'i') {
    raise();
    System.out.println("Raise");
    delay(50);
    hover();
  }
  
  if(key == 'k') {
    lower();
    System.out.println("Lower");
    delay(50);
    hover();
  }
  
  if(key == 'w') {
    forward();
    System.out.println("Forward");
    delay(50);
    hover();
  }
  
  if(key == 's') {
    backward();
    System.out.println("Backward");
    delay(50);
    hover();
  }
}

void keyReleased() {
    if(key == ' ') {
    startStop();
    System.out.println("Liftoff");
    delay(500);
    hover();
  }
}

//Get quad location

//Make decisision and run maneuver

//Lift off / Kill flight
void startStop() {
  yaw = 0;
  throttle = 0;
  roll = 0;
}

//Hover (Default State)
void hover() {
  yaw = 128;
  roll = 128;
  pitch = 128;
  throttle = 0;
}

//Raise
void raise() {
  if(throttle <= 250) {
    throttle+= 5;
  }
}

//Lower
void lower() {
  if(throttle >= 5) {
    throttle-= 5;
  }
}

//Forward
void forward() {
  pitch = 192;
}

//Backwards
void backward() {
  pitch = 64;
}


//Left
void rollLeft() {
  roll = 64;
  
}

//Right
void rollRight() {
  roll = 192;
}


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