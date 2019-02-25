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

void draw () {
  background(0,120,200);
  fill(255,255,255,100);
  noStroke();
  //memb.draw(pixelsize);
  memb.progress(0.4);
  memb.photons(pixelsize);
  memb.damping(0.993);
  if (mousePressed){
    float x = float(mouseX) / width;
    float y = float(mouseY) / height;
    memb.gauss(x,y,0.05,0.02);
  }
  if (keyPressed){
    if (key == 'l'){
      memb.xslanting(0.001);
    }else if (key == 'a'){
      memb.xslanting(-0.001);
    }else if (key == ' '){
      memb.thrumping(0.01);
    }
  }
  
  fill(255);
  textSize(16);
  text("Frame rate: " + int(frameRate), 10, 20);
  
}


  