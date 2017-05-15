import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 20; //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int begTime = 0;
int coloredI = 0;
boolean heldDown = false;
boolean userDone = false;
int countDownTimerWait = 0;

void setup() {
  size(600, 600); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);

  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;
  int curTime = millis();
  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke
  
  if (light<proxSensorThreshold){
    heldDown = true; 
  }
  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }
  
  Target t = targets.get(index);
  
  if (light>proxSensorThreshold) {
    
    if (curTime - 1000 > begTime){
      coloredI ++;
      if (coloredI > 3){
        coloredI = 0;
      }
      begTime = curTime;
    }
  
  // if (light>proxSensorThreshold) {
    for (int i=0; i<4; i++){
      if (targets.get(index).target==i){
        fill(255, 0, 0);
        ellipse(300, i*150+100, 120, 100);
      }
      if (coloredI == i)
        fill(0, 255, 0);
      else
        fill(180, 180, 180);
      ellipse(300, i*150+100, 100, 100);
    }
  }
  
  if (light<=proxSensorThreshold) {
    if (t.action == 0 && cursorX < 200) {
      fill(255);
    } else if (t.action == 0) {
      fill(180);
    } else {
      fill(120);
    }
    rect(100, 300, 200, 600);
    if (t.action == 1 && cursorX > 400) {
      fill(255);
    } else if (t.action == 1) {
      fill(180);
    } else {
      fill(120);
    }
    rect(500, 300, 200, 600);
  }
  
  //if (light>proxSensorThreshold)
  //  fill(180, 0, 0);
  //else
  //  fill(255, 0, 0);
  if (light<=proxSensorThreshold) {
    fill(255, 0, 0);
    ellipse(cursorX, cursorY, 50, 50);
  }

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  text("Target #" + (targets.get(index).target)+1, width/2, 100);
/*
  if (targets.get(index).action==0)
    text("UP", width/2, 150);
  else
    text("DOWN", width/2, 150);
*/
  
  //if light is greater than threshold and heldDown = true, check if colored I equals t.target
  if (light>proxSensorThreshold && heldDown == true && (cursorX < 200 || cursorX > 400)){
    // print("check!");
    text("letgo",90,90);
    int zI = -1;
    if (cursorX < 200) {
      zI = 0;
    } else if (cursorX > 400) {
      zI = 1;
    }
    if (coloredI == t.target && zI == t.action){
      //next trial
      text("Next Trial",170,170);
      trialIndex++;
    } else { 
      text("Prev Trial",170,170);
      if (trialIndex > 0) trialIndex--;
      //previous trial
    }
    heldDown = false;
  }
}


void onAccelerometerEvent(float x, float y, float z)
{
  //int index = trialIndex;

  //if (userDone || index>=targets.size())
  //  return;

  //if (light<=proxThreshold) //only update cursor, if light is low
  //{
    cursorX = 300+x*40; //cented to window and scaled
    cursorY = 300-y*40; //cented to window and scaled
  //}

  //Target t = targets.get(index);

  //if (t==null)
  //  return;
 
  //if (light<=proxSensorThreshold && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  //{
  //  if (hitTest()==t.target)//check if it is the right target
  //  {
  //    //println(z-9.8); use this to check z output!
  //    if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
  //    {
  //      println("Right target, right z direction!");
  //      trialIndex++; //next trial!
  //    } else
  //    {
  //      if (trialIndex>0)
  //        trialIndex--; //move back one trial as penalty!
  //      println("right target, WRONG z direction!");
  //    }
  //    countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  //  } 
  //} else if (light<=proxSensorThreshold && countDownTimerWait<0 && hitTest()!=t.target)
  //{ 
  //  println("wrong round 1 action!"); 

  //  if (trialIndex>0)
  //    trialIndex--; //move back one trial as penalty!

  //  countDownTimerWait=30; //wait roughly 0.5 sec before allowing next trial
  //}
}


int hitTest() 
{
  for (int i=0; i<4; i++)
    if (dist(300, i*150+100, cursorX, cursorY)<100)
      return i;

  return -1;
}


void onLightEvent(float v) //this just updates the light value
{
  light = v;
}