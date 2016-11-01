#define THROTTLE 6
#define YAW 9
#define PITCH 10
#define ROLL 11
#define SLIP_END 0xC0
#define SLIP_ESC 0xDB
#define SLIP_ESC_END 0xDC
#define SLIP_ESC_ESC 0xDD

uint8_t readIn[] = {0x00, 0x00,0x00,0x00};

void setup() {
  Serial.begin(9600);
  while ( ! Serial ) {}
  pinMode(THROTTLE, OUTPUT);
  pinMode(YAW, OUTPUT);
  pinMode(PITCH, OUTPUT);
  pinMode(ROLL, OUTPUT);
}

// Loops until a serial byte is available
uint8_t getNextSerialByte() {
  while ( true ) {
    if ( Serial.available() ) {
      return Serial.read();
    }
  }
}

// Implements SLIP to read in a given number of bytes into 
// a byte array 
// Returns: number of bytes read for error checking
uint8_t receiveSlip(uint8_t* bytes, int byteLength) {
	uint8_t incoming = 0;
	uint8_t done = 0;
	uint8_t count = 0;
	while ( incoming != SLIP_END ) {		//read until encounter END marker (assume start)
		incoming = getNextSerialByte();	
	}
	while ( ! done ) {
		incoming = getNextSerialByte();
		if ( incoming == SLIP_ESC ) {				// if its escape, read second byte
			incoming = getNextSerialByte();
			if ( incoming == SLIP_ESC_END ) {			// SLIP_ESC_END unescapes to SLIP_END
				if ( count < byteLength ) {
					bytes[count++] = SLIP_END;
				} else {
					count = 0;
					done = 1;
				}
			} else if ( incoming == SLIP_ESC_ESC ) {	// SLIP_ESC_ESC unescapes to SLIP_ESC
				if ( count < byteLength ) {
					bytes[count++] = SLIP_ESC;
				} else {
					count = 0;
					done = 1;
				}
			} else {
				count = 0;										// this is undefine so report error
				done = 1;										// and return
			}
		} else if ( incoming == SLIP_END ) {		// if its end marker
			if ( count > 0 ) {							// check to see if it is really the end
				done = 1;
			}	// otherwise first END was actually end of last packet not start of this one
		} else {
			if ( count < byteLength ) {
				bytes[count++] = incoming;					// its a normal data byte
			} else {
				count = 0;
				done = 1;
			}
		}
	}	// ! done
	
	return count;
}

// This method is no longer needed
uint32_t getNextSerial32() {
  uint32_t input = 0x00000000;
      receiveSlip(readIn, 4);
      input += readIn[0];
      input = input << 8;
      input += readIn[1];
      input = input << 8;
      input += readIn[2];
      input = input << 8;
      input += readIn[3];
      return input;
}

/* Calls the recieve slip function and sends the 
 * values that are read in to the different PWM outputs
 */
void getSendNextInput() {
  if(receiveSlip(readIn, 4) != 4) return;
  // Outputs are multiplied by .66 so that a voltage
  // output is never greater than the 3.3v the controller expects
  analogWrite(THROTTLE, readIn[0]*.66);
  analogWrite(YAW, readIn[1]*.66);
  analogWrite(PITCH, readIn[2]*.66);
  analogWrite(ROLL, readIn[3]*.66);
  //Serial.print(readIn[0]*.66);
  //Serial.print(", ");
  //Serial.print(readIn[1]*.66);
  //Serial.print(", ");
  //Serial.print(readIn2]*.66);
  //Serial.print(", ");
  //Serial.println(readIn[3]*.66);
}

void loop() {
  getSendNextInput(); // relplaces original code
  
  /* This is the original code where the inputs
   * were packed into a 32 bit uint and then unpacked
   * and sent to the controller.
  uint32_t input = getNextSerial32();
  //uint8_t throttle, yaw, pitch, roll;
  //throttle = (input & 0xff000000) >> 24;
  //roll = (input & 0x00ff0000) >> 16;
  //pitch = (input & 0x0000ff00) >> 8;
  //yaw = (input & 0x000000ff);
  analogWrite(THROTTLE, throttle*.66);
  analogWrite(YAW, yaw*.66);
  analogWrite(PITCH, pitch*.66);
  analogWrite(ROLL, roll*.66);
  //Serial.print(throttle);
  //Serial.print(", ");
  //Serial.print(yaw);
  //Serial.print(", ");
  //Serial.print(pitch);
  //Serial.print(", ");
  //Serial.println(roll);
  */
  
}
