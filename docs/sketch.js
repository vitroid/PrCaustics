// -*- p5.js -*-
//Caustic simulation by Masakazu Matsumoto
//2019-02-23
//import p5.sound.*;
let ain;


function makeArray(w, h, val) {
  var arr = [];
  for(let i = 0; i < w; i++) {
      arr[i] = [];
      for(let j = 0; j < h; j++) {
          arr[i][j] = val;
      }
  }
  return arr;
}


class Membrane {
  // let width, height;
  // float[][] z, v;
  // let k;
  // let mass;
  // let depth;
  // let dotsize=2;

  constructor(width_, height_, depth_) { //two ends are fixed
    this.width = width_;
    this.height = height_;
    this.depth = depth_;
    this.z = this.width;
    this.z = makeArray(this.width, this.height, 0); //displacement
    this.v = makeArray(this.width, this.height, 0); //velocity
    this.k = 1.0; //spring constant
    this.mass = 1.0;
  }
  gauss(cx, cy, cr, dz){
    let x = int(cx*(this.width-2))+1;
    let y = int(cy*(this.height-2))+1;
    let r = int(cr*this.width);
    for(let dx=-r; dx <= +r; dx++){
      let ix = x+dx;
      if ( ( 0 < ix ) && (ix < this.width-1 ) ){ 
        for(let dy=-r; dy <= +r; dy++){
          let iy=y+dy;
          if ( ( 0 < iy ) && (iy < this.height-1 ) ){
            let right = dz*exp(-(dx*dx+dy*dy)*4/(r*r));
            this.z[ix][iy] += right;
          }
        }
      }
    }
  }
  draw(zoom){
    for(let x=0; x<this.width; x++ ){
      for(let y=0; y<this.height; y++ ){
        let r = int(this.z[x][y]*zoom/2);
        if(r>0){
          rect(x*zoom-r,y*zoom-r,r*2,r*2);
        }
      }
    }
  }
  progress(dt){
    for(let x=1;x<this.width-1;x++){
      for(let y=1;y<this.height-1;y++){
        this.z[x][y] += this.v[x][y]*dt*0.5; //velocity verlet, first half
      }
    }
    for(let x=1;x<this.width-1;x++){
      for(let y=1;y<this.height-1;y++){
        let F = this.k*(this.z[x+1][y] + this.z[x-1][y] + this.z[x][y-1] + this.z[x][y+1] - 4.0*this.z[x][y]);
        let a = F/this.mass;
        this.v[x][y] += a*dt;
      }
    }
    for(let x=1;x<this.width-1;x++){
      for(let y=1;y<this.height-1;y++){
        this.z[x][y] += this.v[x][y]*dt*0.5; //velocity verlet, latter half
      }
    }
  }
  energy_conservation_test(){
    let Ek = 0;
    for(let x=1;x<this.width-1;x++){
      for(let y=1;y<this.height-1;y++){
        Ek += this.mass*this.v[x][y]*this.v[x][y]*0.5;
      }
    }
    let Ep = 0;
    for(let x=0;x<this.width-1;x++){
      for(let y=1;y<this.height-1;y++){
        let dz = this.z[x+1][y]-this.z[x][y];
        Ep += this.k*dz*dz*0.5;
      }
    }
    for(let x=1;x<this.width-1;x++){
      for(let y=0;y<this.height-1;y++){
        let dz = this.z[x][y+1]-this.z[x][y];
        Ep += this.k*dz*dz*0.5;
      }
    }
    println(Ep,Ek,Ep+Ek);
  }
  photons(zoom){
    let r = zoom / 2;
    let d = this.depth*zoom;
    for(let x=0;x<this.width-1;x++){
      for(let y=0;y<this.height-1;y++){
        let gradx = this.z[x+1][y]-this.z[x][y];
        let grady = this.z[x][y+1]-this.z[x][y];
        rect(x*zoom-int(gradx*d)-r,
             y*zoom-int(grady*d)-r,2*r,2*r);
      }
    }
    
  }
  damping(ratio){
    for(let x=1;x<this.width-1;x++){
      for(let y=1;y<this.height-1;y++){
        this.v[x][y] *= ratio;
      }
    }
  }    
  xslanting(ratio){
    let wh = this.width / 2;
    for(let x=1;x<this.width-1;x++){
      let fx = ratio*(x - wh)/wh;
      for(let y=1;y<this.height-1;y++){
        this.v[x][y] += fx;
      }
    }
  }    
  thrumping(ratio){
    for(let x=1;x<this.width-1;x++){
      this.v[x][1] += ratio;
      this.v[x][this.height-2] += ratio;
    }
    for(let y=1;y<this.height-1;y++){
      this.v[1][y] += ratio;
      this.v[this.width-2][y] += ratio;
    }
  }    
}


// Membrane memb;
let pixelsize=8;

function setup() {
    /* for execution on the web browser*/
    createCanvas(1440, 800);

    /*for Processing.js standalone IDE
    fullScreen(P2D);
    orientation(LANDSCAPE);
    */
  
  memb = new Membrane(width/pixelsize, height/pixelsize, 180.0);
  memb.gauss(0.5, 0.5, 0.1, 0.2);
  
  ain = new p5.AudioIn();
  ain.start();
} 

let raining = 0; //rain levels; 0, 1, 3, 7, 15
let dead = 0;  //dead period when key input is ignored.
let accum;


function draw () {
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
  if (mouseIsPressed){
    let x = float(mouseX) / width;
    let y = float(mouseY) / height;
    memb.gauss(x,y,0.05,0.05);
  }
  if (raining > 0){
    if (random(1) < 0.01*raining){
      memb.gauss(random(1), random(1), 0.05, 0.1);
    }
  }

  // let loudness = amp.getLevel();
  let loudness = ain.getLevel();
  accum += loudness*0.6;
  if (accum > 1.0){
    memb.gauss(random(1), random(1), 0.05, 0.2);
    accum -= 1;
  }
  memb.thrumping(loudness*0.05);
  if (keyIsPressed){
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
  text("Frame rate: " + int(frameRate()), 10, 20);
  text("rain: " + int(raining), 10, 40);
  dead -= 1;
}


  
