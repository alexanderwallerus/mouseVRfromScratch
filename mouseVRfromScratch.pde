//Code by Alexander Wallerus
//MIT license

import processing.serial.*;
Serial port;
boolean answered = false;
String answer = "";
int target = 100;
PImage wallText;
PImage endText;
PShape[] segments = new PShape[10];
PShape end;
long absMousePos = 0;
boolean corridorMode = true;
float currentPos = 0;
String sendStr = "continue\n";
boolean blackOut = false;
long blackOutCounter = 0;

void setup() {
  //fullScreen(P3D);
  fullScreen(P3D, SPAN);
  printArray(Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  port.bufferUntil('\n');
  background(0);
  wallText = loadImage("data/wallTexture.png");
  endText = loadImage("data/targetTexture.png");
  noStroke();
  int xOff = width/5;
  int yOff = height/3;
  int baseZ = 600;
  int zShift = -1200;
  textureMode(NORMAL);
  for(int i = 0; i<segments.length; i++){
    PImage tex = wallText.copy();
    tex.loadPixels();
    float randR = random(-100, 100);
    float randG = random(-100, 100);
    float randB = random(-100, 100);
    for(int j=0; j < tex.pixels.length; j++){
      float r = red(tex.pixels[j]) + randR;
      r = constrain(r, 0, 255);
      float g = green(tex.pixels[j]) + randG;
      g = constrain(g, 0, 255);
      float b = blue(tex.pixels[j]) + randB;
      b = constrain(b, 0, 255);
      tex.pixels[j] = color(r, g, b);
    }
    tex.updatePixels();
    segments[i] = createShape();
    segments[i].beginShape(QUADS);
      segments[i].texture(tex);
      segments[i].vertex(-xOff, yOff, 0-zShift, 0, 1); 
      segments[i].vertex(-xOff, yOff, -baseZ-zShift, 1, 1); 
      segments[i].vertex(-xOff, -yOff, -baseZ-zShift, 1, 0); 
      segments[i].vertex(-xOff, -yOff, 0-zShift, 0, 0);
      
      segments[i].vertex(-xOff, -yOff, -baseZ-zShift, 0, 0); 
      segments[i].vertex(-xOff, -yOff, 0-zShift, 0, 1);
      segments[i].vertex(xOff, -yOff, 0-zShift, 1, 1);
      segments[i].vertex(xOff, -yOff, -baseZ-zShift, 1, 0); 
  
      segments[i].vertex(xOff, yOff, 0-zShift, 0, 1); 
      segments[i].vertex(xOff, yOff, -baseZ-zShift, 1, 1); 
      segments[i].vertex(xOff, -yOff, -baseZ-zShift, 1, 0); 
      segments[i].vertex(xOff, -yOff, 0-zShift, 0, 0);
      
      segments[i].vertex(-xOff, yOff, -baseZ-zShift, 0, 0); 
      segments[i].vertex(-xOff, yOff, 0-zShift, 0, 1);
      segments[i].vertex(xOff, yOff, 0-zShift, 1, 1);
      segments[i].vertex(xOff, yOff, -baseZ-zShift, 1, 0); 
    segments[i].endShape(CLOSE);
    zShift+= 600;
  }
  end = createShape();
  end.beginShape(QUADS);
    end.texture(endText);
    end.vertex(-xOff, -yOff, -4800, 0, 0);
    end.vertex(xOff, -yOff, -4800, 1, 0);
    end.vertex(xOff, yOff, -4800, 1, 1);
    end.vertex(-xOff, yOff, -4800, 0, 1);
  end.endShape(CLOSE);
}

void serialEvent(Serial port) {
  String input = port.readString();
  if (input != null) {
    answered = true;
    answer = trim(input);
    absMousePos += int(answer);
  }
}

void draw() {
  if (frameCount == 100) {
    port.write("initiate\n");
  }
  if (answered) {
    answered = false;
    port.write(sendStr);
    sendStr = "continue\n";
  }
  background(0);
  println(absMousePos);
  currentPos = lerp(currentPos, absMousePos, 0.3);
  
  if(absMousePos > 53){
    absMousePos = 0;
    blackOut = true;
    blackOutCounter = millis();
    sendStr = "giveReward\n";
  }
  
  if(blackOut){
    absMousePos = 0;
    if(millis() - blackOutCounter > 2000){
      blackOut = false;
    }
  } else {
    translate(width/2, height/2, 0);
    if(corridorMode){
      float largeMousePos = currentPos * 100;
      pushMatrix();
        ambientLight(255, 255, 255);
        //directionalLight(255, 255, 255, 1, 1, -1);
        float camZ = (height/2)/tan(PI/6);
        //camera(0, 0, camZ-600, 0, 0, 0, 0, 1, 0); 
        camera(0, 0, camZ-largeMousePos, 0, 0, -4800, 0, 1, 0);   //-800
        perspective(PI*0.7, width/height, 0.0001, 5000);//map(mouseX, 0, width, 0, PI)
        ambient(255);
        shape(segments[0], 0, 0);
        for(PShape s : segments){
          shape(s, 0, 0);
        }
        shape(end, 0, 0);
      popMatrix();
    } else {
      float distance = 0.7*width;
      pushMatrix();
        translate(0, 0, 300);
        rectMode(CENTER);  ellipseMode(CENTER);
        noStroke();
        fill(255, 0, 0);
        rect(-distance, 0, 1000, 1000);
        fill(0, 255, 0);
        pushMatrix();
          translate(distance, 0);
          triangle(0, -500, 500, 500, -500, 500);
        popMatrix();
        float circPos = map(currentPos, 0, 54, -distance, distance);
        fill(0, 0, 255);
        ellipse(circPos, 0, 800, 800);  
      popMatrix();
    }
  }
}

void keyPressed(){
  if(key == 'm'){
    corridorMode = !corridorMode;
  }
}
