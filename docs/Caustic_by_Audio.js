// -*- javascript -*-
//Caustic simulation by Masakazu Matsumoto
//2019-02-23
import processing.sound.*;
AudioIn ain;
//Amplitude amp;


class Membrane {
  int width, height;
  float[][] z, v;
  float k;
  float mass;
  float depth;
  int dotsize=2;

  Membrane(int width_, int height_, float depth_) { //two ends are fixed
    width = width_;
    height = height_;
    depth = depth_;
    z = new float[width][height]; //displacement
    v = new float[width][height]; //velocity
    k = 1.0; //spring constant
    mass = 1.0;
  }
  void gauss(float cx, float cy, float cr, float dz){
    int x = int(cx*(width-2))+1;
    int y = int(cy*(height-2))+1;
    int r = int(cr*width);
    for(int dx=-r; dx <= +r; dx++){
      int ix = x+dx;
      if ( ( 0 < ix ) && (ix < width-1 ) ){ 
        for(int dy=-r; dy <= +r; dy++){
          int iy=y+dy;
          if ( ( 0 < iy ) && (iy < height-1 ) ){
            z[ix][iy] += dz*exp(-float(dx*dx+dy*dy)*4/(r*r));
          }
        }
      }
    }
  }
  void draw(float zoom){
    for(int x=0; x<width; x++ ){
      for(int y=0; y<height; y++ ){
        int r = int(z[x][y]*zoom/2);
        if(r>0){
          rect(x*zoom-r,y*zoom-r,r*2,r*2);
        }
      }
    }
  }
  void progress(float dt){
    for(int x=1;x<width-1;x++){
      for(int y=1;y<height-1;y++){
        z[x][y] += v[x][y]*dt*0.5; //velocity verlet, first half
      }
    }
    for(int x=1;x<width-1;x++){
      for(int y=1;y<height-1;y++){
        float F = k*(z[x+1][y] + z[x-1][y] + z[x][y-1] + z[x][y+1] - 4.0*z[x][y]);
        float a = F/mass;
        v[x][y] += a*dt;
      }
    }
    for(int x=1;x<width-1;x++){
      for(int y=1;y<height-1;y++){
        z[x][y] += v[x][y]*dt*0.5; //velocity verlet, latter half
      }
    }
  }
  void energy_conservation_test(){
    float Ek = 0;
    for(int x=1;x<width-1;x++){
      for(int y=1;y<height-1;y++){
        Ek += mass*v[x][y]*v[x][y]*0.5;
      }
    }
    float Ep = 0;
    for(int x=0;x<width-1;x++){
      for(int y=1;y<height-1;y++){
        float dz = z[x+1][y]-z[x][y];
        Ep += k*dz*dz*0.5;
      }
    }
    for(int x=1;x<width-1;x++){
      for(int y=0;y<height-1;y++){
        float dz = z[x][y+1]-z[x][y];
        Ep += k*dz*dz*0.5;
      }
    }
    println(Ep,Ek,Ep+Ek);
  }
  void photons(int zoom){
    float r = zoom / 2;
    float d = depth*zoom;
    for(int x=0;x<width-1;x++){
      for(int y=0;y<height-1;y++){
        float gradx = z[x+1][y]-z[x][y];
        float grady = z[x][y+1]-z[x][y];
        rect(x*zoom-int(gradx*d)-r,
             y*zoom-int(grady*d)-r,2*r,2*r);
      }
    }
    
  }
  void damping(float ratio){
    for(int x=1;x<width-1;x++){
      for(int y=1;y<height-1;y++){
        v[x][y] *= ratio;
      }
    }
  }    
  void xslanting(float ratio){
    int wh = width / 2;
    for(int x=1;x<width-1;x++){
      float fx = ratio*(x - wh)/wh;
      for(int y=1;y<height-1;y++){
        v[x][y] += fx;
      }
    }
  }    
  void thrumping(float ratio){
    for(int x=1;x<width-1;x++){
      v[x][1] += ratio;
      v[x][height-2] += ratio;
    }
    for(int y=1;y<height-1;y++){
      v[1][y] += ratio;
      v[width-2][y] += ratio;
    }
  }    
}


Membrane memb;
int pixelsize=8;

void setup() {
    /* for execution on the web browser*/
    size(1440, 800, P2D);

    /*for Processing.js standalone IDE
    fullScreen(P2D);
    orientation(LANDSCAPE);
    */
  
  memb = new Membrane(width/pixelsize, height/pixelsize, 180.0);
  memb.gauss(0.5, 0.5, 0.1, 0.2);
  
   // Create an Input stream which is routed into the Amplitude analyzer
  //amp = new Amplitude(this);
  ain = new AudioIn(this, 0);
  ain.start();
  //amp.input(ain);
} 

int raining = 0; //rain levels; 0, 1, 3, 7, 15
int dead = 0;  //dead period when key input is ignored.
float accum;


void draw () {
  //println(amp.analyze());
  //background(0,120,200);
  background(0);
  fill(255,255,255,50);
  //fill(255,255,255);
  noStroke();
  //memb.draw(pixelsize);
  memb.progress(0.4);
  memb.progress(0.4);
  memb.photons(pixelsize);
  memb.damping(1.0-0.009);
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

  // float loudness = amp.analyze();
  // accum += loudness*0.6;
  // if (accum > 1.0){
  //   memb.gauss(random(1), random(1), 0.05, 0.2);
  //   accum -= 1;
  // }
  // memb.thrumping(loudness*0.05);
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


  
