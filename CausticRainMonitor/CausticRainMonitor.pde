//Caustic simulation by Masakazu Matsumoto
//2019-02-23
import processing.sound.*;
Amplitude amp;
AudioIn in;

Membrane memb;
int pixelsize=8;

void setup() {
  fullScreen(P2D);
  //size(1440, 800, P2D);
  orientation(LANDSCAPE);
  
  memb = new Membrane(width/pixelsize, height/pixelsize, 300.0);
  memb.gauss(0.5, 0.5, 0.1, 0.2);
  
   // Create an Input stream which is routed into the Amplitude analyzer
  amp = new Amplitude(this);
  in = new AudioIn(this, 0);
  in.start();
  amp.input(in);
} 

String yappid = "dj00aiZpPUxORHdoRUdINmRMeCZzPWNvbnN1bWVyc2VjcmV0Jng9N2I-";
String okayama = "133.9205568,34.6884276";
String url    = "https://map.yahooapis.jp/weather/V1/place?coordinates="+okayama+"&appid="+yappid;

float rainfall = 0; //rain levels; 0, 1, 3, 7, 15
float accum;
float lastm = 0;
float Pi=3.14159;


void draw () {
  //println(amp.analyze());
  float m = minute();
  float h = hour();
  float sec = second();
  float now = (sec/60+m)/60+h;
  
  //sky color
  float phase=0;
  if ((4<=now)&&(now<6)){
    phase = (now-4.)/2;
  }
  else if ((6<=now)&&(now<18)){
    phase = 1;
  }
  else if ((18<=now)&&(now<20)){
    phase =(20-now)/2;
  }
  float red = (150*(1-phase) + 0   * phase) * phase;
  float gre = (0  *(1-phase) + 120 * phase) * phase;
  float blu = (150*(1-phase) + 200 * phase) * phase;
  background(red,gre,blu);
    
  fill(255,255,255,50);
  //fill(255,255,255);
  noStroke();
  //memb.draw(pixelsize);
  memb.progress(0.4);
  memb.progress(0.4);
  memb.photons(pixelsize);
  memb.damping(1.0-0.005);
  // weather check
  if ( m != lastm ){
    lastm = m;
    XML xml = loadXML(url);
    rainfall = xml.getFloat("Rainfall");
    println(rainfall);
  }  
  if (mousePressed){
    float x = float(mouseX) / width;
    float y = float(mouseY) / height;
    memb.gauss(x,y,0.05,0.05);
  }
  if (random(1) < 0.01*rainfall){
      memb.gauss(random(1), random(1), 0.05, 0.2);
  }
  float loudness = amp.analyze();
  accum += loudness*0.6;
  if (accum > 1.0){
    memb.gauss(random(1), random(1), 0.05, 0.2);
    accum -= 1;
  }
  memb.thrumping(loudness*0.05);
  if (keyPressed){
    if (key == ' '){
      memb.thrumping(0.01);
    }
  }

  fill(255);
  textSize(40);
  //text(width + "x" + height + "." + int(frameRate), 300, 90);
  String s=String.format("%02d:%02d %.2f mm/h", int(h), int(m), rainfall);
  //text("" + int(h) + ":" + int(m) + " " + rainfall + " mm/h", 300, 50);
  text(s, 300, 50);
}


  
