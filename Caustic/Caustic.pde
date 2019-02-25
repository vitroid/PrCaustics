//Caustic simulation by Masakazu Matsumoto
//2019-02-23

Membrane memb;
int pixelsize=8;

void setup() {
  size(1440, 800, P2D);
  orientation(LANDSCAPE);
  
  memb = new Membrane(width/pixelsize, height/pixelsize, 180.0);
  memb.gauss(0.5, 0.5, 0.1, 0.2);
} 

boolean raining = false;
int ns = 0;

void draw () {
  background(0,120,200);
  fill(255,255,255,100);
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
  if (raining){
    if (random(1) < 0.05){
      memb.gauss(random(1), random(1), 0.05, 0.2);
    }
  }
  if (keyPressed){
    if (key == 'l'){
      memb.xslanting(0.001);
    }else if (key == 'a'){
      memb.xslanting(-0.001);
    }else if (key == ' '){
      memb.thrumping(0.01);
    }else if ((key == 'r')&&(ns<0)){
      raining = ! raining;
      ns = 100;
    }
  }
  
  fill(255);
  textSize(16);
  text("Frame rate: " + int(frameRate), 10, 20);
  if ( raining ){
    text("raining...", 10, 40);
  }
  ns -= 1;
}


  