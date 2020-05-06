class Membrane {
  int width, height;
  float[][] z, v;
  float k;
  float mass;
  float depth;
  
  PImage baseimage;
  int pixelsize;

  Membrane(int width_, int height_, float depth_, PImage baseimage_, int pixelsize_) { //two ends are fixed
    width  = width_;
    height = height_;
    depth  = depth_;
    baseimage = baseimage_;
    pixelsize = pixelsize_;
    
    z = new float[width][height]; //displacement
    v = new float[width][height]; //velocity
    k = 1.0; //spring constant
    mass = 1.0;
  }
  void gauss(float cx, float cy, float cr, float dz){
    int x = int(cx*width);
    int y = int(cy*height);
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
  void photons(){
    float d = depth*pixelsize;
    for(int x=0;x<width-1;x++){
      for(int y=0;y<height-1;y++){
        float gradx = z[x+1][y]-z[x][y];
        float grady = z[x][y+1]-z[x][y];
        blend(baseimage,x*pixelsize,y*pixelsize,pixelsize,pixelsize,
        x*pixelsize-int(gradx*d),
        y*pixelsize-int(grady*d),pixelsize,pixelsize,ADD);
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
}