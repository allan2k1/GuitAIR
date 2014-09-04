/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import ddf.minim.*;


SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
PVector com = new PVector();                                   
PVector com2d = new PVector();       

float distancia_mao_corpo;
float distancia_mao_perna;
float distancia_mao_cabeca;
float distancia_mao_direita_cabeca;

boolean palhetada = false;

boolean aux = false;


String nota = "";

Minim minim;
AudioPlayer G, A, D;

void setup()
{
  size(640,480);
  
  context = new SimpleOpenNI(this);
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
   
  // enable skeleton generation for all joints
  context.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth(); 
 
   // set the sound
  minim = new Minim(this);
  D = minim.loadFile("D.mp3");
  A = minim.loadFile("A.mp3");
  G = minim.loadFile("G.mp3");
 
}

void draw()
{
  // update the cam
  context.update();
  
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(),0,0);
  
  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);
      getPoints(userList[i]);
    }      
      
    // draw the center of mass
    if(context.getCoM(userList[i],com))
    {
      context.convertRealWorldToProjective(com,com2d);
      stroke(100,255,0);
      strokeWeight(1);
      beginShape(LINES);
        vertex(com2d.x,com2d.y - 5);
        vertex(com2d.x,com2d.y + 5);

        vertex(com2d.x - 5,com2d.y);
        vertex(com2d.x + 5,com2d.y);
      endShape();
      
      fill(0,255,100);
      text(Integer.toString(userList[i]),com2d.x,com2d.y);
    }
  }    
  
  if(distancia_mao_cabeca > 500 && distancia_mao_perna > 350){
    
      if (D.isPlaying() == true) {
          //do nothing
      }
      else {
          if (palhetada && distancia_mao_corpo> 350 && distancia_mao_corpo< 490) {
              G.pause();
              A.pause();
              D.play(1);
              println("Acorde de Lá");
              nota = "Lá";
              D.rewind();
              palhetada = false;
          }
      }
      
      if (A.isPlaying() == true) {
          //do nothing
      }
      else {
          if (palhetada && distancia_mao_corpo> 500 && distancia_mao_corpo< 640){
              G.pause();
              D.pause();
              A.play(1);
              println("Acorde de Sol");
              nota = "Sol";
              A.rewind();
              palhetada = false;
          }
      }
 
 
      if (G.isPlaying() == true) {
          //do nothing
      }
      else {
          if (palhetada && distancia_mao_corpo> 650 && distancia_mao_corpo< 800){
              A.pause();
              D.pause();
              G.play(1);
              println("Acorde de Fá");
              nota = "Fá";
              G.rewind();
              palhetada = false;
          }
      }
  }
  
}

void getPoints(int userId){
PVector maoEsquerda = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,maoEsquerda);
  
  PVector maoDireita = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,maoDireita);
  
  PVector tronco = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO,tronco);
  
  PVector cabeca = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD,cabeca);
  
  PVector pernaEsquerda = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_KNEE,pernaEsquerda);
  
  distancia_mao_corpo= tronco.dist(maoEsquerda);
  distancia_mao_cabeca = cabeca.dist(maoEsquerda);
  distancia_mao_perna = pernaEsquerda.dist(maoEsquerda);  
  distancia_mao_direita_cabeca = maoDireita.dist(cabeca);
  
  pushMatrix();
  text("Distância: " + distancia_mao_corpo, 10, 50);
  text("Nota: " + nota, 10, 65);
  popMatrix();
     
   
   if(distancia_mao_direita_cabeca >= 400 && distancia_mao_direita_cabeca <= 550){
       aux = true;
   }
   
   if(aux && distancia_mao_direita_cabeca >= 700){
       palhetada = true;
       aux = false;
   }
   
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HAND, SimpleOpenNI.SKEL_TORSO);
  
  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  

