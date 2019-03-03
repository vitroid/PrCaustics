//Caustic simulation by Masakazu Matsumoto
//2019-02-23
import processing.sound.*;
Amplitude amp;
AudioIn in;

Membrane memb;
int pixelsize=12;

void setup() {
  fullScreen(P2D);
  //size(1440, 800, P2D);
  orientation(LANDSCAPE);
  
  memb = new Membrane(width/pixelsize, height/pixelsize, 120.0);
  memb.gauss(0.5, 0.5, 0.1, 0.2);
  
   // Create an Input stream which is routed into the Amplitude analyzer
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
} 

int raining = 0; //rain levels; 0, 1, 3, 7, 15
int dead = 0;  //dead period when key input is ignored.
float accum;


void draw () {
  //println(amp.analyze());
  background(0,120,200);
  //background(0);
  fill(255,255,255,50);
  //fill(255,255,255);
  noStroke();
  //memb.draw(pixelsize);
  memb.progress(0.4);
  memb.progress(0.4);
  memb.photons(pixelsize);
  memb.damping(1.0-0.007);
  if (mousePressed){
    float x = float(mouseX) / width;
    float y = float(mouseY) / height;
    memb.gauss(x,y,0.05,0.05);
  }
  if (raining > 0){
    if (random(1) < 0.01*raining){
      memb.gauss(random(1), random(1), 0.05, 0.1);
    }
  }

  float loudness = amp.analyze();
  accum += loudness*0.6;
  if (accum > 1.0){
    memb.gauss(random(1), random(1), 0.05, 0.2);
    accum -= 1;
  }
  memb.thrumping(loudness*0.05);
  if (keyPressed){
    if (key == 'l'){
      memb.xslanting(0.001);
    }else if (key == 'a'){
      memb.xslanting(-0.001);
    }else if (key == ' '){
      memb.thrumping(0.01);
    }else if ((key == 'r')&&(dead<0)){
      raining += raining + 1; 
      if (raining > 16){
        raining = 0;
      }
      dead = 20;
    }
  }

  
  fill(255);
  textSize(16);
  text(width + "x" + height, 150, 20);
  text("Frame rate: " + int(frameRate), 10, 20);
  text("rain: " + int(raining), 10, 40);
  dead -= 1;
}


  