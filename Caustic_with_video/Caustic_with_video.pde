//Caustic simulation by Masakazu Matsumoto
//2019-02-23
import processing.video.*;

Membrane memb;
int pixelsize=16;
Capture cam;

void setup() {
  size(640,480, P2D);
  orientation(LANDSCAPE);
    
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
  memb = new Membrane(width/pixelsize, height/pixelsize, 180.0,
  cam, pixelsize);
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


  