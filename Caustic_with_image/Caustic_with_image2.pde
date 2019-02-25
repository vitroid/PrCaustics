//Caustic simulation by Masakazu Matsumoto
//2019-02-23

Membrane memb;
int pixelsize=16;
PImage baseimage;

void setup() {
  size(800,800, P2D);
  orientation(LANDSCAPE);
  
  
  baseimage = loadImage("andoh5gonB069.png");
  //PImage tile = baseimage.get(400,400,100,100);
  //set(100,100,tile);
  
  memb = new Membrane(width/pixelsize, height/pixelsize, 180.0,
  baseimage,pixelsize);
} 

void draw () {
  background(0);
  fill(255,255,255,100);
  noStroke();
  memb.progress(0.4);
  memb.photons();
  memb.damping(0.995);
  if (mousePressed){
    float x = float(mouseX) / width;
    float y = float(mouseY) / height;
    memb.gauss(x,y,0.04,0.02);
  }
  fill(255);
  textSize(16);
  text("Frame rate: " + int(frameRate), 10, 20);
  
}


  