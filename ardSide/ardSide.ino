volatile boolean turnDetected = false;
volatile boolean rotationDirection;

const int PinCLK=2;
const int PinDT=3;
const int PinSW=4;

int rotPos = 0;
int prevPos;
int stepsToTake;

long delta = 0;
long oldRotPos =0;

const int lightPin = 40;
unsigned long rewardTime = 0;
boolean rewarding = false;
String command;

// Interrupt routine runs if CLK goes from HIGH to LOW
void isr ()  {
  delay(5);  // delay for Debouncing
  if (digitalRead(PinCLK))
    rotationDirection= digitalRead(PinDT);
  else
    rotationDirection= !digitalRead(PinDT);
  turnDetected = true;
}


void setup() {
  Serial.begin(9600);
  pinMode(lightPin, OUTPUT);

  pinMode(PinCLK,INPUT);
  pinMode(PinDT,INPUT);  
  pinMode(PinSW,INPUT);
  digitalWrite(PinSW, HIGH); // Pull-Up resistor for switch
  attachInterrupt (0,isr,FALLING);
  //interrupt 0 always connected to pin 2 on Arduino UNO
}

void loop() {
  //this block is not really needed here
  if(!(digitalRead(PinSW))){  //check if button is pressed
    Serial.println("button is pressed");
  }

  if(turnDetected){
    prevPos = rotPos; //Save previous position in variable
    if(rotationDirection){
      rotPos=rotPos-1; //decrase Position by 1
    }else{
      rotPos=rotPos+1; //increase Position by 1
    } 
    turnDetected = false;//don't repeat ifloop until new rotation
  }

  if(Serial.available()>0){
    command = Serial.readStringUntil('\n');
    delta = rotPos - oldRotPos;
    oldRotPos = rotPos;
    delay(1);
    Serial.println(delta);
  }

  if(command.equals("giveReward")){
    rewarding = true;
    rewardTime = millis();
  }
    
  if(rewarding){
    digitalWrite(lightPin, HIGH);
    if(millis() - rewardTime > 2000){
      rewarding = false;  
    }
  } else {
    digitalWrite(lightPin, LOW);
  }
}
